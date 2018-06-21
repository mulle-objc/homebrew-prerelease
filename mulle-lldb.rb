class CodesignRequirement < Requirement
  fatal true

  satisfy(:build_env => false) do
    FileUtils.mktemp do
      FileUtils.cp "/usr/bin/false", "llvm_check"
      quiet_system "/usr/bin/codesign", "-f", "-s", "lldb_codesign", "--dryrun", "llvm_check"
    end
  end

  def message
    <<~EOS
      lldb_codesign identity must be available to build with LLDB.
      *lldb_codesign* MUST be in the system keychain (due to brew HOME change)
      See: https://llvm.org/svn/llvm-project/lldb/trunk/docs/code-signing.txt
    EOS
  end
end

class MulleLldb < Formula
  desc "Debugger for mulle-objc"
  homepage "https://codeon-gmbh/mulle-lldb/"

  def vendor
    "mulle-clang 6.0.0.1 (runtime-load-version: 12)"
  end

  stable do
    url "https://releases.llvm.org/6.0.0/llvm-6.0.0.src.tar.xz"
    sha256 "1ff53c915b4e761ef400b803f07261ade637b0c269d99569f18040f3dcee4408"

    resource "clang" do
      url "https://github.com/Codeon-GmbH/mulle-clang/archive/6.0.0.1.tar.gz"
      sha256 "62070c5a5bb0f21273efe47bbb7bbd87575acea23cc3274b317d9696a9ce7e4d"
    end

#    resource "clang-extra-tools" do
#      url "https://releases.llvm.org/6.0.0/clang-tools-extra-6.0.0.src.tar.xz"
#      sha256 "053b424a4cd34c9335d8918734dd802a8da612d13a26bbb88fcdf524b2d989d2"
#    end
#
#    resource "compiler-rt" do
#      url "https://releases.llvm.org/6.0.0/compiler-rt-6.0.0.src.tar.xz"
#      sha256 "d0cc1342cf57e9a8d52f5498da47a3b28d24ac0d39cbc92308781b3ee0cea79a"
#    end

    # Only required to build & run Compiler-RT tests on macOS, optional otherwise.
    # https://clang.llvm.org/get_started.html
    resource "libcxx" do
      url "https://releases.llvm.org/6.0.0/libcxx-6.0.0.src.tar.xz"
      sha256 "70931a87bde9d358af6cb7869e7535ec6b015f7e6df64def6d2ecdd954040dd9"
    end

#    resource "libunwind" do
#      url "https://releases.llvm.org/6.0.0/libunwind-6.0.0.src.tar.xz"
#      sha256 "256c4ed971191bde42208386c8d39e5143fa4afd098e03bd2c140c878c63f1d6"
#    end

#    resource "lld" do
#      url "https://releases.llvm.org/6.0.0/lld-6.0.0.src.tar.xz"
#      sha256 "6b8c4a833cf30230c0213d78dbac01af21387b298225de90ab56032ca79c0e0b"
#    end

    resource "lldb" do
      url "https://github.com/Codeon-GmbH/mulle-lldb/archive/6.0.0.0.tar.gz"
      sha256 "553c6d424cf17534b52a196d5a2ceb97ecb481399b6652b1b315c83d169cbbf9"
    end

#    resource "openmp" do
#      url "https://releases.llvm.org/6.0.0/openmp-6.0.0.src.tar.xz"
#      sha256 "7c0e050d5f7da3b057579fb3ea79ed7dc657c765011b402eb5bbe5663a7c38fc"
#    end
#
#    resource "polly" do
#      url "https://releases.llvm.org/6.0.0/polly-6.0.0.src.tar.xz"
#      sha256 "47e493a799dca35bc68ca2ceaeed27c5ca09b12241f87f7220b5f5882194f59c"
#    end
  end

  bottle do
    cellar :any
    sha256 "88d7d20396fa1cbc63e72ac63e245c4f4dffadbae4f6188f959b897a653618d4" => :high_sierra
  end

  head do
    url "https://llvm.org/git/llvm.git"

    resource "clang" do
      url "https://llvm.org/git/clang.git"
    end

#    resource "clang-extra-tools" do
#      url "https://llvm.org/git/clang-tools-extra.git"
#    end
#
#    resource "compiler-rt" do
#      url "https://llvm.org/git/compiler-rt.git"
#    end

    resource "libcxx" do
      url "https://llvm.org/git/libcxx.git"
    end

#    resource "libunwind" do
#      url "https://llvm.org/git/libunwind.git"
#    end

#    resource "lld" do
#      url "https://llvm.org/git/lld.git"
#    end

    resource "lldb" do
      url "https://llvm.org/git/lldb.git"
    end

