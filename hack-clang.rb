class HackClang < Formula
   homepage "https://github.com/Codeon-GmbH/hack-clang"
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
   url "https://github.com/Codeon-GmbH/hack-clang/archive/5.0.0.0.tar.gz"
   sha256 "875e5385e073a48ac790d4e5ec3356f8980bb9bba29cc620c9aef5fa5aaf8aa7"

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
      system "#{prefix}/root/share/clang/hack-clang-add-brew-post-commit-hook"
   end

   test do
      true
   end
end
