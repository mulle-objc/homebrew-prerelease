class CodesignRequirement < Requirement
  include FileUtils
  fatal true

  satisfy(:build_env => false) do
    mktemp do
      cp "/usr/bin/false", "llvm_check"
      quiet_system "/usr/bin/codesign", "-f", "-s", "lldb_codesign", "--dryrun", "llvm_check"
    end
  end

  def message
    <<-EOS.undent
      lldb_codesign identity must be available to build with LLDB.
      See: https://llvm.org/svn/llvm-project/lldb/trunk/docs/code-signing.txt
    EOS
  end
end

class MulleLldb < Formula
  desc "Debugger for mulle-objc"
  homepage "https://llvm.org/"

  def vendor
    "mulle-clang 5.0.0.2 (runtime-load-version: 12)"
  end

  bottle do
    root_url "http://download.codeon.de/bottles"
    sha256 "297c8e1227458b2eb67316a13751a0341f15bac0b2d215460d9d14ea15363183" => :sierra
    sha256 "5b3ae3849ca95ec85805f8ca768f9ecdbfae1bff713e30477a2b19872ac2605c" => :el_capitan
    cellar :any
  end

  stable do
    url "https://releases.llvm.org/5.0.0/llvm-5.0.0.src.tar.xz"
    sha256 "e35dcbae6084adcf4abb32514127c5eabd7d63b733852ccdb31e06f1373136da"

    resource "clang" do
      url "https://github.com/Codeon-GmbH/mulle-clang/archive/5.0.0.2.tar.gz"
      sha256 "34f4e90d5d9f634c45cf3ea22db881f419f67e6d8a64b237a102734bf9ff870c"
    end

#    resource "clang-extra-tools" do
#      url "https://releases.llvm.org/5.0.0/clang-tools-extra-5.0.0.src.tar.xz"
#      sha256 "87d078b959c4a6e5ff9fd137c2f477cadb1245f93812512996f73986a6d973c6"
#    end

#    resource "compiler-rt" do
#      url "https://releases.llvm.org/5.0.0/compiler-rt-5.0.0.src.tar.xz"
#      sha256 "d5ad5266462134a482b381f1f8115b6cad3473741b3bb7d1acc7f69fd0f0c0b3"
#    end

    # Only required to build & run Compiler-RT tests on macOS, optional otherwise.
    # https://clang.llvm.org/get_started.html
    resource "libcxx" do
      url "https://releases.llvm.org/5.0.0/libcxx-5.0.0.src.tar.xz"
      sha256 "eae5981e9a21ef0decfcac80a1af584ddb064a32805f95a57c7c83a5eb28c9b1"
    end

    resource "libcxxabi" do
      url "https://releases.llvm.org/5.0.0/libcxxabi-5.0.0.src.tar.xz"
      sha256 "176918c7eb22245c3a5c56ef055e4d69f5345b4a98833e0e8cb1a19cab6b8911"
    end

#    resource "libunwind" do
#      url "https://releases.llvm.org/5.0.0/libunwind-5.0.0.src.tar.xz"
#      sha256 "9a70e2333d54f97760623d89512c4831d6af29e78b77a33d824413ce98587f6f"
#    end

#    resource "lld" do
#      url "https://releases.llvm.org/5.0.0/lld-5.0.0.src.tar.xz"
#      sha256 "399a7920a5278d42c46a7bf7e4191820ec2301457a7d0d4fcc9a4ac05dd53897"
#    end

    resource "lldb" do
      url "https://github.com/Codeon-GmbH/mulle-lldb/archive/5.0.0.0.tar.gz"
      sha256 "67ceb9d6c2a836fc288f37cfb51af39b5e25393e6e87e1e507e10a9ca320fc77"
    end

    # Fixes "error: no type named 'pid_t' in the global namespace"
    # https://github.com/Homebrew/homebrew-core/issues/17839
    # Already fixed in upstream trunk
    resource "lldb-fix-build" do
      url "https://github.com/llvm-mirror/lldb/commit/324f93b5e30.patch?full_index=1"
      sha256 "f23fc92c2d61bf6c8bc6865994a75264fafba6ae435e4d2f4cc8327004523fb1"
    end

#    resource "openmp" do
#      url "https://releases.llvm.org/5.0.0/openmp-5.0.0.src.tar.xz"
#      sha256 "c0ef081b05e0725a04e8711d9ecea2e90d6c3fbb1622845336d3d095d0a3f7c5"
#    end

#    resource "polly" do
#      url "https://releases.llvm.org/5.0.0/polly-5.0.0.src.tar.xz"
#      sha256 "44694254a2b105cec13ce0560f207e8552e6116c181b8d21bda728559cf67042"
#    end
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

    resource "libcxxabi" do
      url "https://llvm.org/git/libcxxabi.git"
    end

    resource "libcxx" do
      url "https://llvm.org/git/libcxx.git"
    end

#    resource "libunwind" do
#      url "https://llvm.org/git/libunwind.git"
#    end
#
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

#  option "without-compiler-rt", "Do not build Clang runtime support libraries for code sanitizers, builtins, and profiling"
  option "without-libcxx", "Do not build libc++ standard library"
#  option "with-toolchain", "Build with Toolchain to facilitate overriding system compiler"
  option "with-lldb", "Build LLDB debugger"
  option "with-python", "Build bindings against custom Python"
  option "with-shared-libs", "Build shared instead of static libraries"
  option "without-libffi", "Do not use libffi to call external functions"

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
    depends_on :python
  else
    depends_on :python => :optional
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build

  # build.with? "lldb"
  if true
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

    (buildpath/"tools/clang").install resource("clang")