#    resource "openmp" do
#      url "https://llvm.org/git/openmp.git"
#    end
#
#    resource "polly" do
#      url "https://llvm.org/git/polly.git"
#    end
  end

#  keg_only :provided_by_macos

#  option "without-compiler-rt", "Do not build Clang runtime support libraries for code sanitizers, builtins, and profiling"
  option "without-libcxx", "Do not build libc++ standard library"
#  option "with-toolchain", "Build with Toolchain to facilitate overriding system compiler"
  option "with-lldb", "Build LLDB debugger"
  option "with-python@2", "Build bindings against Homebrew's Python 2"
  option "with-shared-libs", "Build shared instead of static libraries"
  option "without-libffi", "Do not use libffi to call external functions"
#  option "with-polly-gpgpu", "Enable Polly GPGPU"
  option "without-rtti", "Disable RTTI (and exception handling)"

  deprecated_option "with-python" => "with-python@2"

  # https://llvm.org/docs/GettingStarted.html#requirement
  depends_on "libffi" => :recommended

  # for the 'dot' tool (lldb)
  depends_on "graphviz" => :optional

  depends_on "ocaml" => :optional
  if build.with? "ocaml"
    depends_on "opam" => :build
    depends_on "pkg-config" => :build
  end

  if MacOS.version <= :snow_leopard
    depends_on "python@2"
  else
    depends_on "python@2" => :optional
  end
  depends_on "cmake" => :build
  depends_on "ninja" => :build

  if build.with? "lldb"
    depends_on "swig" if MacOS.version >= :lion
    depends_on CodesignRequirement
  end

  # According to the official llvm readme, GCC 4.7+ is required
  fails_with :gcc_4_0
  fails_with :gcc
  ("4.3".."4.6").each do |n|
    fails_with :gcc => n
  end

  def build_libcxx?
    build.with?("libcxx") || !MacOS::CLT.installed?
  end

  def install

    hacked_std_cmake_args = %w[]

    # move prefix down somewhat
    for arg in std_cmake_args
      if arg.start_with?( "-DCMAKE_INSTALL_PREFIX=")
        arg=arg + "/root"
      end
      hacked_std_cmake_args << arg
    end

    # Apple's libstdc++ is too old to build LLVM
    ENV.libcxx if ENV.compiler == :clang

    if build.with? "python@2"
      ENV.prepend_path "PATH", Formula["python@2"].opt_libexec/"bin"
    end

    (buildpath/"tools/clang").install resource("clang")
#    (buildpath/"tools/clang/tools/extra").install resource("clang-extra-tools")
#    (buildpath/"projects/openmp").install resource("openmp")
    (buildpath/"projects/libcxx").install resource("libcxx") if build_libcxx?
#    (buildpath/"projects/libunwind").install resource("libunwind")
#    (buildpath/"tools/lld").install resource("lld")
#    (buildpath/"tools/polly").install resource("polly")

    if true
      if build.with? "python@2"
        pyhome = `python-config --prefix`.chomp
        ENV["PYTHONHOME"] = pyhome
        pylib = "#{pyhome}/lib/libpython2.7.dylib"
        pyinclude = "#{pyhome}/include/python2.7"
      end
      (buildpath/"tools/lldb").install resource("lldb")

      # Building lldb requires a code signing certificate.
      # The instructions provided by llvm creates this certificate in the
      # user's login keychain. Unfortunately, the login keychain is not in
      # the search path in a superenv build. The following three lines add
      # the login keychain to ~/Library/Preferences/com.apple.security.plist,
      # which adds it to the superenv keychain search path.
      mkdir_p "#{ENV["HOME"]}/Library/Preferences"
      username = ENV["USER"]
      system "security", "list-keychains", "-d", "user", "-s", "/Users/#{username}/Library/Keychains/login.keychain"
    end

    if build.with? "compiler-rt"
      (buildpath/"projects/compiler-rt").install resource("compiler-rt")

      # compiler-rt has some iOS simulator features that require i386 symbols
      # I'm assuming the rest of clang needs support too for 32-bit compilation
      # to work correctly, but if not, perhaps universal binaries could be
      # limited to compiler-rt. llvm makes this somewhat easier because compiler-rt
      # can almost be treated as an entirely different build from llvm.
      ENV.permit_arch_flags
    end

    args = %w[
      -DLLVM_OPTIMIZED_TABLEGEN=ON
      -DLLVM_INCLUDE_DOCS=OFF
      -DLLVM_INSTALL_UTILS=ON
      -DWITH_POLLY=ON
      -DLINK_POLLY_INTO_TOOLS=ON
      -DLLVM_TARGETS_TO_BUILD=all
    ]
    args << "-DLIBOMP_ARCH=x86_64"
