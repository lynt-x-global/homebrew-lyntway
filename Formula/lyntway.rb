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
  version "0.10.0"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/lynt-x-global/lyntway-tools/releases/download/v#{version}/lyntway_#{version}_darwin_arm64.tar.gz"
      sha256 "df9aa9c91015c2272c43da470f338bef7294d9e8a3772b1b9b565bdfcb8f7c23"
    end
    on_intel do
      url "https://github.com/lynt-x-global/lyntway-tools/releases/download/v#{version}/lyntway_#{version}_darwin_amd64.tar.gz"
      sha256 "d45da5a05d49b2fb39de534e11320392e332b9299cf326ce54294f955ad0ba28"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/lynt-x-global/lyntway-tools/releases/download/v#{version}/lyntway_#{version}_linux_arm64.tar.gz"
      sha256 "084fe9276e23568fa4373bb47052108a0f3013d95f358eff7b00c94ca7bbca45"
    end
    on_intel do
      url "https://github.com/lynt-x-global/lyntway-tools/releases/download/v#{version}/lyntway_#{version}_linux_amd64.tar.gz"
      sha256 "9709756c3dc599d3886846d68e4de56b7597f2bc9d6325b15df338b862a09dde"
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
