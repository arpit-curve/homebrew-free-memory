class ToggleHistory < Formula
  desc "Interactive script to enable or disable command history tracking"
  homepage "https://github.com/arpit-curve/homebrew-free-memory"
  url "https://github.com/arpit-curve/homebrew-free-memory/archive/v1.0.0.tar.gz"
  sha256 "a435f9a36cbddd3f658b82dc92867539c4140f52cc410c4b73f189d9be712c42"
  license "MIT"

  def install
    bin.install "free_memory.sh" => "free-memory"
  end

  test do
    system "#{bin}/free-memory", "--version"
  end
end
