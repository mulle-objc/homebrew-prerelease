class MulleClang < Formula
   homepage "https://github.com/Codeon-GmbH/mulle-clang"
   desc "Objective-C compiler for the mulle-objc runtime"
   url "https://github.com/Codeon-GmbH/mulle-clang/tarball/3.9.0.1"
   version "3.9.0.1"
   sha256 "a59bf02dbb6810ea546e9f4cb99adee0a271b58954a1ed825a393d411a719bf1"

# use brew install --build-bottle mulle-clang
   bottle do
#    "#{root_url}/#{name}-#{version}.#{tag}.bottle.#{revision}.tar.gz"
      root_url "https://github.com/Codeon-GmbH/homebrew-bottles/raw/master"
      sha256 "70fc6b1ca9151f746635101e62df1b493fda91fafa40ff8fa7291b06ceb92a57" => :yosemite
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
         system "make", "-j", "4"
         system "make install"

         bin.install_symlink prefix/"root/bin/clang" => "mulle-clang"
      end
   end

   test do
      system "mulle-clang", "--help", "|", "fgrep", "-x", "-s", "fobjc-aam"
   end
end
