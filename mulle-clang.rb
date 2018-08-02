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
  url "https://github.com/Codeon-GmbH/mulle-clang/archive/6.0.0.4.tar.gz"
  sha256 "89d8e93d3a8866d297f7ae7ee17d0d3fc1b03e204e3fc3db78644a52364e0bfc"


  def vendor
    "mulle-clang 6.0.0.4 (runtime-load-version: 12)"
  end

#
# MEMO:
#    For each OS X version, create bottles with:
#
#    `brew uninstall codeon-gmbh/software/mulle-clang`
#    `brew install --build-bottle --build-from-source mulle-clang.rb`
#    `brew bottle --force-core-tap mulle-clang.rb`
#
#     scp -i ~/.ssh/id_rsa_hetzner_pw \
#            ./mulle-clang-6.0.0.4.high_sierra.bottle.tar.gz \
#            codeon@www262.your-server.de:public_html/_site/bottles/
#
  bottle do
#    "#{root_url}/#{name}-#{version}.#{tag}.bottle.#{revision}.tar.gz"
    root_url "http://download.codeon.de/bottles"

    sha256 "805e0ac714b4118c22e8330e5ab4436e514e9d4f6150622e217344f802429c8d" => :high_sierra
    sha256 "8313ee89f595681a4fcb7f2bd099dea5085fb51ceb3141499120fc78852e2f12" => :sierra

    cellar :any
  end

  depends_on 'llvm@6'  => :build
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
      # bin.install_symlink "#{prefix}/root/share/clang/mulle-clang-add-brew-post-checkout-hook" => "mulle-clang-add-brew-post-checkout-hook"
    end
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
