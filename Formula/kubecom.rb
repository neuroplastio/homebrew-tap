# Rendered by kubecom's release workflow from packaging/homebrew/kubecom.rb in
# github.com/neuroplastio/kubecom; change it there.
#
# A launcher plus a seed build (D295/D299): the formula installs the thin
# launcher and a complete kubecom binary. On first run the wrapper seeds the
# launcher's home (~/.local/kubecom) from that binary, so kubecom works with no
# network and survives a channel outage; `kubecom update` then updates the copy
# in the home, outside the package manager.
class Kubecom < Formula
  desc "A fast, keyboard-driven, zero-deploy Kubernetes TUI"
  homepage "https://github.com/neuroplastio/kubecom"
  version "26.10.07"
  license "Apache-2.0"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/neuroplastio/kubecom/releases/download/26.10.07/kubecom-launcher_darwin_arm64"
    sha256 "be5a7f43b3fd49670f42b2b54861e9e8dffa7dc722e3ac324ed182691f1bdd97"
    resource "seed" do
      url "https://github.com/neuroplastio/kubecom/releases/download/26.10.07/kubecom_darwin_arm64"
      sha256 "01cb3db6991bac3b5caa661c33bb3ef0d4d71dd08b78ab6fdb165282d2c3cb34"
    end
  elsif OS.mac?
    url "https://github.com/neuroplastio/kubecom/releases/download/26.10.07/kubecom-launcher_darwin_amd64"
    sha256 "b5cb798fd94de5110ca630b59a8bebe45730fc34d8ac1f50aa755ac5ad8759ce"
    resource "seed" do
      url "https://github.com/neuroplastio/kubecom/releases/download/26.10.07/kubecom_darwin_amd64"
      sha256 "c6799c1c88d759dec791ad9e4454bf8262c174c49bfea71e449fe474dbfe2443"
    end
  elsif Hardware::CPU.arm?
    url "https://github.com/neuroplastio/kubecom/releases/download/26.10.07/kubecom-launcher_linux_arm64"
    sha256 "59f3f87f717718ddb0f1b938efe422a9ca1771af5c9d1597c4f093287164510c"
    resource "seed" do
      url "https://github.com/neuroplastio/kubecom/releases/download/26.10.07/kubecom_linux_arm64"
      sha256 "d16e3e25ae341c012e04a3261c55ef959a4ec7a2374518e828652c50d75fc4ba"
    end
  else
    url "https://github.com/neuroplastio/kubecom/releases/download/26.10.07/kubecom-launcher_linux_amd64"
    sha256 "e6ebfab74bb7b0a46f4b1192155fa23d22414d8b92110f0781a4787f64c735c5"
    resource "seed" do
      url "https://github.com/neuroplastio/kubecom/releases/download/26.10.07/kubecom_linux_amd64"
      sha256 "761b4935da56c46f591419d32434265aeb707954b86e4e7c25bf8274be0f12de"
    end
  end

  def install
    libexec.install Dir["kubecom-launcher_*"].first => "kubecom-launcher"
    resource("seed").stage do
      (libexec/"kubecom-seed").install Dir["kubecom_*"].first => "kubecom"
    end
    # The release assets are bare binaries, which brew downloads without the
    # executable bit.
    chmod 0755, [libexec/"kubecom-launcher", libexec/"kubecom-seed/kubecom"]

    # bin/kubecom seeds the launcher's home from the packaged build on first
    # run, then hands over. The home is enlaunch's default (~/.local/kubecom);
    # an already-updated install is left alone.
    (bin/"kubecom").write <<~SH
      #!/bin/sh
      home="$HOME/.local/kubecom"
      if [ ! -e "$home/bin/kubecom" ]; then
        mkdir -p "$home/builds/ccabdf49722002803df4394772197df050c4acfb"
        cp "#{opt_libexec}/kubecom-seed/kubecom" "$home/builds/ccabdf49722002803df4394772197df050c4acfb/kubecom"
        chmod +x "$home/builds/ccabdf49722002803df4394772197df050c4acfb/kubecom"
        ln -sfn "builds/ccabdf49722002803df4394772197df050c4acfb" "$home/bin"
      fi
      exec "#{opt_libexec}/kubecom-launcher" "$@"
    SH
    chmod 0755, bin/"kubecom"
  end

  test do
    ENV["HOME"] = testpath.to_s
    assert_match "kubecom", shell_output("#{bin}/kubecom version")
  end
end
