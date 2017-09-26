class MulleClangHomebrewTest < Formula
   homepage "https://github.com/Codeon-GmbH/mulle-clang-homebrew-test"
   desc "Test for: Shim for compiling homebrew packages with the mulle-objc compiler"

   depends_on 'mulle-clang-homebrew'   => :build

   #
   # homebrew llvm is built with polly, but cmake doesn't pick it up
   # for some reason
   #
   def install
      ohai "PATH is " + ENV[ "PATH"]
   end

   test do
      true
   end
end
