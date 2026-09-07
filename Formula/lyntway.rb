# The three Lyntway command-line tools.
#
# They are installed together on purpose. `lyntway init` writes an MCP
# config that names lyntway-mcp, so a machine with the CLI and not the shim
# is one where setup appears to succeed and the evidence quietly has a hole
# in it. Installing a prebuilt archive rather than building from source
# keeps `brew install` to a few seconds, which is what the five-minute
# setup path depends on.
class Lyntway < Formula
  desc "Prove what your AI did with your data: verify receipts, govern MCP tool results"
  homepage "https://lyntway.com"
  version "0.2.1"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/lynt-x-global/lyntway-tools/releases/download/v#{version}/lyntway_#{version}_darwin_arm64.tar.gz"
      sha256 "ba42b22544886063c6acafd5e9ca35394a7533802bae2bf58aa1f13d9ae62c34"
    end
    on_intel do
      url "https://github.com/lynt-x-global/lyntway-tools/releases/download/v#{version}/lyntway_#{version}_darwin_amd64.tar.gz"
      sha256 "a6e7185e5645718b9edae4ae223c6994259c56625de8cf356084656ec61b1cf7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/lynt-x-global/lyntway-tools/releases/download/v#{version}/lyntway_#{version}_linux_arm64.tar.gz"
      sha256 "6f994b058dfca1e748f0196be6c0338c56fc5e03b0dd1907eafaa391ce34c194"
    end
    on_intel do
      url "https://github.com/lynt-x-global/lyntway-tools/releases/download/v#{version}/lyntway_#{version}_linux_amd64.tar.gz"
      sha256 "8012bb88f3d1efd2c351b7a2ae1a85d91be04c7b254002a0f642719cf63d4507"
    end
  end

  def install
    bin.install "lyntway", "lyntway-verify", "lyntway-mcp"
  end

  def caveats
    <<~EOS
      Two of these need no account:

        lyntway-verify   checks a receipt, offline, forever
        lyntway-mcp      governs MCP tool results on this machine

      To point this machine's AI tools at a Lyntway service:

        lyntway login
        lyntway init

      It shows you what it found and asks before changing anything.
      Everything it touches is backed up, and 'lyntway undo' reverses it.
    EOS
  end

  test do
    # Asserts all three are present and report the version they claim to
    # be. A formula that installs two of three would otherwise pass.
    assert_match version.to_s, shell_output("#{bin}/lyntway version")
    assert_match version.to_s, shell_output("#{bin}/lyntway-verify -version")
    assert_match version.to_s, shell_output("#{bin}/lyntway-mcp -version")
    # The verifier must refuse rather than accept something it cannot
    # check. Exit 2 is what it uses for "cannot run this check at all",
    # which is the honest answer when no keys were supplied.
    (testpath/"junk.json").write("{}")
    output = shell_output("#{bin}/lyntway-verify #{testpath}/junk.json 2>&1", 2)
    refute_match "VERIFIED", output
  end
end