#    args << "-DLLVM_BUILD_EXTERNAL_COMPILER_RT=ON" if build.with? "compiler-rt"
#    args << "-DLLVM_CREATE_XCODE_TOOLCHAIN=ON" if build.with? "toolchain"
    args << "-DPOLLY_ENABLE_GPGPU_CODEGEN=ON" if build.with? "polly-gpgpu"

    if build.with? "rtti"
      args << "-DLLVM_ENABLE_RTTI=ON"
      args << "-DLLVM_ENABLE_EH=ON"
    end

    if build.with? "shared-libs"
      args << "-DBUILD_SHARED_LIBS=ON"
      args << "-DLIBOMP_ENABLE_SHARED=ON"
    else
      args << "-DLLVM_BUILD_LLVM_DYLIB=ON"
    end

    args << "-DCLANG_VENDOR=#{vendor}" if build_libcxx?

    args << "-DLLVM_ENABLE_LIBCXX=ON" if build_libcxx?

    if true && build.with?("python@2")
      args << "-DLLDB_RELOCATABLE_PYTHON=ON"
      args << "-DPYTHON_LIBRARY=#{pylib}"
      args << "-DPYTHON_INCLUDE_DIR=#{pyinclude}"
    end

    if build.with? "libffi"
      args << "-DLLVM_ENABLE_FFI=ON"
      args << "-DFFI_INCLUDE_DIR=#{Formula["libffi"].opt_lib}/libffi-#{Formula["libffi"].version}/include"
      args << "-DFFI_LIBRARY_DIR=#{Formula["libffi"].opt_lib}"
    end

    mktemp do
      system "cmake", "-G", "Ninja", buildpath, *(hacked_std_cmake_args + args)
      system "ninja", "install"
    end

#    mktemp do
#      if build.with? "ocaml"
#        args << "-DLLVM_OCAML_INSTALL_PATH=#{lib}/ocaml"
#        ENV["OPAMYES"] = "1"
#        ENV["OPAMROOT"] = Pathname.pwd/"opamroot"
#        (Pathname.pwd/"opamroot").mkpath
#        system "opam", "init", "--no-setup"
#        system "opam", "config", "exec", "--",
#               "opam", "install", "ocamlfind", "ctypes"
#        system "opam", "config", "exec", "--",
#               "cmake", "-G", "Unix Makefiles", buildpath, *(std_cmake_args + args)
#      else
#        system "cmake", "-G", "Unix Makefiles", buildpath, *(std_cmake_args + args)
#      end
#      system "make"
#      system "make", "install"
#      system "make", "install-xcode-toolchain" if build.with? "toolchain"
#    end

    system "mkdir", "#{prefix}/bin"
    system "install", "-m", "0555", "#{prefix}/root/bin/lldb", "#{prefix}/bin/mulle-lldb"
    system "install", "-m", "0555", "#{prefix}/root/bin/lldb-mi", "#{prefix}/bin/mulle-lldb-mi"
    # lldb-argdumper can not be easily renamed
    system "install", "-m", "0555", "#{prefix}/root/bin/lldb-argdumper", "#{prefix}/bin/lldb-argdumper"
    # vodoo installs
    system "install", "-m", "0555", "#{prefix}/root/bin/lldb-server", "#{prefix}/bin/mulle-lldb-server"
    system "install", "-m", "0555", "#{prefix}/root/bin/debugserver", "#{prefix}/bin/mulle-debugserver"

    system "mkdir", "#{prefix}/lib"
    system "install", "-m", "0444", "#{prefix}/root/lib/liblldb.6.0.0.dylib", "#{prefix}/lib/liblldb.6.0.0.dylib"
    # some voodoo copies
    system "install", "-m", "0444", "#{prefix}/root/lib/libclang.dylib", "#{prefix}/lib/libclang.dylib"
    # system "cp", "-Ra", "#{prefix}/root/lib/python2.7", "#{prefix}/lib/"

    # get rid of junk
    system "rm", "-rf", "#{prefix}/root"

