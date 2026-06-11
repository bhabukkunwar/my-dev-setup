#!/usr/bin/env bash
# Install Docker Sandboxes (sbx) — https://github.com/docker/sbx-releases
# Idempotent: exits 0 immediately if sbx is already installed.
set -euo pipefail

REPO="docker/sbx-releases"

log() { printf '%s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

# --- already installed? ------------------------------------------------------
if command -v sbx >/dev/null 2>&1; then
  log "sbx already installed: $(sbx version 2>/dev/null | head -1)"
  exit 0
fi

# --- prerequisites -----------------------------------------------------------
command -v curl >/dev/null 2>&1 || die "curl is required"

SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  command -v sudo >/dev/null 2>&1 || die "run as root or install sudo"
  SUDO="sudo"
fi

# --- pick the release asset for this machine ---------------------------------
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Linux)
    [ "$ARCH" = "x86_64" ] || die "no Linux release asset for $ARCH (x86_64 only)"

    # /etc/os-release tells us which package flavor to grab.
    ID_LIKE="" ID="" VERSION_ID=""
    [ -r /etc/os-release ] && . /etc/os-release

    case "${ID}:${ID_LIKE}" in
      ubuntu:*|debian:*|*:*debian*)
        # Nearest Ubuntu build: 26.04+, 25.x, else the 24.04 baseline.
        MAJOR="${VERSION_ID%%.*}"
        if   [ "${MAJOR:-0}" -ge 26 ]; then ASSET="DockerSandboxes-linux-amd64-ubuntu2604.deb"
        elif [ "${MAJOR:-0}" -eq 25 ]; then ASSET="DockerSandboxes-linux-amd64-ubuntu2510.deb"
        else                                ASSET="DockerSandboxes-linux-amd64-ubuntu2404.deb"
        fi
        PKG="deb"
        ;;
      rocky:*|rhel:*|centos:*|*:*rhel*|*:*fedora*)
        ASSET="DockerSandboxes-linux-amd64-rockylinux8.rpm"
        PKG="rpm"
        ;;
      *)
        die "unsupported distro '${ID:-unknown}' — grab an asset manually: https://github.com/${REPO}/releases"
        ;;
    esac

    # KVM is required at runtime (sandboxes are microVMs), not at install time.
    [ -e /dev/kvm ] || log "WARN: /dev/kvm not found — sbx will install but sandboxes won't start without KVM"
    ;;
  Darwin)
    die "on macOS, download DockerSandboxes-darwin.tar.gz from https://github.com/${REPO}/releases or use Docker Desktop"
    ;;
  *)
    die "unsupported OS: $OS"
    ;;
esac

# --- download + install ------------------------------------------------------
# Buffer the response before grepping: grep -m1 on a live pipe closes it
# early, curl exits 23, and pipefail would abort the script.
RELEASE_JSON="$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest")"
TAG="$(printf '%s' "$RELEASE_JSON" | grep -m1 '"tag_name"' | cut -d'"' -f4)"
[ -n "$TAG" ] || die "could not resolve latest release tag from GitHub"

URL="https://github.com/${REPO}/releases/download/${TAG}/${ASSET}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

log "Installing sbx ${TAG} (${ASSET})..."
curl -fsSL -o "${TMP}/${ASSET}" "$URL"

if [ "$PKG" = "deb" ]; then
  $SUDO apt-get install -y "${TMP}/${ASSET}"
else
  $SUDO dnf install -y "${TMP}/${ASSET}" 2>/dev/null || $SUDO yum install -y "${TMP}/${ASSET}"
fi

# --- verify ------------------------------------------------------------------
command -v sbx >/dev/null 2>&1 || die "install finished but sbx is not on PATH"
log "Installed: $(sbx version 2>/dev/null | head -1)"
log "Next: run 'sbx login' to authenticate."
