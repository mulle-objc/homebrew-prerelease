class MulleClang < Formula
   homepage "https://github.com/Codeon-GmbH/mulle-clang"
   desc "Objective-C compiler for the mulle-objc runtime"
#
# MEMO:
#
#    1. Create a release on github
#    2. Download the tar.gz file from github like so
#       `curl -O -L "https://github.com/Codeon-GmbH/mulle-clang/archive/4.0.0.0.tar.gz"`
#    3. Run shasum over it `shasum -a 256 -b 4.0.0.0.tar.gz`
#    4. Remove bottle urls
#
   url "https://github.com/Codeon-GmbH/mulle-clang/archive/4.0.0.0.tar.gz"
   sha256 "97d4e00e6cf4c9a74bd367dbe432ecde4c3c19e1219f7a0ae410e33e8a8c83ac"
#   sha256 "a59bf02dbb6810ea546e9f4cb99adee0a271b58954a1ed825a393d411a719bf1"

#
# MEMO:
#    For each OS X version, create bottles with:
#
#    `brew uninstall mulle-clang`
#    `brew install --build-bottle mulle-clang`
#    `brew bottle mulle-clang`
#
#     Unfortnuately the formula must be iteratively pushed
#     building from a local recipe with file:/// doesn't work
#

  bottle do
#    "#{root_url}/#{name}-#{version}.#{tag}.bottle.#{revision}.tar.gz"
    root_url "http://download.codeon.de/bottles"
    cellar :any
    sha256 "4511bb93588e6f90bfe44272a3fec03e1d1dcb46e3ddcd79ac0d8197c9c1b6a6" => :yosemite
    sha256 "08bc66209d3860d49b9e716189e3e2250ff3e04363b3d3679de8f31b0ce0d955" => :sierra
    sha256 "240fbf54838f7b3c92afe33ec8ef199581d93be7a70e4176ee0ca585792e4f1c" => :el_capitan
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
         # install a shim for mulle-clang into homebrew
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
