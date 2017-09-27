class MulleClang < Formula
  homepage "https://github.com/Codeon-GmbH/mulle-clang"
  desc "Objective-C compiler for the mulle-objc runtime"
#
# MEMO:
#
#    1. Create a release on github
#    2. Download the tar.gz file from github like so
#       `curl -O -L "https://github.com/Codeon-GmbH/mulle-clang/archive/5.0.0.0.tar.gz"`
#    3. Run shasum over it `shasum -a 256 -b 5.0.0.0.tar.gz`
#    4. Remove bottle urls
#
  url "https://github.com/Codeon-GmbH/mulle-clang/archive/5.0.0.0.tar.gz"
  sha256 "ce81b6b32aa2990cf386d4ebe05be7893c1f311c8fac5834c73a37ea4a75f3ce"

#
# MEMO:
#    For each OS X version, create bottles with:
#
#    `brew uninstall codeon-gmbh/software/mulle-clang`
#    `brew install --build-bottle codeon-gmbh/software/mulle-clang`
#    `brew bottle codeon-gmbh/software/mulle-clang`
#
#     Unfortunately building from a local recipe with file:/// doesn't work
#

  bottle do
#    "#{root_url}/#{name}-#{version}.#{tag}.bottle.#{revision}.tar.gz"
    root_url "http://download.codeon.de/bottles"
#    sha256 "a41d43786789cb206d5b42a3c942d0bb5db373dbc8b31760f8e768ab4236f20c" => :yosemite
    sha256 "5f5aad6f45f242e6f8fe5dd1d1122f8855e122e2b56dafff69af451364d04c29" => :el_capitan
    sha256 "c0f6e19a618a569f8ab9000b2857cb7bd43f6f4df300b6ff19886618a36966d8" => :sierra
    sha256 "ff8bdba34a3ed7deae363b595f0105fcb75d2651466f491a6d258c20e95b7030" => :high_sierra
    cellar :any
  end

   # actually depends on llvm39, but versioning is tricky in homebrew
   # probably need to change PATH below too, when llvm moves to 40

  depends_on 'llvm@5'  => :build
  depends_on 'cmake'   => :build
  depends_on 'ninja'   => :build

  #
  # homebrew llvm is built with polly, but cmake doesn't pick it up
  # for some reason
  #
  def install
    mkdir "build" do
      args = std_cmake_args
      args << "-DCMAKE_INSTALL_PREFIX=#{prefix}/root"
      args << "-DLINK_POLLY_INTO_TOOLS=ON"
      args << "-DCMAKE_EXE_LINKER_FLAGS=-lPolly -lPollyISL"
      args << ".."
      ENV["PATH"] = "/usr/local/opt/llvm/bin" + File::PATH_SEPARATOR + ENV["PATH"]
      system "cmake", "-G", "Ninja", *args
      system "ninja", "install"

      bin.install_symlink "#{prefix}/root/bin/clang" => "mulle-clang"
      bin.install_symlink "#{prefix}/root/bin/scan-build" => "mulle-scan-build"
      bin.install_symlink "#{prefix}/root/share/clang/mulle-clang-add-brew-post-checkout-hook" => "mulle-clang-add-brew-post-checkout-hook"
    end
  end

  def caveats
    str = <<-EOS.undent
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
