#!/bin/bash
# push.sh - Git add, commit, and push with auto commit messages

DATE=$(date +%Y-%m-%d)

if [ -z "$1" ]; then
    COMMIT_MSG="fix(AUTO-COMMIT): $DATE"
else
    COMMIT_MSG="$1"
fi

# Add all changes
git add .

# Commit
git commit -m "$COMMIT_MSG"

# Get current branch
BRANCH=$(git branch --show-current)

# Push
git push origin "$BRANCH"

echo "✅ Changes pushed to $BRANCH with commit message:"
echo "   $COMMIT_MSG"
