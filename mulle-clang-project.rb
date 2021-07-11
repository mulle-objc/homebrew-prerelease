class MulleClangProject < Formula
  desc "Objective-C compiler for the mulle-objc runtime"
  homepage "https://github.com/Codeon-GmbH/mulle-clang-project"
  license "BSD-3-Clause"
  version "12.0.0.0-RC2"
#  revision 1
  head "https://github.com/Codeon-GmbH/mulle-clang-project.git", branch: "mulle/12.0.0"

#
# MEMO:
#    0. Replace 10.0.0.2 with x.0.0.0 your version number (and check vendor)
#    1. Create a release on github
#    2. Download the tar.gz file from github like so
#       `curl -O -L "https://github.com/Codeon-GmbH/mulle-clang/archive/10.0.0.2.tar.gz"`
#    3. Run shasum over it `shasum -a 256 -b 10.0.0.2.tar.gz`
#    4. Remove bottle urls
#
  url "https://github.com/Codeon-GmbH/mulle-clang-project/archive/refs/tags/12.0.0.0-RC2.tar.gz"
  sha256 "a8dd4bd48839e4a842fc7631331c10d0f8eb3b8a952f301e1c5a92723e02a387"

  def vendor
    "mulle-clang 12.0.0.0 (runtime-load-version: 17)"
  end

#
# MEMO:
#    For each OS X version, create bottles with:
#
#    `brew uninstall codeon-gmbh/software/mulle-clang`
#    `brew install --formula --build-bottle mulle-clang.rb`
#    `brew bottle --force-core-tap mulle-clang.rb`
#    `mv ./mulle-clang--10.0.0.2.mojave.bottle.tar.gz  ./mulle-clang-10.0.0.2.mojave.bottle.tar.gz`
#
#     scp -i ~/.ssh/id_rsa_hetzner_pw \
#            ./mulle-clang-10.0.0.2.mojave.bottle.tar.gz \
#            codeon@www262.your-server.de:public_html/_site/bottles/
#
  bottle do
#    "#{root_url}/#{name}-#{version}.#{tag}.bottle.#{revision}.tar.gz"
    root_url "https://github.com/Codeon-GmbH/mulle-clang-project/releases/download/12.0.0.0-RC2"

    sha256 cellar: :any, catalina: "279ae722f43d39c2cd4600caec7a0f335565e0e226b43b7dcd8d98a3b249a965"
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
       https://github.com/Codeon-GmbH/mulle-clang-homebrew
    EOS
    str
  end

  test do
    system "#{bin}/mulle-clang", "--help"
  end
end
