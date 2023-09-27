#!bash

set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 BRANCH_NAME"
  exit 1
fi

BRANCH=$1

pushd ~/Projects/spring/spring-boot
# git pull upstream
git worktree add -b ${BRANCH} ../spring-boot-${BRANCH}

pushd ../spring-boot-${BRANCH}
git fetch upstream
git checkout ${BRANCH}
git reset --hard upstream/${BRANCH}
git push --set-upstream origin ${BRANCH}

mkdir .git-hooks
pushd .git-hooks
ln -s ../git/hooks/forward-merge commit-msg
ln -s ../git/hooks/prepare-forward-merge prepare-commit-msg
git config core.hooksPath ./.git-hooks

popd
popd

git worktree list
