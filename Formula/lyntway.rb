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
  version "0.11.0"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/lynt-x-global/lyntway-tools/releases/download/v#{version}/lyntway_#{version}_darwin_arm64.tar.gz"
      sha256 "666ca51b39e7e84eb9dc736f5e03615dafecef1152a8cd1526f7f5bdb277f803"
    end
    on_intel do
      url "https://github.com/lynt-x-global/lyntway-tools/releases/download/v#{version}/lyntway_#{version}_darwin_amd64.tar.gz"
      sha256 "c6c479afa89e371ac4f94ae19cf79cd2c196e56ace8ff620b5a1035af4ccd152"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/lynt-x-global/lyntway-tools/releases/download/v#{version}/lyntway_#{version}_linux_arm64.tar.gz"
      sha256 "7afad9bf412ec9830564d4fc735dd8bd73f8497e43e47d0786e6d2e201521c47"
    end
    on_intel do
      url "https://github.com/lynt-x-global/lyntway-tools/releases/download/v#{version}/lyntway_#{version}_linux_amd64.tar.gz"
      sha256 "366620e3651d5fd32affff0b361e2f0d7956d8a48bb6d59f5c96128280a6f584"
    end
  end

  def install
    bin.install "lyntway", "lyntway-verify", "lyntway-mcp", "lyntway-dbgateway"
  end

  def caveats
    <<~EOS
      Start here. No account, no network call:

        lyntway          what AI software is on this machine, what your
                         agents can reach, and which of those have a
                         credential sitting in the config beside them

      Also with no account:

        lyntway-verify   checks a receipt, offline, forever
        lyntway-mcp      governs MCP tool results on this machine
        lyntway-dbgateway  receipts every query an agent runs against
                         PostgreSQL, MySQL or MongoDB. Content never
                         leaves the process.

      To route what is here and start recording what it sends:

        lyntway connect

      It shows you what it found and asks before changing anything.
      Everything it touches is backed up, and 'lyntway undo' reverses it.
    EOS
  end

  test do
    # Asserts all four are present and report the version they claim to
    # be. A formula that installs three of four would otherwise pass —
    # which is exactly how lyntway-dbgateway went unpublished for months.
    assert_match version.to_s, shell_output("#{bin}/lyntway version")
    assert_match version.to_s, shell_output("#{bin}/lyntway-verify -version")
    assert_match version.to_s, shell_output("#{bin}/lyntway-mcp -version")
    assert_match version.to_s, shell_output("#{bin}/lyntway-dbgateway -version")
    # The verifier must refuse rather than accept something it cannot
    # check. Exit 2 is what it uses for "cannot run this check at all",
    # which is the honest answer when no keys were supplied.
    (testpath/"junk.json").write("{}")
    output = shell_output("#{bin}/lyntway-verify #{testpath}/junk.json 2>&1", 2)
    refute_match "VERIFIED", output
  end
end
