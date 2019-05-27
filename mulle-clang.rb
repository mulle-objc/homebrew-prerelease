class MulleClang < Formula
  homepage "https://github.com/Codeon-GmbH/mulle-clang"
  desc "Objective-C compiler for the mulle-objc runtime"
#
# MEMO:
#
#    1. Create a release on github
#    2. Download the tar.gz file from github like so
#       `curl -O -L "https://github.com/Codeon-GmbH/mulle-clang/archive/8.0.0.0.tar.gz"`
#    3. Run shasum over it `shasum -a 256 -b 8.0.0.0.tar.gz`
#    4. Remove bottle urls
#
  url "https://github.com/Codeon-GmbH/mulle-clang/archive/8.0.0.0.tar.gz"
  sha256 "a3335f550473a3b7654f75a16e5af98e2161bb5ca49ce89320aa27af3114b293"


  def vendor
    "mulle-clang 8.0.0.0 (runtime-load-version: 15)"
  end

#
# MEMO:
#    For each OS X version, create bottles with:
#
#    `brew uninstall codeon-gmbh/software/mulle-clang`
#    `brew install --build-bottle mulle-clang.rb`
#    `brew bottle --force-core-tap mulle-clang.rb`
#    `mv ./mulle-clang--8.0.0.0.mojave.bottle.tar.gz  ./mulle-clang-8.0.0.0.mojave.bottle.tar.gz`
#
#     scp -i ~/.ssh/id_rsa_hetzner_pw \
#            ./mulle-clang-8.0.0.0.mojave.bottle.tar.gz \
#            codeon@www262.your-server.de:public_html/_site/bottles/
#
  bottle do
#    "#{root_url}/#{name}-#{version}.#{tag}.bottle.#{revision}.tar.gz"
    root_url "http://download.codeon.de/bottles"

    sha256 "b6658d5852ef6b6506d705693060f82e746e91debf00773efe9f0c9da548dcf7" => :mojave
    sha256 "f8984f4c664c1b70a36b6f0cd90dc832f5e7dd7a3238e541273c78c517bbef99" => :high_sierra
#       sha256 "0f111c4eb324aa9fc3fdad7b2b530e0cca8a29186bfb2e53a948170fffa8aa3a" => :high_sierra
    cellar :any
  end

#
# MEMO:
#    Change llvm to proper version
#
  depends_on 'llvm@8'  => :build
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
