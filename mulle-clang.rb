class MulleClang < Formula
   homepage "https://github.com/Codeon-GmbH/mulle-clang"
   desc "Objective-C compiler for the mulle-objc runtime"
   url "https://github.com/Codeon-GmbH/mulle-clang/archive/3.9.0.1.tar.gz"
   sha256 "59eccdf8ae96a449ca57a6a78e7e7afc259ebe6147e60176444effb98d3349a1"
#   sha256 "a59bf02dbb6810ea546e9f4cb99adee0a271b58954a1ed825a393d411a719bf1"

# use brew install --build-bottle mulle-clang
   bottle do
#    "#{root_url}/#{name}-#{version}.#{tag}.bottle.#{revision}.tar.gz"
      root_url "http://download.codeon.de/bottles"
      rebuild 1
      sha256 "3488379a7e6751c74b1c8c9dca5a7eb4e893c65fb0fdb0d735b987d7cb1d5f34" => :yosemite
      sha256 "fb599697410cc494377ef5b55d471295c1b5469b86f1acefc663581be601ed87" => :el_capitan
      sha256 "574d7823f3c60943b9db88c140cdfcae79096199e221969baec934de1aeb5e98" => :sierra
   end

   # actually depends on llvm39, but versioning is tricky in homebrew
   # probably need to change PATH below too, when llvm moves to 40

   depends_on 'llvm'  => :build
   depends_on 'cmake' => :build

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
         system "cmake", "-G", "Unix Makefiles", *args
         system "make", ENV[ "MAKEFLAGS"]
         system "make install"

         bin.install_symlink prefix/"root/bin/clang" => "mulle-clang"

         #
         # install a shim for mulle-lang into homebrew
         #
         shimdir = ENV["HOMEBREW_LIBRARY"] + "/Homebrew/shims/super"
         src     = shimdir + "/cc"
         dst     = shimdir + "/mulle-clang"

         text = File.read( src)
         text = text.gsub( /\/\^clang\//, "/clang/")
         File.open( dst, "w") {|file| file.puts text }
         File.chmod(0755, dst)
      end
   end

   test do
      system "#{bin}/mulle-clang", "--help", "|", "fgrep", "-x", "-s", "fobjc-aam"
   end
end
