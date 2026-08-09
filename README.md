# neuroplastio homebrew tap

Homebrew tap for the [neuroplastio](https://github.com/neuroplastio) org's tools.

`brew tap neuroplastio/tap`

| Tool | Cask | Status |
| ---- | ---- | ------ |
| [kubecom](https://github.com/neuroplastio/kubecom) | `kubecom` | wired — the cask is written here by goreleaser from the first tagged release (see below) |

## Why the tap is empty right now

`kubecom` ships as a Homebrew **cask**, and the cask file is written by
goreleaser at release time — it carries the version, the download URL and the
sha256 of a real release artifact, so it cannot exist until the first
`v1.x.x` tag is pushed. Until then:

```bash
brew tap neuroplastio/tap   # works now
brew install --cask kubecom      # "no cask found" until the first tagged release
```

macOS only: Homebrew does not install casks on Linux. Linux users install
kubecom from the release tarball, the AUR package (`kubecom-bin`) or `go install`.

This tap deliberately replaces the 2020 `AnatolyRugalev/homebrew-kubecom` tap,
which is abandoned with no redirect and keeps serving the 2020 formula to anyone
still on the old address.