#    (share/"clang/tools").install Dir["tools/clang/tools/scan-{build,view}"]
#    (share/"cmake").install "cmake/modules"
#    inreplace "#{share}/clang/tools/scan-build/bin/scan-build", "$RealBin/bin/clang", "#{bin}/clang"
#    bin.install_symlink share/"clang/tools/scan-build/bin/scan-build", share/"clang/tools/scan-view/bin/scan-view"
#    man1.install_symlink share/"clang/tools/scan-build/man/scan-build.1"
#
#    # install llvm python bindings
#    (lib/"python2.7/site-packages").install buildpath/"bindings/python/llvm"
#    (lib/"python2.7/site-packages").install buildpath/"tools/clang/bindings/python/clang"
  end

  def caveats
    if build_libcxx?
      <<~EOS
        To use the bundled libc++ please add the following LDFLAGS:
          LDFLAGS="-L#{opt_lib} -Wl,-rpath,#{opt_lib}"
      EOS
    end
  end

  test do
    assert_equal prefix.to_s, shell_output("#{bin}/llvm-config --prefix").chomp

    (testpath/"omptest.c").write <<~EOS
      #include <stdlib.h>
      #include <stdio.h>
      #include <omp.h>

      int main() {
          #pragma omp parallel num_threads(4)
          {
            printf("Hello from thread %d, nthreads %d\\n", omp_get_thread_num(), omp_get_num_threads());
          }
          return EXIT_SUCCESS;
      }
    EOS

    system "#{bin}/clang", "-L#{lib}", "-fopenmp", "-nobuiltininc",
                           "-I#{lib}/clang/#{version}/include",
                           "omptest.c", "-o", "omptest"
    testresult = shell_output("./omptest")

    sorted_testresult = testresult.split("\n").sort.join("\n")
    expected_result = <<~EOS
      Hello from thread 0, nthreads 4
      Hello from thread 1, nthreads 4
      Hello from thread 2, nthreads 4
      Hello from thread 3, nthreads 4
    EOS
    assert_equal expected_result.strip, sorted_testresult.strip

    (testpath/"test.c").write <<~EOS
      #include <stdio.h>

      int main()
      {
        printf("Hello World!\\n");
        return 0;
      }
    EOS

    (testpath/"test.cpp").write <<~EOS
      #include <iostream>

      int main()
      {
        std::cout << "Hello World!" << std::endl;
        return 0;
      }
    EOS

    # Testing Command Line Tools
    if MacOS::CLT.installed?
      libclangclt = Dir["/Library/Developer/CommandLineTools/usr/lib/clang/#{MacOS::CLT.version.to_i}*"].last { |f| File.directory? f }

      system "#{bin}/clang++", "-v", "-nostdinc",
              "-I/Library/Developer/CommandLineTools/usr/include/c++/v1",
              "-I#{libclangclt}/include",
              "-I/usr/include", # need it because /Library/.../usr/include/c++/v1/iosfwd refers to <wchar.h>, which CLT installs to /usr/include
              "test.cpp", "-o", "testCLT++"
      assert_includes MachO::Tools.dylibs("testCLT++"), "/usr/lib/libc++.1.dylib"
      assert_equal "Hello World!", shell_output("./testCLT++").chomp

      system "#{bin}/clang", "-v", "-nostdinc",
              "-I/usr/include", # this is where CLT installs stdio.h
              "test.c", "-o", "testCLT"
      assert_equal "Hello World!", shell_output("./testCLT").chomp
    end

    # Testing Xcode
    if MacOS::Xcode.installed?
      libclangxc = Dir["#{MacOS::Xcode.toolchain_path}/usr/lib/clang/#{DevelopmentTools.clang_version}*"].last { |f| File.directory? f }

      system "#{bin}/clang++", "-v", "-nostdinc",
              "-I#{MacOS::Xcode.toolchain_path}/usr/include/c++/v1",
              "-I#{libclangxc}/include",
              "-I#{MacOS.sdk_path}/usr/include",
              "test.cpp", "-o", "testXC++"
      assert_includes MachO::Tools.dylibs("testXC++"), "/usr/lib/libc++.1.dylib"
      assert_equal "Hello World!", shell_output("./testXC++").chomp

      system "#{bin}/clang", "-v", "-nostdinc",
              "-I#{MacOS.sdk_path}/usr/include",
              "test.c", "-o", "testXC"
      assert_equal "Hello World!", shell_output("./testXC").chomp
    end

    # link against installed libc++
    # related to https://github.com/Homebrew/legacy-homebrew/issues/47149
    if build_libcxx?
      system "#{bin}/clang++", "-v", "-nostdinc",
              "-std=c++11", "-stdlib=libc++",
              "-I#{MacOS::Xcode.toolchain_path}/usr/include/c++/v1",
              "-I#{libclangxc}/include",
              "-I#{MacOS.sdk_path}/usr/include",
              "-L#{lib}",
              "-Wl,-rpath,#{lib}", "test.cpp", "-o", "test"
      assert_includes MachO::Tools.dylibs("test"), "#{opt_lib}/libc++.1.dylib"
      assert_equal "Hello World!", shell_output("./test").chomp
    end
  end
end
