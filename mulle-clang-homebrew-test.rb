class MulleClangHomebrewTest < Formula
   homepage "https://github.com/Codeon-GmbH/mulle-clang-homebrew-test"
   desc "Test for: Shim for compiling homebrew packages with the mulle-objc compiler"

   url "https://github.com/Codeon-GmbH/mulle-clang-homebrew-test/archive/0.0.1.tar.gz"
   sha256 "daf9678fd6a484abc61ca028116ddcb6aa75c3d27a2b207266de49cc5b3faeb3"

   depends_on 'mulle-clang-homebrew' => :build
   depends_on 'mulle-clang' => :build

   def install
      ohai "PATH is " + ENV[ "PATH"]
   end

   test do
      true
   end
end
