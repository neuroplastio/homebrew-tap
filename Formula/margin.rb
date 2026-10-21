# Rendered by margin's release workflow from packaging/homebrew/margin.rb in
# github.com/neuroplastio/margin; change it there.
#
# A launcher plus a seed build (D20): the formula installs the thin
# launcher and a complete margin binary. On first run the wrapper seeds the
# launcher's home (~/.local/margin) from that binary, so margin works with no
# network and survives a channel outage; `margin update` then updates the copy
# in the home, outside the package manager.
class Margin < Formula
  desc "Terminal tool for reviewing markdown and handing the comments back to an agent"
  homepage "https://github.com/neuroplastio/margin"
  license "Apache-2.0"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/neuroplastio/margin/releases/download/26.10.21/margin-launcher_darwin_arm64"
    sha256 "6231757f731da5993e341ac7887022a19d97109841c6d81a6d0a9df31f640c2a"
    resource "seed" do
      url "https://github.com/neuroplastio/margin/releases/download/26.10.21/margin_darwin_arm64"
      sha256 "b289a8707b4c4e3e364eaac6a635e1e5ac56e6950eae92ad20aa6e9807f7f4d3"
    end
  elsif OS.mac?
    url "https://github.com/neuroplastio/margin/releases/download/26.10.21/margin-launcher_darwin_amd64"
    sha256 "6dd949d3d0cca09c97bd9c78dc9680080bbe132b6e3df3c76d3637be3fb87fc5"
    resource "seed" do
      url "https://github.com/neuroplastio/margin/releases/download/26.10.21/margin_darwin_amd64"
      sha256 "f4094aa6ad05b34408e7d4af2b8ed0f49370a618f575c7f0a78e0ba2fd775a90"
    end
  elsif Hardware::CPU.arm?
    url "https://github.com/neuroplastio/margin/releases/download/26.10.21/margin-launcher_linux_arm64"
    sha256 "2bd279f77fa85fec76544440917af1423aa17a86e869cf32a0da9f230188bbf6"
    resource "seed" do
      url "https://github.com/neuroplastio/margin/releases/download/26.10.21/margin_linux_arm64"
      sha256 "ba592ca636599ad60b05517977247f01b92477ad0d38efd674c9534b318751f2"
    end
  else
    url "https://github.com/neuroplastio/margin/releases/download/26.10.21/margin-launcher_linux_amd64"
    sha256 "6528a5fd2a91574d6f1854807441a1bf4c6af2dd2c51bc4eef30cd20a1341a65"
    resource "seed" do
      url "https://github.com/neuroplastio/margin/releases/download/26.10.21/margin_linux_amd64"
      sha256 "31893be542f4ae94143714f458c798e6f84616920683dda175722c1318902d3a"
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
        mkdir -p "$home/builds/70970357f609c1b05b43c75d130e0eb9583a62fd"
        cp "#{opt_libexec}/margin-seed/margin" "$home/builds/70970357f609c1b05b43c75d130e0eb9583a62fd/margin"
        chmod +x "$home/builds/70970357f609c1b05b43c75d130e0eb9583a62fd/margin"
        ln -sfn "builds/70970357f609c1b05b43c75d130e0eb9583a62fd" "$home/bin"
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
