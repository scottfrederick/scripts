#!/usr/bin/env bash
#
# rollback-release.sh — delete a NES release and its backing tag.
#
# Usage: rollback-release.sh [-y|--yes] <project-id> <nes-version>
#
# NES version format:  <semver>-<project-id>-<semver>
#   e.g.  1.2.3-spring-framework-5.3.39
# Tag / release name is derived from the SECOND semver:
#   nes-v<second-semver>     e.g.  nes-v5.3.39
# Repo:  neverendingsupport/<project-id>

set -euo pipefail

ORG="neverendingsupport"

NES_JAVA_TOOLS="java -jar ${HOME}/Projects/tools/nes-java-tools/cli/build/libs/cli-1.0.0-SNAPSHOT.jar"

die() { echo "error: $*" >&2; exit 1; }

usage() {
  echo "usage: $(basename "$0") [-y|--yes] <project-id> <nes-version>"
  echo "deletes the NES release nes-v<second-semver> and its tag from ${ORG}/<project-id>"
}

# --- parse flags + positional args ------------------------------------------
assume_yes=false
args=()
for a in "$@"; do
  case "$a" in
    -y|--yes)  assume_yes=true ;;
    -h|--help) usage; exit 0 ;;
    -*)        die "unknown flag: $a" ;;
    *)         args+=("$a") ;;
  esac
done
set -- "${args[@]}"

[[ $# -eq 2 ]] || { usage >&2; exit 1; }

project_id="$1"
nes_version="$2"

[[ -n "$project_id"  ]] || die "project-id must not be empty"
[[ -n "$nes_version" ]] || die "nes-version must not be empty"

# --- derive the tag from the second semver ----------------------------------
# The project-id is the anchor between the two semvers; splitting on it stays
# correct even when a semver carries a hyphenated pre-release (e.g. -rc.1).
anchor="-${project_id}-"
[[ "$nes_version" == *"$anchor"* ]] \
  || die "nes-version '$nes_version' has no '${anchor}' segment; project-id and version are inconsistent"

second_semver="${nes_version##*${anchor}}"
[[ -n "$second_semver" ]] || die "could not derive second semver from '$nes_version'"

tag="nes-v${second_semver}"
repo="${ORG}/${project_id}"

# --- delete -----------------------------------------------------------------
command -v gh >/dev/null 2>&1 || die "gh CLI not found on PATH"

echo "Repo:    $repo"
echo "Version: $nes_version"
echo "Tag:     $tag"
echo

gh_flags=(--repo "$repo" --cleanup-tag)
$assume_yes && gh_flags+=(--yes)

gh release delete "$tag" "${gh_flags[@]}"

echo "Deleted release and tag '$tag' from $repo."

${NES_JAVA_TOOLS} gh-delete-package-version --repoName ${project_id} --version ${nes_version} --dryRun false

echo "Deleted version '$nes_version' from GitHub packages in $repo."

