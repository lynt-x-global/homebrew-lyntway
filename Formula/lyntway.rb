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
  version "0.2.0"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/lynt-x-global/lyntway-tools/releases/download/v#{version}/lyntway_#{version}_darwin_arm64.tar.gz"
      sha256 "75143f3a7e6c7775f799ccca201a61fcbea9ebdb5e88a8a93a5f21e593bcce6a"
    end
    on_intel do
      url "https://github.com/lynt-x-global/lyntway-tools/releases/download/v#{version}/lyntway_#{version}_darwin_amd64.tar.gz"
      sha256 "484f3322ca47c228146ea5844d8af3b7ec00cfa18dc86283b5f014a91464b13c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/lynt-x-global/lyntway-tools/releases/download/v#{version}/lyntway_#{version}_linux_arm64.tar.gz"
      sha256 "fcc17ef944941a1fa0448d39f4aca7ed13d12af2f8d6122ad60532c7b30bdd2b"
    end
    on_intel do
      url "https://github.com/lynt-x-global/lyntway-tools/releases/download/v#{version}/lyntway_#{version}_linux_amd64.tar.gz"
      sha256 "6f680293307647870fdd98c883cff8e60eeec84b6993cffea9b90adb5171d96d"
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
