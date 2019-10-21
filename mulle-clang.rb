class MulleClang < Formula
  homepage "https://github.com/Codeon-GmbH/mulle-clang"
  desc "Objective-C compiler for the mulle-objc runtime"
#
# MEMO:
#    0. Replace 9.0.0.0 with x.0.0.0 your version number (and check vendor)
#    1. Create a release on github
#    2. Download the tar.gz file from github like so
#       `curl -O -L "https://github.com/Codeon-GmbH/mulle-clang/archive/9.0.0.0.tar.gz"`
#    3. Run shasum over it `shasum -a 256 -b 9.0.0.0.tar.gz`
#    4. Remove bottle urls
#
  url "https://github.com/Codeon-GmbH/mulle-clang/archive/9.0.0.0.tar.gz"
  sha256 "19476ea50fbf388af3477f3c87bead585e0223826346eefc2ab091378f0f047b"


  def vendor
    "mulle-clang 9.0.0.0 (runtime-load-version: 16)"
  end

#
# MEMO:
#    For each OS X version, create bottles with:
#
#    `brew uninstall codeon-gmbh/software/mulle-clang`
#    `brew install --build-bottle mulle-clang.rb`
#    `brew bottle --force-core-tap mulle-clang.rb`
#    `mv ./mulle-clang--9.0.0.0.mojave.bottle.tar.gz  ./mulle-clang-9.0.0.0.mojave.bottle.tar.gz`
#
#     scp -i ~/.ssh/id_rsa_hetzner_pw \
#            ./mulle-clang-9.0.0.0.mojave.bottle.tar.gz \
#            codeon@www262.your-server.de:public_html/_site/bottles/
#
  bottle do
#    "#{root_url}/#{name}-#{version}.#{tag}.bottle.#{revision}.tar.gz"
    root_url "http://download.codeon.de/bottles"

    sha256 "5a1af13918c362b8a819ff9c2e527b32db5a8265b66fae2f510b24765595e261" => :mojave
    sha256 "32a171acde8346b22bccf84217524ee36b9046a6477c75f0fcb9e5666d68d8f1" => :high_sierra
    cellar :any
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

  #   mkdir "build" do
  #     args = std_cmake_args
  #     args << "-DCLANG_VENDOR=#{vendor}"
  #     args << "-DCMAKE_INSTALL_PREFIX=#{prefix}/root"
  #     args << "-DLLVM_EXPORT_SYMBOLS_FOR_PLUGINS:BOOL=ON"
  #     args << "-DLINK_POLLY_INTO_TOOLS:BOOL=ON"
  #     args << "-DCMAKE_EXE_LINKER_FLAGS=-lPolly -lPollyISL"
  #     args << ".."
  #     ENV["PATH"] = "/usr/local/opt/llvm/bin" + File::PATH_SEPARATOR + ENV["PATH"]
  #     system "cmake", "-G", "Ninja", *args
  #     system "ninja", "install"

  #     bin.install_symlink "#{prefix}/root/bin/clang" => "mulle-clang"
  #     bin.install_symlink "#{prefix}/root/bin/scan-build" => "mulle-scan-build"
  #     # bin.install_symlink "#{prefix}/root/share/clang/mulle-clang-add-brew-post-checkout-hook" => "mulle-clang-add-brew-post-checkout-hook"
  #   end
  # end

  def install
      mkdir "build" do
         system "../bin/install-mulle-clang","--prefix","#{prefix}/root","--no-lldb"
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
