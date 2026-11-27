#!/bin/bash
# Opens a PR that mirrors one merged Monkestation PR: cherry-picks its merge commit onto a fresh branch off master,
# pushes the branch and opens the PR. A cherry-pick that conflicts is committed as it is, and the PR body lists the
# conflicting files and what kind of conflict each one is.
# Run it from a checkout of master. Needs UPSTREAM (the Monkestation repo as owner/name) and GH_TOKEN in the environment.
# usage: mirror_pr.sh <Monkestation PR number> <branch> [<number of the mirror PR this one replaces>]
# If a PR is given it is closed once the new one is open. Exits with 3 if the PR could not be mirrored.
set -u

num=$1
branch=$2
replaces=${3:-}

tools=$(dirname "$0")
upstream_url=${UPSTREAM_GIT_URL:-https://github.com/$UPSTREAM.git}
base=${MIRROR_BASE:-origin/master}

pr=$(gh api "repos/$UPSTREAM/pulls/$num") || exit 1
sha=$(jq -r .merge_commit_sha <<< "$pr")
title=$(jq -r .title <<< "$pr")
author=$(jq -r .user.login <<< "$pr")
# Credit the upstream author in the changelog if the :cl: has no name
body=$(jq -r '.body // ""' <<< "$pr" | sed -E "s/^:cl:\s*\r?$/:cl: $author/")

git fetch -q --depth 2 "$upstream_url" "$sha" || exit 1
git checkout -q -B "$branch" "$base" || exit 1

note=""
output=$(git cherry-pick -x "$sha" 2>&1)
status=$?
printf '%s\n' "$output"
if [ "$status" -ne 0 ]; then
    output_file=$(mktemp)
    printf '%s\n' "$output" > "$output_file"
    note=$(bash "$tools/mirror_conflict_report.sh" "$output_file")
    rm -f "$output_file"

    git add -A
    git commit -q --no-edit || { git cherry-pick --abort; echo "Skipped PR $num, the cherry-pick gave nothing to commit."; exit 3; }
    note=${note:-"**Has merge conflicts, fix them before merging.**"}
fi

if [ -n "$replaces" ]; then
    note="Replaces #$replaces, made again from the current master.
$note"
fi

git push -q -f origin "$branch" || exit 1
url=$(gh pr create --base master --head "$branch" --title "[MIRROR] $title" \
    --body "Mirrored from https://github.com/$UPSTREAM/pull/$num
$note

$body") || exit 1
echo "$url"

if [ -n "$replaces" ]; then
    gh pr close "$replaces" --comment "Replaced by #${url##*/}, made again from the current master."
fi
