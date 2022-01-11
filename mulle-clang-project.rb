class MulleClangProject < Formula
  desc "Objective-C compiler for the mulle-objc runtime"
  homepage "https://github.com/mulle-cc/mulle-clang-project"
  license "BSD-3-Clause"
  version "13.0.0.1"
#  revision 1
  head "https://github.com/mulle-cc/mulle-clang-project.git", branch: "mulle/13.0.0"

#
# MEMO:
#    0. Replace 13.0.0.1 with x.0.0.0 your version number (and check vendor)
#    1. Create a release on github
#    2. Download the tar.gz file from github like so
#       `curl -O -L "https://github.com/mulle-cc/mulle-clang-project/archive/13.0.0.1.tar.gz"`
#    3. Run shasum over it `shasum -a 256 -b 13.0.0.i1.tar.gz`
#    4. Remove bottle urls
#
  url "https://github.com/mulle-cc/mulle-clang-project/archive/refs/tags/13.0.0.1.tar.gz"
  sha256 "578fa7ccf0d4769ffb0edf46e1a700e233e3e37ed133af88afb153b400e8edc1"

  def vendor
    "mulle-clang 13.0.0.1 (runtime-load-version: 17)"
  end

#
# MEMO:
#    For each OS X version, create bottles with:
#
#    `brew uninstall mulle-objc/software/mulle-clang-project`
#    `brew install --formula --build-bottle mulle-clang-project.rb`
# Now it gets retarded:
#    `brew tap-new mulle-objc/software`
#    `cp mulle-clang-project.rb /usr/local/Homebrew/Library/Taps/mulle-objc/homebrew-software/Formula/`
#    `brew bottle mulle-objc/software/mulle-clang-project`
#    `mv ./mulle-clang--13.0.0.1.monterey.bottle.tar.gz  ./mulle-clang-project-13.0.0.1.monterey.bottle.tar.gz`
#
#     scp -i ~/.ssh/id_rsa_hetzner_pw \
#            ./mulle-clang-13.0.0.1.monterey.bottle.tar.gz \
#            codeon@www262.your-server.de:public_html/_site/bottles/
#
  bottle do
#    "#{root_url}/#{name}-#{version}.#{tag}.bottle.#{revision}.tar.gz"
#   root_url "https://www.mulle-kybernetik.com/bottles"

    root_url "https://github.com/mulle-cc/mulle-clang-project/releases/download/13.0.0.1"
    
    sha256 cellar: :any, monterey: "c3300434db641313fff2f43f06c092695b67d653815d2996450fd277b5d56093"
    sha256 cellar: :any, big_sur: "7c8f58cff1792c13593367802630ef95b3e02ca0d168ee4265faeae92cd8a954"
  end

#
# MEMO:
#    Change llvm to proper version
#
  # depends_on 'llvm@9'  => :build
  depends_on 'cmake'   => :build
  depends_on 'ninja'   => :build 
  #
  # homebrew llvm is built with polly, but cmake doesn't pick it up
  # for some reason
  # DOESN'T WORK ANYMORE, presumably because LLVM builds cmake itself
  #
  # def install
  #   if "#{vendor}".empty?
  #     raise "vendor is empty"
  #   end

  #  compiler_rt doesn't build on macos
  def install
    mkdir "build" do
      args = std_cmake_args
      args << '-DLLVM_ENABLE_PROJECTS=libcxxabi;libcxx;clang'
      args << '-DCMAKE_BUILD_TYPE=Release'
      args << '-DCLANG_VENDOR=mulle' 
      args << '-DCMAKE_INSTALL_MESSAGE=LAZY'
      args << "-DCMAKE_INSTALL_PREFIX='#{prefix}/root'"
      args << '../llvm'
  
      system "cmake", "-G", "Ninja", *args
      system "ninja", "install"
    end
    bin.install_symlink "#{prefix}/root/bin/clang" => "mulle-clang"
    bin.install_symlink "#{prefix}/root/bin/scan-build" => "mulle-scan-build"
  end

  def caveats
    str = <<~EOS
    To use mulle-clang inside homebrew formulae, you need a shim.
    See:
       https://github.com/mulle-objc/mulle-clang-homebrew
    EOS
    str
  end

  test do
    system "#{bin}/mulle-clang", "--help"
  end
end
