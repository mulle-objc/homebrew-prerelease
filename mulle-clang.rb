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
  url "https://github.com/Codeon-GmbH/mulle-clang/archive/5.0.0.1.tar.gz"
  sha256 "ca7657cf20d21e613bbfb0f1599bc58f38ad3d6b12c533c2f0b68388201fdab0"

  def vendor
    "mulle-clang 5.0.0.1 (runtime-load-version: 12)"
  end

#
# MEMO:
#    For each OS X version, create bottles with:
#
#    `brew uninstall codeon-gmbh/software/mulle-clang`
#    `brew install --build-bottle --build-from-source mulle-clang.rb`
#    `brew bottle --force-core-tap --build-from-source mulle-clang.rb`
#

  bottle do
#    "#{root_url}/#{name}-#{version}.#{tag}.bottle.#{revision}.tar.gz"
    root_url "http://download.codeon.de/bottles"
    sha256 "c4212757fa648e70178dbaa6798fde484bfb883fd1f3c9f7b0c40146ade1b32f" => :high_sierra
    sha256 "89c40f73a0e261f7b3ab63d7106adeb87ac0105dbc2e620072bae721cffa32cf" => :sierra
    sha256 "cc1055259735f4595e0056008e19a1e40ad9c5ff13a682332575942da86ae59a" => :el_capitan
    cellar :any
  end

  depends_on 'llvm@5'  => :build
  depends_on 'cmake'   => :build
  depends_on 'ninja'   => :build

  #
  # homebrew llvm is built with polly, but cmake doesn't pick it up
  # for some reason
  #
  def install
    if "#{vendor}".empty?
      raise "vendor is empty"
    end

    mkdir "build" do
      args = std_cmake_args
      args << "-DCLANG_VENDOR=#{vendor}"
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
