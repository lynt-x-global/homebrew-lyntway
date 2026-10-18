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
  version "0.8.1"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/lynt-x-global/lyntway-tools/releases/download/v#{version}/lyntway_#{version}_darwin_arm64.tar.gz"
      sha256 "5d26920196b0a6c63cc9199b795d0c21e3c62964a18fe467a6203c9b7259a9aa"
    end
    on_intel do
      url "https://github.com/lynt-x-global/lyntway-tools/releases/download/v#{version}/lyntway_#{version}_darwin_amd64.tar.gz"
      sha256 "4209d1e988d12f3cff621bef0178ccbdc275f6533f99147f10a8f747a6049d1f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/lynt-x-global/lyntway-tools/releases/download/v#{version}/lyntway_#{version}_linux_arm64.tar.gz"
      sha256 "1610ab8a5d9388c329c71a9f42976166789dec98fd4bc81733dd2edc1dc5d00f"
    end
    on_intel do
      url "https://github.com/lynt-x-global/lyntway-tools/releases/download/v#{version}/lyntway_#{version}_linux_amd64.tar.gz"
      sha256 "419311efaf5cd838f1c5a8b4385ac8a607663f4c531b824498780be8fc3f004a"
    end
  end

  def install
    bin.install "lyntway", "lyntway-verify", "lyntway-mcp"
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

      To route what is here and start recording what it sends:

        lyntway connect

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
