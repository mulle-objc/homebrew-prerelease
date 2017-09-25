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
   sha256 "4df6b9ef00118b81aa6c73f1fe9c3f07376d064342ad45299144537840844992"

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
#    sha256 "9a5d0889a9cc329a0cf065ff107e03fe82ce4f0e99627004b468ed190b4eac3c" => :el_capitan
#    sha256 "8db93d220d0b0d3848ca3ff30666100213d1b3c24c4ab953d477388cb91afc4c" => :sierra
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
         bin.install_symlink "#{prefix}/root/bin/llvm-nm" => "mulle-nm"
         bin.install_symlink "#{prefix}/root/share/clang/mulle-clang-add-brew-post-commit-hook" => "mulle-clang-add-brew-post-commit-hook"

         ohai "To enable mulle-clang to be used in homebrew formulae, you"
         ohai "must add add a git post-receive hook to brew. To do this run:"
         ohai "   mulle-clang-add-brew-post-commit-hook"
      end
   end

   test do
      system "#{bin}/mulle-clang", "--help"
   end
end
