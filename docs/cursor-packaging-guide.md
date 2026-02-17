# Cursor IDE Packaging Guide

Building the latest Cursor AI IDE with a custom Nix overlay.

## The Problem

**Nixpkgs lags behind**: The `code-cursor` package in nixpkgs is often weeks or months behind the latest Cursor release.
- Nixpkgs stable: 2.2.44 (outdated)
- Latest upstream: 2.4.37+ (nightly updates)

**Third-party flakes have issues**: External flakes like tylergets/cursor-flake update frequently but have integration problems:
- Unfree license conflicts
- callPackage argument mismatches
- Dependency on external nixpkgs instance

## The Solution: Custom Overlay

Create an overlay that builds Cursor from the latest AppImage using nixpkgs' existing `code-cursor` infrastructure as a template.

## Implementation

### 1. Overlay Structure

```nix
# overlays/cursor-latest.nix
final: prev: {
  cursor-latest = prev.code-cursor.overrideAttrs (oldAttrs: rec {
    pname = "cursor";
    version = "2.4.37";  # Update this as new versions release

    src = prev.fetchurl {
      url = "https://downloader.cursor.sh/linux/appImage/x64/${version}";
      hash = "sha256-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=";  # Update hash
    };

    # Inherit all other attributes from code-cursor
    # (appimage extraction, desktop entry, icon, etc.)
  });
}
```

### 2. Auto-Update Script

```bash
#!/usr/bin/env bash
# scripts/update-cursor.sh

# Fetch latest version from Cursor changelog
LATEST_VERSION=$(curl -s https://changelog.cursor.sh/ | \
  grep -oP 'Version \K[\d.]+' | head -1)

# Download and compute hash
URL="https://downloader.cursor.sh/linux/appImage/x64/${LATEST_VERSION}"
HASH=$(nix-prefetch-url "$URL")
SHA256=$(nix hash convert --hash-algo sha256 "$HASH")

# Update overlay
sed -i "s/version = \".*\"/version = \"${LATEST_VERSION}\"/" \
  overlays/cursor-latest.nix
sed -i "s/hash = \".*\"/hash = \"${SHA256}\"/" \
  overlays/cursor-latest.nix

echo "Updated Cursor to ${LATEST_VERSION}"
```

### 3. Integration

```nix
# flake.nix
{
  outputs = {...}: {
    overlays = {
      cursor-latest = import ./overlays/cursor-latest.nix;
    };

    nixosConfigurations.alice = {
      nixpkgs.overlays = [
        self.overlays.cursor-latest
      ];
    };
  };
}
```

```nix
# home-manager/packages/cursor.nix
{ pkgs, ... }:
{
  home.packages = [
    pkgs.cursor-latest  # Uses our overlay
  ];
}
```

## Alternative: Direct AppImage

For maximum simplicity, skip the overlay and use appimage-run:

```nix
let
  cursorAppImage = pkgs.fetchurl {
    url = "https://downloader.cursor.sh/linux/appImage/x64/2.4.37";
    hash = "sha256-...";
  };
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "cursor" ''
      exec ${pkgs.appimage-run}/bin/appimage-run ${cursorAppImage} "$@"
    '')
  ];
}
```

**Pros**: Simple, always latest version
**Cons**: No desktop entry, slower startup (AppImage extraction)

## Why Not Use Third-Party Flakes?

**Dependency conflicts**: External flakes use their own nixpkgs instance
- Different unfree settings
- Different system configuration
- callPackage argument mismatches

**Maintenance burden**: Trusting external maintainers
- What if the repo is abandoned?
- What if breaking changes are introduced?

**Our overlay approach**:
- ✅ Uses your nixpkgs configuration
- ✅ Inherits unfree settings
- ✅ Full control over versioning
- ✅ Easy to update (just version + hash)
- ✅ Can be automated with update script

## Update Workflow

### Manual Update
1. Check https://changelog.cursor.sh/ for latest version
2. Update `version` in overlay
3. Run `nix build .#cursor-latest` (will fail with hash mismatch)
4. Copy correct hash from error message
5. Update `hash` in overlay
6. Rebuild: `nixos-rebuild switch`

### Automated Update
```bash
# Add to cron or systemd timer
./scripts/update-cursor.sh
git commit -am "chore: update Cursor to $(grep version overlays/cursor-latest.nix)"
nixos-rebuild switch
```

## Comparison

| Method | Version | Update Frequency | Issues |
|--------|---------|------------------|--------|
| nixpkgs stable | 2.2.44 | Monthly | Very outdated |
| nixpkgs unstable | ~2.4.x | Weekly | Slightly behind |
| tylergets/cursor-flake | 2.4.37 | Nightly | callPackage errors, unfree conflicts |
| omarcresp/cursor-flake | 2.4.30 | 3x daily | Abandoned?, outdated |
| **Custom overlay** | **Latest** | **On-demand/automated** | **None** |

## Recommended Approach

**For now**: Use nixpkgs `code-cursor-fhs` (version 2.2.44)
- Stable, tested, works out of the box
- Good enough for most use cases
- Cursor's AI features work regardless of version

**Long-term**: Create custom overlay
- When you need bleeding-edge features
- When nixpkgs lags more than 1 month behind
- When specific bugs are fixed in newer versions

**Avoid**: Third-party flakes
- Integration issues outweigh benefits
- Better to maintain your own simple overlay

## Implementation Status

- [ ] Create `overlays/cursor-latest.nix`
- [ ] Add overlay to flake.nix
- [ ] Create update script
- [ ] Test build
- [ ] Document in CLAUDE.md

Current: Using nixpkgs `code-cursor-fhs` (2.2.44) until overlay is ready.
