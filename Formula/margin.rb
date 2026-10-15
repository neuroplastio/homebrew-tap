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
    url "https://github.com/neuroplastio/margin/releases/download/26.10.03/margin-launcher_darwin_arm64"
    sha256 "a838eb037c9f2b475a215450786059bad0ccbc03f299503025fda12ff625f64d"
    resource "seed" do
      url "https://github.com/neuroplastio/margin/releases/download/26.10.03/margin_darwin_arm64"
      sha256 "aee09cf2cdbae34ee8f0456ff94925d85601710c4505128a368575f9a515cd2b"
    end
  elsif OS.mac?
    url "https://github.com/neuroplastio/margin/releases/download/26.10.03/margin-launcher_darwin_amd64"
    sha256 "944f1d14ee08a804667484c2eac09f0d06c65937ea49c65f8d4adab9a9a574cd"
    resource "seed" do
      url "https://github.com/neuroplastio/margin/releases/download/26.10.03/margin_darwin_amd64"
      sha256 "233e4f9e700b7652fa751fac193f139cf0d08270bf33406d106bda1129c475c7"
    end
  elsif Hardware::CPU.arm?
    url "https://github.com/neuroplastio/margin/releases/download/26.10.03/margin-launcher_linux_arm64"
    sha256 "f57c1483648ac05a1ec1e63afaa86afed19cd33bf84ebf291c81c84679e745ef"
    resource "seed" do
      url "https://github.com/neuroplastio/margin/releases/download/26.10.03/margin_linux_arm64"
      sha256 "518253268d26ed052c639e2bc2dfd0a12835613e1c615ae0f532da9bb72b4c13"
    end
  else
    url "https://github.com/neuroplastio/margin/releases/download/26.10.03/margin-launcher_linux_amd64"
    sha256 "d63a8d0c7fc1bd1a43978462ff92034389f280ddbf93a5897f79ee91e116367e"
    resource "seed" do
      url "https://github.com/neuroplastio/margin/releases/download/26.10.03/margin_linux_amd64"
      sha256 "44ea7919c5797d09606ee989c6e8577f0893adadff286149b1bd6d6f8c48db00"
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
        mkdir -p "$home/builds/75a774be93a687d63bdead2e961ab89a12449919"
        cp "#{opt_libexec}/margin-seed/margin" "$home/builds/75a774be93a687d63bdead2e961ab89a12449919/margin"
        chmod +x "$home/builds/75a774be93a687d63bdead2e961ab89a12449919/margin"
        ln -sfn "builds/75a774be93a687d63bdead2e961ab89a12449919" "$home/bin"
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
