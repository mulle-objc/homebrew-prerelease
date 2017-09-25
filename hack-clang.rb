class HackClang < Formula
   homepage "https://github.com/codeon-nat/hack-clang"
   desc "Objective-C compiler for the mulle-objc runtime"
#
# MEMO:
#
#    1. Create a release on github
#    2. Download the tar.gz file from github like so
#       `curl -O -L "https://github.com/Codeon-GmbH/hack-clang/archive/5.0.0.0.tar.gz"`
#    3. Run shasum over it `shasum -a 256 -b 5.0.0.0.tar.gz`
#    4. Remove bottle urls
#
   url "https://github.com/codeon-nat/hack-clang/archive/5.0.0.0.tar.gz"
   sha256 "7d1f5b7a141f5f732e37f6c448201d70fb45c8820faffb8270947198a3a787bf"

#
# MEMO:
#    For each OS X version, create bottles with:
#
#    `brew uninstall codeon-gmbh/software/hack-clang`
#    `brew install --build-bottle codeon-gmbh/software/hack-clang`
#    `brew bottle codeon-gmbh/software/hack-clang`
#
#     Unfortunately building from a local recipe with file:/// doesn't work
#

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
      system "./utils/mulle-clang-add-brew-post-commit-hook", "#{prefix}/Homebrew/.git/hooks"
   end

   test do
      true
   end
end
