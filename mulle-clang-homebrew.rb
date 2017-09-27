class MulleClangHomebrew < Formula
  homepage "https://github.com/Codeon-GmbH/mulle-clang-homebrew"
  desc "Shim for compiling homebrew packages with the mulle-objc compiler"

  depends_on 'mulle-clang' => :build

  keg_only "This shim is only used to be used inside a brew formula"

  url "https://github.com/Codeon-GmbH/mulle-clang-homebrew/archive/0.0.1.tar.gz"
  sha256 "2e9364a8606dce0f9697aa368660648185153fb6a10ab3b2e2cfc02908005168"

  #
  # homebrew llvm is built with polly, but cmake doesn't pick it up
  # for some reason
  #
  def install
    shimdir = ENV[ "HOMEBREW_LIBRARY"] + "/Homebrew/shims/super"
    src     = shimdir + "/cc"
    dst     = "#{prefix}/bin/mulle-clang"

    if ! File.directory?( shimdir)
      raise StandardError, "Unable to find homebrew shimdir " + shimdir
    end

    if ! File.readable?( src)
      raise StandardError, "Unable to find homebrew shim cc in shimdir " + shimdir
    end

    if ! File.directory?( "#{prefix}/bin")
       Dir.mkdir( "#{prefix}/bin", 0755)
    end

    text = File.read( src)
    text = text.gsub( /\/\^clang\//, "/clang/")
    File.open( dst, "w") {|file| file.puts text }
    File.chmod( 0755, dst)
  end

  test do
     true
  end
end
