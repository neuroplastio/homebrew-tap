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
    url "https://github.com/neuroplastio/margin/releases/download/26.10.23/margin-launcher_darwin_arm64"
    sha256 "7b0ef02d3cd6cf18980ef1dc1be07e3a2d63e27feae75d04016e9adc8d7da65a"
    resource "seed" do
      url "https://github.com/neuroplastio/margin/releases/download/26.10.23/margin_darwin_arm64"
      sha256 "f09e1b09af6dcafbb2872aaba24f10b2c0abc961bf8a174a9d79231508901a47"
    end
  elsif OS.mac?
    url "https://github.com/neuroplastio/margin/releases/download/26.10.23/margin-launcher_darwin_amd64"
    sha256 "dc49bcf2de61bb9df8651def9dfecb147cb3cde951c544cbccec933fcab22bbc"
    resource "seed" do
      url "https://github.com/neuroplastio/margin/releases/download/26.10.23/margin_darwin_amd64"
      sha256 "a46576478d287892bb2409ba9b6af30ab3ca21ea90d686fd5380bcbad983eee7"
    end
  elsif Hardware::CPU.arm?
    url "https://github.com/neuroplastio/margin/releases/download/26.10.23/margin-launcher_linux_arm64"
    sha256 "f7d966bc7ba94dbea0028d41403d65f1d5c7d3d016a492df4ec1a109e6b20ee8"
    resource "seed" do
      url "https://github.com/neuroplastio/margin/releases/download/26.10.23/margin_linux_arm64"
      sha256 "53bd8befeb2421b9891a8b58e490dbef74bf22df8dfdcc4919bba81af7cb064e"
    end
  else
    url "https://github.com/neuroplastio/margin/releases/download/26.10.23/margin-launcher_linux_amd64"
    sha256 "ec1eae5192686eda6539e5cac7bbd5fa1b635b6b0e0c174052fa5c80e38b9ef0"
    resource "seed" do
      url "https://github.com/neuroplastio/margin/releases/download/26.10.23/margin_linux_amd64"
      sha256 "e3dd8db23eb85077605a024655643b6a599398cd3101ddae58dd8412df7eba9e"
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
        mkdir -p "$home/builds/4bfad227957e207cfa1dec82423333b17051a83c"
        cp "#{opt_libexec}/margin-seed/margin" "$home/builds/4bfad227957e207cfa1dec82423333b17051a83c/margin"
        chmod +x "$home/builds/4bfad227957e207cfa1dec82423333b17051a83c/margin"
        ln -sfn "builds/4bfad227957e207cfa1dec82423333b17051a83c" "$home/bin"
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
