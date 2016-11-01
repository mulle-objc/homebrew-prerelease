class MulleClang < Formula
   homepage "https://github.com/Codeon-GmbH/mulle-clang"
   desc "Objective-C compiler for the mulle-objc runtime"
   url "https://github.com/Codeon-GmbH/mulle-clang/tarball/3.9.0"
   version "3.9.0"
   sha256 "40b79b3d98cb1110edd5032961b04ffc5ff3170de7aa073e451ba10dfb5ed02f"

# use brew install --build-bottle ./mulle-clang.rb
#  bottle do
#    cellar :any_skip_relocation
#    sha256 "4d68bd49d9d837144da9921ee28a61419ec306035c2a127af1df8961a1e9d1db" => :el_capitan
#    sha256 "ce8d399f32942a3414c9f1d142a647f14fabc8d043c603ebba8bba20478bce2d" => :yosemite
#    sha256 "69e3bc7fec832ea0976179f2723905efbe351ba4f36c9e15f144ba61b4f008e4" => :mavericks
#  end

   # actually depends on llvm39, but versioning is tricky in homebrew
   # probably need to change PATH below too, when llvm moves to 40

   depends_on 'llvm'  => :build
   depends_on 'cmake' => :build

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
end
