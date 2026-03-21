#!/bin/bash
# Resonance — Design for the Exhale
# Project setup script
#
# This script generates the Xcode project using XcodeGen.
# Install XcodeGen: brew install xcodegen

set -e

echo "✦ Resonance — Setting up Xcode project..."

# Check for XcodeGen
if ! command -v xcodegen &> /dev/null; then
    echo ""
    echo "XcodeGen is required. Install it with:"
    echo "  brew install xcodegen"
    echo ""
    echo "Then run this script again."
    exit 1
fi

# Generate project
cd "$(dirname "$0")"
xcodegen generate

echo ""
echo "✦ Resonance.xcodeproj generated successfully."
echo ""
echo "  Open in Xcode:"
echo "    open Resonance.xcodeproj"
echo ""
echo "  Available targets:"
echo "    • Resonance-iOS      (iPhone & iPad)"
echo "    • Resonance-macOS    (Mac)"
echo "    • Resonance-watchOS  (Apple Watch)"
echo "    • Resonance-visionOS (Vision Pro)"
echo ""
echo "  Note: Install Cormorant Garamond font for the full"
echo "  typographic experience (or use system serif as fallback)."
echo ""
