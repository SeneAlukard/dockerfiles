#!/usr/bin/env bash
set -euo pipefail

# ——— Detect display server ———
# Prefer XDG_SESSION_TYPE, but fall back to env vars
if [[ "${XDG_SESSION_TYPE:-}" == "wayland" ]] || [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    DISPLAY_MODE="wayland"
elif [[ "${XDG_SESSION_TYPE:-}" == "x11" ]] || [[ -n "${DISPLAY:-}" ]]; then
    DISPLAY_MODE="x11"
else
    echo "⚠️  Could not detect display server; defaulting to X11"
    DISPLAY_MODE="x11"
fi

# ——— Configurable vars ———
IMAGE="arch-dotfiles-test"
DOTFILES_DIR="../../dotfiles"
USER_IN_CONTAINER="dev"   # matches useradd in your Dockerfile

# ——— Prepare Docker flags ———
DOCKER_FLAGS=(
  -it --rm
  -v "$DOTFILES_DIR":/home/$USER_IN_CONTAINER/dotfiles
)

if [[ "$DISPLAY_MODE" == "x11" ]]; then
  echo "🔌 Using X11 — granting socket access"
  # allow root (docker) to talk to your X server
  xhost +local:root >/dev/null

  DOCKER_FLAGS+=(
    -e DISPLAY="$DISPLAY"
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro
    # if you lock down Xauthority:
    -v "$HOME/.Xauthority":/home/$USER_IN_CONTAINER/.Xauthority:ro
  )
else
  echo "🔌 Using Wayland — mounting socket"
  XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
  WAYLAND_SOCK="${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY:-wayland-0}"

  DOCKER_FLAGS+=(
    -e XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR"
    -v "$WAYLAND_SOCK":"$WAYLAND_SOCK":ro
  )
fi

# ——— Launch! ———
echo "🚀 Launching container $IMAGE"
docker run "${DOCKER_FLAGS[@]}" "$IMAGE" zsh

# ——— Cleanup X11 access ———
if [[ "$DISPLAY_MODE" == "x11" ]]; then
  echo "🧹 Revoking X11 access"
  xhost -local:root >/dev/null
fi

