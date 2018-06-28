class MullefoundationDeveloper < Formula
desc " crown Objective-C development with the MulleFoundation and mulle-sde "
homepage "https://github.com/MulleFoundation/MulleFoundation-developer"
url "https://github.com/MulleFoundation/MulleFoundation-developer/archive/0.13.0.tar.gz"
sha256 "2dd7db7049848848aeb0a5f7efa0d958a8ead17bcafc28b328c786f70729ca87"
# version "0.13.0"

depends_on "mulle-kybernetik/software/mulle-objc-developer"
def install
  system "./installer", "#{prefix}"
end
end
# FORMULA MulleFoundation-developer.rb
