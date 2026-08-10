#!bash

set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 BRANCH_NAME WORKTREE_NAME"
  exit 1
fi

BRANCH=$1
WORKTREE=$2

git fetch origin
git worktree add -b ${BRANCH} ../${WORKTREE}

pushd ../${WORKTREE}
git checkout ${BRANCH}
git reset --hard origin/${BRANCH}
popd

git worktree list
