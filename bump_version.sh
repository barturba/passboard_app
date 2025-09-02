#!/bin/bash

# Auto-increment version script for Password Board
# Usage: ./bump_version.sh [patch|minor|major]

set -e

# Default to patch version bump
BUMP_TYPE=${1:-patch}

# Read current version from pubspec.yaml
CURRENT_VERSION=$(sed -n 's/^version: \([0-9]*\.[0-9]*\.[0-9]*\).*/\1/p' pubspec.yaml)

if [ -z "$CURRENT_VERSION" ]; then
    echo "Error: Could not find version in pubspec.yaml"
    exit 1
fi

echo "Current version: $CURRENT_VERSION"

# Parse version components
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

case $BUMP_TYPE in
    major)
        NEW_MAJOR=$((MAJOR + 1))
        NEW_VERSION="$NEW_MAJOR.0.0"
        ;;
    minor)
        NEW_MINOR=$((MINOR + 1))
        NEW_VERSION="$MAJOR.$NEW_MINOR.0"
        ;;
    patch)
        NEW_PATCH=$((PATCH + 1))
        NEW_VERSION="$MAJOR.$MINOR.$NEW_PATCH"
        ;;
    *)
        echo "Usage: $0 [patch|minor|major]"
        echo "Current version: $CURRENT_VERSION"
        exit 1
        ;;
esac

echo "New version: $NEW_VERSION"

# Update pubspec.yaml
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/version: $CURRENT_VERSION\+[0-9]*/version: $NEW_VERSION+1/" pubspec.yaml
else
    # Linux
    sed -i "s/version: $CURRENT_VERSION\+[0-9]*/version: $NEW_VERSION+1/" pubspec.yaml
fi

echo "Updated pubspec.yaml to version: $NEW_VERSION"

# Commit the change
git add pubspec.yaml
git commit -m "chore: Bump version to $NEW_VERSION"

echo "Committed version bump. Ready to push and tag as v$NEW_VERSION"