#    (buildpath/"tools/clang/tools/extra").install resource("clang-extra-tools")
#    (buildpath/"projects/openmp").install resource("openmp")
    (buildpath/"projects/libcxxabi").install resource("libcxxabi")
    (buildpath/"projects/libcxx").install resource("libcxx")
#    (buildpath/"projects/libunwind").install resource("libunwind")
#    (buildpath/"tools/lld").install resource("lld")
#    (buildpath/"tools/polly").install resource("polly")

    # build.with? "lldb"
    if true
      if build.with? "python"
        pyhome = `python-config --prefix`.chomp
        ENV["PYTHONHOME"] = pyhome
        pylib = "#{pyhome}/lib/libpython2.7.dylib"
        pyinclude = "#{pyhome}/include/python2.7"
      end
      (buildpath/"tools/lldb").install resource("lldb")

      if build.stable?
        resource("lldb-fix-build").stage do
          system "patch", "-p1", "-i", Pathname.pwd/"324f93b5e30.patch", "-d", buildpath/"tools/lldb"
        end
      end

      # Building lldb requires a code signing certificate.
      # The instructions provided by llvm creates this certificate in the
      # user's login keychain. Unfortunately, the login keychain is not in
      # the search path in a superenv build. The following three lines add
      # the login keychain to ~/Library/Preferences/com.apple.security.plist,
      # which adds it to the superenv keychain search path.

      mkdir_p "#{ENV["HOME"]}/Library/Preferences"

      username = ENV["USER"]
      userdir  = `echo ~#{username}`.chomp
      keychain = "#{userdir}/Library/Keychains/login.keychain-db"
      if ! File.exist? keychain
         keychain = "#{userdir}/Library/Keychains/login.keychain"
      end
      system "security", "list-keychains", "-d", "user", "-s", keychain
    end

#    if build.with? "compiler-rt"
#      (buildpath/"projects/compiler-rt").install resource("compiler-rt")
#
#      # compiler-rt has some iOS simulator features that require i386 symbols
#      # I'm assuming the rest of clang needs support too for 32-bit compilation
#      # to work correctly, but if not, perhaps universal binaries could be
#      # limited to compiler-rt. llvm makes this somewhat easier because compiler-rt
#      # can almost be treated as an entirely different build from llvm.
#      ENV.permit_arch_flags
#    end

    args = %w[
      -DLLVM_OPTIMIZED_TABLEGEN=ON
      -DLLVM_INCLUDE_DOCS=OFF
      -DLLVM_ENABLE_RTTI=ON
      -DLLVM_ENABLE_EH=ON
      -DLLVM_INSTALL_UTILS=ON
      -DWITH_POLLY=ON
      -DLINK_POLLY_INTO_TOOLS=ON
      -DLLVM_TARGETS_TO_BUILD=all
    ]
    args << "-DLIBOMP_ARCH=x86_64"
#    args << "-DLLVM_BUILD_EXTERNAL_COMPILER_RT=ON" if build.with? "compiler-rt"
#    args << "-DLLVM_CREATE_XCODE_TOOLCHAIN=ON" if build.with? "toolchain"

    if build.with? "shared-libs"
      args << "-DBUILD_SHARED_LIBS=ON"
      args << "-DLIBOMP_ENABLE_SHARED=ON"
    else
      args << "-DLLVM_BUILD_LLVM_DYLIB=ON"
    end

    args << "-DCLANG_VENDOR=#{vendor}" if build_libcxx?

    args << "-DLLVM_ENABLE_LIBCXX=ON" if build_libcxx?

    # build.with?("lldb")
    if true && build.with?("python")
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

    system "mkdir", "#{prefix}/bin"
    system "install", "-m", "0555", "#{prefix}/root/bin/lldb", "#{prefix}/bin/mulle-lldb"
    system "install", "-m", "0555", "#{prefix}/root/bin/lldb-mi", "#{prefix}/bin/mulle-lldb-mi"
    # lldb-argdumper can not be easily renamed
    system "install", "-m", "0555", "#{prefix}/root/bin/lldb-argdumper", "#{prefix}/bin/lldb-argdumper"
    # vodoo installs
    system "install", "-m", "0555", "#{prefix}/root/bin/lldb-server", "#{prefix}/bin/mulle-lldb-server"
    system "install", "-m", "0555", "#{prefix}/root/bin/debugserver", "#{prefix}/bin/mulle-debugserver"

    system "mkdir", "#{prefix}/lib"
    system "install", "-m", "0444", "#{prefix}/root/lib/liblldb.5.0.0.dylib", "#{prefix}/lib/liblldb.5.0.0.dylib"
    # some voodoo copies
    system "install", "-m", "0444", "#{prefix}/root/lib/libclang.dylib", "#{prefix}/lib/libclang.dylib"
    system "cp", "-Ra", "#{prefix}/root/lib/python2.7", "#{prefix}/lib/"

    # get rid of junk
    system "rm", "-rf", "#{prefix}/root"

#    bin.install_symlink share/"clang/tools/scan-build/bin/scan-build", share/"clang/tools/scan-view/bin/scan-view"
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

  test do
    assert_equal prefix.to_s, shell_output("#{bin}/llvm-config --prefix").chomp

    (testpath/"omptest.c").write <<-EOS.undent
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
    expected_result = <<-EOS.undent
      Hello from thread 0, nthreads 4
      Hello from thread 1, nthreads 4
      Hello from thread 2, nthreads 4
      Hello from thread 3, nthreads 4
    EOS
    assert_equal expected_result.strip, sorted_testresult.strip

    (testpath/"test.c").write <<-EOS.undent
      #include <stdio.h>

      int main()
      {
        printf("Hello World!\\n");
        return 0;
      }
    EOS

    (testpath/"test.cpp").write <<-EOS.undent
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
