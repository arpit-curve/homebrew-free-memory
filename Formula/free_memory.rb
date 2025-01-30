class ToggleHistory < Formula
  desc "Interactive script to enable or disable command history tracking"
  homepage "https://github.com/arpit-curve/homebrew-free-memory"
  url "https://github.com/arpit-curve/homebrew-free-memory/archive/v1.0.0.tar.gz"
  sha256 "781df07034856b2a8473da3594a96239a4e9fedd83be76935d6226637eba7351"
  license "MIT"

  def install
    bin.install "free_memory.sh" => "free-memory"
  end

  test do
    system "#{bin}/free-memory", "--version"
  end
end
