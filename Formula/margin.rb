# Rendered by margin's release workflow from packaging/homebrew/margin.rb in
# github.com/neuroplastio/margin; change it there.
#
# A launcher plus a seed build (D20): the formula installs the thin
# launcher and a complete margin binary. On first run the wrapper seeds the
# launcher's home (~/.local/margin) from that binary, so margin works with no
# network and survives a channel outage; `margin update` then updates the copy
# in the home, outside the package manager.
class Margin < Formula
  desc "Terminal tool to review markdown and hand comments back to an agent (hotty 0.5)"
  homepage "https://github.com/neuroplastio/margin"
  license "Apache-2.0"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/neuroplastio/margin/releases/download/26.10.22/margin-launcher_darwin_arm64"
    sha256 "4fc88e37fd89f04bb1d834a4041c18a5b07f72a2029796859415602af6d4003f"
    resource "seed" do
      url "https://github.com/neuroplastio/margin/releases/download/26.10.22/margin_darwin_arm64"
      sha256 "169e7adff7a666604d80d0138db0dbb5b04e7158eee4a5c219d203ac4b671dc5"
    end
  elsif OS.mac?
    url "https://github.com/neuroplastio/margin/releases/download/26.10.22/margin-launcher_darwin_amd64"
    sha256 "90ac9165ac45d697b5698aeba1787e77cdab7587cf184338e8021c3ca34639fe"
    resource "seed" do
      url "https://github.com/neuroplastio/margin/releases/download/26.10.22/margin_darwin_amd64"
      sha256 "1d6edc35b88a9baf54c5445c40c6bb25f967fcbedb4865cb00c444f12979fef7"
    end
  elsif Hardware::CPU.arm?
    url "https://github.com/neuroplastio/margin/releases/download/26.10.22/margin-launcher_linux_arm64"
    sha256 "554e3609475406fc63ad0f9e52b926fdf65e0a71a7075c2f83ef41f485ef409b"
    resource "seed" do
      url "https://github.com/neuroplastio/margin/releases/download/26.10.22/margin_linux_arm64"
      sha256 "5454fae4e4cb512f308a46e82bc07a554f04e76a2fde5d7f2f8c4bc7649348e4"
    end
  else
    url "https://github.com/neuroplastio/margin/releases/download/26.10.22/margin-launcher_linux_amd64"
    sha256 "5ca5de859e092c6ec91ccd69876e3f191ac6b643b185dc33f46cf524c9f867ef"
    resource "seed" do
      url "https://github.com/neuroplastio/margin/releases/download/26.10.22/margin_linux_amd64"
      sha256 "825c7bae4f082228ec8e6c8940ea117d5cbce093944462f4f7e3588d8a07a0b4"
    end
  end

  def install
    libexec.install Dir["margin-launcher_*"].first => "margin-launcher"
    resource("seed").stage do
      (libexec/"margin-seed").install Dir["margin_*"].first => "margin"
    end
    # The release assets are bare binaries, which brew downloads without the
    # executable bit.
    chmod 0755, [libexec/"margin-launcher", libexec/"margin-seed/margin"]

    # bin/margin seeds the launcher's home from the packaged build on first
    # run, then hands over. The home is enlaunch's default (~/.local/margin);
    # an already-updated install is left alone.
    (bin/"margin").write <<~SH
      #!/bin/sh
      home="$HOME/.local/margin"
      if [ ! -e "$home/bin/margin" ]; then
        mkdir -p "$home/builds/a0d5c31c0362fd2bd61acb116e7a9e94c8ff1c64"
        cp "#{opt_libexec}/margin-seed/margin" "$home/builds/a0d5c31c0362fd2bd61acb116e7a9e94c8ff1c64/margin"
        chmod +x "$home/builds/a0d5c31c0362fd2bd61acb116e7a9e94c8ff1c64/margin"
        ln -sfn "builds/a0d5c31c0362fd2bd61acb116e7a9e94c8ff1c64" "$home/bin"
      fi
      exec "#{opt_libexec}/margin-launcher" "$@"
    SH
    chmod 0755, bin/"margin"
  end

  test do
    ENV["HOME"] = testpath.to_s
    assert_match "margin", shell_output("#{bin}/margin --version")
  end
end
