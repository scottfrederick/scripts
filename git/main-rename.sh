#!/usr/bin/env bash

set -euo pipefail

remote_has() {
	git ls-remote --exit-code --heads origin "$1" >/dev/null
}

if ! remote_has main; then
	if ! remote_has master; then
		echo "origin has neither 'main' nor 'master'" >&2
		exit 1
	fi
	repo=$(gh repo view "$(git remote get-url origin)" --json nameWithOwner -q .nameWithOwner)
	echo "Renaming master to main on $repo"
	gh api -X POST "repos/$repo/branches/master/rename" -f new_name=main >/dev/null
fi

if git show-ref --verify --quiet refs/heads/master; then
	git branch -m master main
fi

git fetch --prune origin
git branch -u origin/main main
git remote set-head origin main
