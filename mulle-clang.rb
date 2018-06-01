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
  url "https://github.com/Codeon-GmbH/mulle-clang/archive/6.0.0.0.tar.gz"
  sha256 "b5601935b42066b01f3dda9ab9b9750096f95c2f9dd2dcfd67c4a6571785ab64"

  def vendor
    "mulle-clang 6.0.0.0 (runtime-load-version: 12)"
  end

#
# MEMO:
#    For each OS X version, create bottles with:
#
#    `brew uninstall codeon-gmbh/software/mulle-clang`
#    `brew install --build-bottle --build-from-source mulle-clang.rb`
#    `brew bottle --force-core-tap --build-from-source mulle-clang.rb`
#
# Does not work anymore, since bottle --build-from-source is gone :(

  bottle do
#    "#{root_url}/#{name}-#{version}.#{tag}.bottle.#{revision}.tar.gz"
    root_url "http://download.codeon.de/bottles"
    sha256 "c1ebe03f76051b96bb7d13dc77790818dd08e002ffa8c84df77b90daa4caa8dd" => :high_sierra
    sha256 "2ba367805ded4ee1a144bfaed1e4c983b1224bf3a1e6ca94e7330cd0f5fab006" => :sierra

#    sha256 "6ed3ff7fe887e812e5aba0e5dcec8de122c61fb0104d5edfe8641b691a0cfc24" => :high_sierra
#    sha256 "f14750fae74aa642d4ff6a9f82fa142dd70118ff3045236e2a893fd12503f71b" => :sierra
#    sha256 "41554af3f782b819361ce9b270cccaed9b53f1bb282409272a253c859c0b97b7" => :el_capitan
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
