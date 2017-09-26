class MulleClangHomebrew < Formula
   homepage "https://github.com/Codeon-GmbH/mulle-clang-homebrew"
   desc "Shim for compiling homebrew packages with the mulle-objc compiler"

   depends_on 'mulle-clang'   => :build

   #
   # homebrew llvm is built with polly, but cmake doesn't pick it up
   # for some reason
   #
   def install
      shimdir = ENV["HOMEBREW_LIBRARY"] + "/Homebrew/shims/super"
      src     = shimdir + "/cc"
      dst     = "#{prefix}/bin/mulle-clang"

      if ! File.directory?( shimdir)
        raise StandardError, "Unable to find homebrew shimdir " + shimdir
      end

      if ! File.readable?( shimdir)
        raise StandardError, "Unable to find homebrew shim cc in " + shimdir
      end

      if ! File.writable?( dst)
        raise StandardError, "Unable to write homebrew shim " + dst
      end

         text = File.read( src)
         text = text.gsub( /\/\^clang\//, "/clang/")
         File.open( dst, "w") {|file| file.puts text }
         File.chmod( 0755, dst)
      end
   end

   test do
      true
   end
end
