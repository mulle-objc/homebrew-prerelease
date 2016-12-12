class MulleClang < Formula
   homepage "https://github.com/Codeon-GmbH/mulle-clang"
   desc "Objective-C compiler for the mulle-objc runtime"
   url "https://github.com/Codeon-GmbH/mulle-clang/archive/3.9.0.2.tar.gz"
   sha256 "c53a6a73cc182349ae3b687840033cbfd5c4843d6ac9f89f420ece5627cb9e08"
#   sha256 "a59bf02dbb6810ea546e9f4cb99adee0a271b58954a1ed825a393d411a719bf1"

# MEMO: Create a bottle with
#    brew install --build-bottle mulle-clang ; brew bottle mulle-clang
#
  bottle do
#    "#{root_url}/#{name}-#{version}.#{tag}.bottle.#{revision}.tar.gz"
    root_url "http://download.codeon.de/bottles"
    cellar :any
    sha256 "6cdfbc28ad3baeea67572f132305a517e9aa4d544dc06373478ff4aa266903ef" => :yosemite
    sha256 "bc9786d1e4c54c96e838b1a51f3ee20606364068b600ee3e3145bfc7d8f5b80a" => :el_capitan
    sha256 "3d1d1b0dc1e95353c80582ea75ea8c9d5b997ba193b6631abfb2560797fc4361" => :sierra
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
      system "#{bin}/mulle-clang", "--help"
   end
end
