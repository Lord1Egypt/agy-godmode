#!/bin/bash
# agy-godmode installer
# Run this script on any new WSL instance or machine to activate the full setup.
# Usage: bash install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME:-/home/$(whoami)}"

echo "[1/3] Installing GEMINI.md to $HOME_DIR..."
cp "$SCRIPT_DIR/GEMINI.md" "$HOME_DIR/GEMINI.md"
echo "      Done — $HOME_DIR/GEMINI.md"

echo "[2/3] Installing skill files to $HOME_DIR/.gemini/skills/..."
mkdir -p "$HOME_DIR/.gemini/skills"
cp "$SCRIPT_DIR/skills/"*.md "$HOME_DIR/.gemini/skills/"
echo "      Done — $(ls "$SCRIPT_DIR/skills/" | wc -l) skill files installed"

echo "[3/3] Verifying..."
echo "      GEMINI.md: $(wc -l < "$HOME_DIR/GEMINI.md") lines"
echo "      Skills:"
for f in "$HOME_DIR/.gemini/skills/"*.md; do
    echo "        - $(basename $f)"
done

echo ""
echo "Setup complete. Start agy from $HOME_DIR and instructions load automatically."
echo "Load a skill in any prompt: @~/.gemini/skills/rust.md <your task>"
