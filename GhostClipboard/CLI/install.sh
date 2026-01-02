#!/bin/bash
#
# Install GhostClipboard CLI
#

set -e

echo "👻 Installing GhostClipboard CLI..."

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Compile the Swift binary
echo "📦 Compiling Swift binary..."
swiftc -O "$DIR/main.swift" -o "$DIR/ghostclip-bin"

# Make the runner executable
chmod +x "$DIR/ghostclip"

# Create symlink in /usr/local/bin
INSTALL_PATH="/usr/local/bin/ghostclip"

if [ -w "/usr/local/bin" ]; then
    ln -sf "$DIR/ghostclip" "$INSTALL_PATH"
    echo "✅ Installed to $INSTALL_PATH"
else
    echo "⚠️  Need sudo to install to /usr/local/bin"
    sudo ln -sf "$DIR/ghostclip" "$INSTALL_PATH"
    echo "✅ Installed to $INSTALL_PATH"
fi

echo ""
echo "🎉 Installation complete!"
echo ""
echo "Usage:"
echo "  ghostclip           # Run interactive mode"
echo "  ghostclip --list    # List all items"
echo "  ghostclip --last    # Copy last item"
echo "  ghostclip --help    # Show help"
echo ""
echo "👻 Happy haunting!"
