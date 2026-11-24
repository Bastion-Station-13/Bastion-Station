#!/bin/bash
# Makes a fresh mirror of the Monkestation PR behind a mirror PR: a new branch off the current master with the PR
# cherry-picked again, a new mirror PR from it, and the old mirror PR closed and its branch deleted.
# Run it from a checkout of master. Needs UPSTREAM and GH_TOKEN, like mirror_pr.sh.
# usage: remirror_pr.sh <mirror PR number> <its branch>
set -eu

old_pr=$1
old_branch=$2

if [[ ! $old_branch =~ ^upstream-mirror-([0-9]+)(-[0-9]+)?$ ]]; then
    echo "$old_branch is not a mirror branch"
    exit 1
fi
num=${BASH_REMATCH[1]}

# upstream-mirror-123 is the first mirror of PR 123, the next ones are upstream-mirror-123-2, -3 and so on
n=2
while [ -n "$(git ls-remote --heads origin "refs/heads/upstream-mirror-$num-$n")" ] ||
    [ "$(gh pr list --state all --head "upstream-mirror-$num-$n" --json number --jq length)" != 0 ]; do
    n=$((n + 1))
done

bash "$(dirname "$0")/mirror_pr.sh" "$num" "upstream-mirror-$num-$n" "$old_pr"

git push origin --delete "$old_branch" || echo "Could not delete $old_branch"
