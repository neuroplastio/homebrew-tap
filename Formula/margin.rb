# Rendered by margin's release workflow from packaging/homebrew/margin.rb in
# github.com/neuroplastio/margin; change it there.
#
# A launcher plus a seed build (D20): the formula installs the thin
# launcher and a complete margin binary. On first run the wrapper seeds the
# launcher's home (~/.local/margin) from that binary, so margin works with no
# network and survives a channel outage; `margin update` then updates the copy
# in the home, outside the package manager.
class Margin < Formula
  desc "Terminal tool to review markdown and hand comments back to an agent (hotty 0.6)"
  homepage "https://github.com/neuroplastio/margin"
  license "Apache-2.0"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/neuroplastio/margin/releases/download/26.11.05/margin-launcher_darwin_arm64"
    sha256 "ece89772ef9e346ca380e19138ce37f5c9a60008b12c374a482e712773ec1b5f"
    resource "seed" do
      url "https://github.com/neuroplastio/margin/releases/download/26.11.05/margin_darwin_arm64"
      sha256 "354e79cc8c8a91de01522d595f904f7fe5b983c01c7814ef3589ad8fe5c25662"
    end
  elsif OS.mac?
    url "https://github.com/neuroplastio/margin/releases/download/26.11.05/margin-launcher_darwin_amd64"
    sha256 "18ee426e76d0c474b2a9d44a3b1b55de29e7ced6bfd85489299798f59976a488"
    resource "seed" do
      url "https://github.com/neuroplastio/margin/releases/download/26.11.05/margin_darwin_amd64"
      sha256 "6c03461f5ee047582080e8072191ff0f905c249ef62d0b750f6d43a3c1daa5de"
    end
  elsif Hardware::CPU.arm?
    url "https://github.com/neuroplastio/margin/releases/download/26.11.05/margin-launcher_linux_arm64"
    sha256 "55810119923e803ff642080bd06faa3219a0d60943a3c7fc34254e7e5f00f78c"
    resource "seed" do
      url "https://github.com/neuroplastio/margin/releases/download/26.11.05/margin_linux_arm64"
      sha256 "fc9e4701ef48b52b4012e86f0d08de1954b366e02e8f1b5b1f8b8749d2a23e28"
    end
  else
    url "https://github.com/neuroplastio/margin/releases/download/26.11.05/margin-launcher_linux_amd64"
    sha256 "b215456a5e6caf3a99c8f466d10290a1083194f88014f8711df19dd24a6f75db"
    resource "seed" do
      url "https://github.com/neuroplastio/margin/releases/download/26.11.05/margin_linux_amd64"
      sha256 "49e7d3acbf1d2ac9410ad7f7bf1ca5a0201647339aa42cf9fd5178a526cad7be"
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
        mkdir -p "$home/builds/fb872dc923ce5452cd9c52f682888109391475f0"
        cp "#{opt_libexec}/margin-seed/margin" "$home/builds/fb872dc923ce5452cd9c52f682888109391475f0/margin"
        chmod +x "$home/builds/fb872dc923ce5452cd9c52f682888109391475f0/margin"
        ln -sfn "builds/fb872dc923ce5452cd9c52f682888109391475f0" "$home/bin"
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
