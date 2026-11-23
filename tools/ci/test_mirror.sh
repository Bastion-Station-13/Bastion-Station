#!/bin/bash
# Tests mirror_pr.sh, mirror_conflict_report.sh and remirror_pr.sh against real git repositories and a fake gh.
# Needs git and jq. usage: tools/ci/test_mirror.sh
# With KEEP_TMP=1 the folder with the repositories and the fake PR bodies (stub/body-<branch>) is left for a look.
# shellcheck disable=SC2016
set -u

tools=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
if [ -z "${KEEP_TMP:-}" ]; then
    trap 'rm -rf "$tmp"' EXIT
else
    echo "keeping $tmp"
fi

export HOME="$tmp/home"
export GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com
mkdir -p "$HOME" "$tmp/bin" "$tmp/stub"

failures=0
check() {
    if [ "$2" = ok ]; then
        echo "PASS $1"
    else
        echo "FAIL $1"
        failures=$((failures + 1))
    fi
}
# check_has <name> <file> <text>: the file has the text on a line of its own or inside one
check_has() {
    if grep -qF -- "$3" "$2"; then check "$1" ok; else check "$1 (no '$3' in $2)" bad; fi
}
check_lacks() {
    if grep -qF -- "$3" "$2"; then check "$1 ('$3' is in $2)" bad; else check "$1" ok; fi
}

# a fake gh that answers from $GH_STUB and writes down what is done with it
cat > "$tmp/bin/gh" <<'GH'
#!/bin/bash
case "$1" in
    api)
        cat "$GH_STUB/pr-${2##*/}.json"
        ;;
    pr)
        case "$2" in
            create)
                shift 2
                while [ $# -gt 0 ]; do
                    case "$1" in
                        --head) head=$2; shift ;;
                        --title) title=$2; shift ;;
                        --body) body=$2; shift ;;
                        --base) shift ;;
                    esac
                    shift
                done
                n=$(( $(cat "$GH_STUB/counter" 2>/dev/null || echo 100) + 1 ))
                echo "$n" > "$GH_STUB/counter"
                printf '%s' "$body" > "$GH_STUB/body-$head"
                printf '%s' "$title" > "$GH_STUB/title-$head"
                echo "$head" >> "$GH_STUB/heads"
                echo "https://github.com/example/bastion/pull/$n"
                ;;
            list)
                while [ $# -gt 0 ]; do
                    [ "$1" = --head ] && head=$2
                    shift
                done
                grep -cxF -- "$head" "$GH_STUB/heads" 2>/dev/null || true
                ;;
            close)
                echo "$3 $5" >> "$GH_STUB/closed"
                ;;
        esac
        ;;
esac
GH
chmod +x "$tmp/bin/gh"
export PATH="$tmp/bin:$PATH"
export GH_STUB="$tmp/stub"
export UPSTREAM=example/monke
export UPSTREAM_GIT_URL="file://$tmp/monke"

numbered() { seq 1 20 | sed "s/^/$1 line /"; }

# Monkestation: a base commit, then one commit per PR, all made from the base
git init -q -b main "$tmp/monke"
cd "$tmp/monke" || exit 1
mkdir code icons
numbered a > code/a.dm
numbered b > code/b.dm
numbered c > code/c.dm
numbered d > code/d.dm
numbered e > code/e.dm
numbered with-space > "code/with space.dm"
numbered pipe > "code/pi|pe.dm"
printf '\0\1\2base\n' > icons/x.bin
git add -A
git commit -q -m base
base=$(git rev-parse HEAD)

pr_commit() { # number, title, then the changes are made by the caller before this and left in the tree
    git add -A
    git commit -q -m "$2"
    sha=$(git rev-parse HEAD)
    jq -n --arg sha "$sha" --arg title "$2" --arg body $'## About\nbody of '"$1"$'\n\n:cl:\nfix: a thing\n/:cl:' \
        '{merge_commit_sha: $sha, title: $title, user: {login: "someone"}, body: $body}' > "$GH_STUB/pr-$1.json"
    git branch -q "pr$1" HEAD
    git checkout -q --detach "$base"
}
git checkout -q --detach "$base"

# 1: a clean change
sed -i '3s/.*/monke b3/' code/b.dm
pr_commit 1 "Clean change"
# 2: the same two parts of a file that Bastion changes
sed -i '3s/.*/monke 3/; 17s/.*/monke 17/' code/a.dm
pr_commit 2 "Content conflict"
# 3: changes a file that Bastion deleted
sed -i '1s/.*/monke d1/' code/d.dm
pr_commit 3 "Modify delete"
# 4: deletes a file that Bastion changed, and changes another file so that something is left to commit
git rm -q code/e.dm
sed -i '7s/.*/monke b7/' code/b.dm
pr_commit 4 "Delete modify"
# 5: adds a file that Bastion also adds
echo "monke new" > code/new.dm
pr_commit 5 "Add add"
# 6: changes a binary file that Bastion also changes, and another file
printf '\0\3monke\n' > icons/x.bin
sed -i '7s/.*/monke b7/' code/b.dm
pr_commit 6 "Binary"
# 7: renames a file that Bastion deleted
git mv code/c.dm code/c2.dm
pr_commit 7 "Rename delete"
# 8: several at once, with odd file names
sed -i '3s/.*/monke 3/' code/a.dm
sed -i '1s/.*/monke d1/' code/d.dm
printf '\0\3monke\n' > icons/x.bin
sed -i '5s/.*/monke space/' "code/with space.dm"
sed -i '5s/.*/monke pipe/' "code/pi|pe.dm"
pr_commit 8 "Many files"
# 9: a merge commit, which cherry-pick refuses without -m
git merge -q --no-ff --no-edit pr1 -m "Merge of a PR" > /dev/null
sha=$(git rev-parse HEAD)
jq -n --arg sha "$sha" '{merge_commit_sha: $sha, title: "A merge commit", user: {login: "someone"}, body: ""}' > "$GH_STUB/pr-9.json"
git branch -q pr9 HEAD
git checkout -q --detach "$base"
# 11: 105 files that Bastion also adds
mkdir lots
for i in $(seq 1 105); do echo "monke $i" > "lots/f$i.txt"; done
pr_commit 11 "Lots of files"
# 10: only a conflict that keeps Bastion's version, so nothing is left to commit
printf '\0\3monke\n' > icons/x.bin
pr_commit 10 "Nothing left"

# Bastion: master has changed the same files differently
git clone -q "$tmp/monke" "$tmp/seed"
cd "$tmp/seed" || exit 1
git checkout -q -b master "$base"
sed -i '3s/.*/bastion 3/; 17s/.*/bastion 17/' code/a.dm
git rm -q code/d.dm code/c.dm
sed -i '2s/.*/bastion e2/' code/e.dm
echo "bastion new" > code/new.dm
mkdir lots
for i in $(seq 1 105); do echo "bastion $i" > "lots/f$i.txt"; done
printf '\0\2bastion\n' > icons/x.bin
sed -i '5s/.*/bastion space/' "code/with space.dm"
sed -i '5s/.*/bastion pipe/' "code/pi|pe.dm"
git add -A
git commit -q -m "Bastion changes"
git init -q --bare "$tmp/origin.git"
git push -q "$tmp/origin.git" master
git clone -q "$tmp/origin.git" "$tmp/work"
cd "$tmp/work" || exit 1

mirror() { # arguments of mirror_pr.sh
    git checkout -q master
    git reset -q --hard origin/master
    git clean -fdq
    bash "$tools/mirror_pr.sh" "$@" > "$tmp/last.log" 2>&1
}
remirror() {
    git checkout -q master
    git reset -q --hard origin/master
    git clean -fdq
    bash "$tools/remirror_pr.sh" "$@" > "$tmp/last.log" 2>&1
}
body() { echo "$GH_STUB/body-$1"; }
pushed() { git ls-remote --heads origin "refs/heads/$1" | grep -q .; }

echo "--- a clean mirror"
mirror 1 upstream-mirror-1; status=$?
check "clean: exits 0" "$([ "$status" -eq 0 ] && echo ok)"
check "clean: branch is pushed" "$(pushed upstream-mirror-1 && echo ok)"
check_has "clean: link to the Monkestation PR" "$(body upstream-mirror-1)" "Mirrored from https://github.com/example/monke/pull/1"
check_lacks "clean: no conflict note" "$(body upstream-mirror-1)" "merge conflicts"
check_has "clean: the :cl: is credited" "$(body upstream-mirror-1)" ":cl: someone"
check_has "clean: title" "$GH_STUB/title-upstream-mirror-1" "[MIRROR] Clean change"
check "clean: the change is on the branch" "$(git show origin/upstream-mirror-1:code/b.dm | grep -q 'monke b3' && echo ok)"

echo "--- content conflict"
mirror 2 upstream-mirror-2; status=$?
b=$(body upstream-mirror-2)
check "content: exits 0 and pushes" "$([ "$status" -eq 0 ] && pushed upstream-mirror-2 && echo ok)"
check_has "content: header" "$b" "**Has merge conflicts, fix them before merging.**"
check_has "content: file and regions" "$b" '| `code/a.dm` | Both sides changed the same part of the file (2 regions, lines 3, '
check_has "content: raw git output" "$b" "CONFLICT (content): Merge conflict in code/a.dm"
check_has "content: re-mirror hint" "$b" "RE-MIRROR"
check "content: the markers are committed as before" "$([ "$(git show origin/upstream-mirror-2:code/a.dm | grep -c '^<<<<<<< ')" = 2 ] && echo ok)"

echo "--- modify/delete and delete/modify"
mirror 3 upstream-mirror-3
check_has "modify/delete" "$(body upstream-mirror-3)" '| `code/d.dm` | Deleted in Bastion, but this PR changes it. The file has this PR'"'"'s version. |'
mirror 4 upstream-mirror-4
check_has "delete/modify" "$(body upstream-mirror-4)" '| `code/e.dm` | This PR deletes it, but Bastion changed it. The file has Bastion'"'"'s version. |'

echo "--- add/add, binary and rename/delete"
mirror 5 upstream-mirror-5
check_has "add/add" "$(body upstream-mirror-5)" '| `code/new.dm` | Both sides added this file with different contents (1 region, line 1). |'
mirror 6 upstream-mirror-6
check_has "binary" "$(body upstream-mirror-6)" '| `icons/x.bin` | Binary file that both sides changed. The Bastion version was kept, pick the right one by hand. |'
mirror 7 upstream-mirror-7
check_has "rename/delete" "$(body upstream-mirror-7)" '| `code/c2.dm` | rename/delete conflict: code/c.dm renamed to code/c2.dm in'

echo "--- many files, one of each"
mirror 8 upstream-mirror-8
b=$(body upstream-mirror-8)
check_has "many: count" "$b" "The cherry-pick stopped on 5 files."
check_has "many: a.dm" "$b" '| `code/a.dm` | Both sides changed the same part of the file (1 region, line 3). |'
check_has "many: d.dm" "$b" '| `code/d.dm` | Deleted in Bastion'
check_has "many: binary" "$b" '| `icons/x.bin` | Binary file'
check_has "many: name with a space" "$b" '| `code/with space.dm` | Both sides changed the same part of the file (1 region, line 5). |'
check_has "many: name with a pipe" "$b" '| `code/pi\|pe.dm` | Both sides changed the same part of the file (1 region, line 5). |'

echo "--- a lot of files"
mirror 11 upstream-mirror-11
b=$(body upstream-mirror-11)
check_has "lots: count" "$b" "The cherry-pick stopped on 105 files."
check "lots: only 100 rows" "$([ "$(grep -c '^| `lots/' "$b")" -eq 100 ] && echo ok)"
check_has "lots: the rest is counted" "$b" "| ... | 5 more files |"

echo "--- a PR that cannot be cherry-picked is skipped"
mirror 9 upstream-mirror-9; status=$?
check "skipped: exits 3" "$([ "$status" -eq 3 ] && echo ok)"
check "skipped: nothing is pushed" "$(pushed upstream-mirror-9 || echo ok)"
check "skipped: no PR is made" "$(grep -qx upstream-mirror-9 "$GH_STUB/heads" || echo ok)"

mirror 10 upstream-mirror-10; status=$?
check "nothing left: exits 3 and says why" "$([ "$status" -eq 3 ] && grep -q 'gave nothing to commit' "$tmp/last.log" && echo ok)"
check "nothing left: nothing is pushed" "$(pushed upstream-mirror-10 || echo ok)"

echo "--- the cron loop of upstream_mirror.yml goes on after a skipped PR"
git checkout -q master && git reset -q --hard origin/master
git push -q origin --delete upstream-mirror-1
sed -i '/^upstream-mirror-1$/d' "$GH_STUB/heads"
bash -e -c 'for num in 9 1; do bash "$0/mirror_pr.sh" "$num" "upstream-mirror-$num" || [ $? -eq 3 ]; done' "$tools" > "$tmp/loop.log" 2>&1
status=$?
check "loop: ran to the end" "$([ "$status" -eq 0 ] && echo ok)"
check "loop: the PR after the skipped one is mirrored" "$(pushed upstream-mirror-1 && echo ok)"

echo "--- re-mirror"
remirror 102 upstream-mirror-2; status=$?
check "re-mirror: exits 0" "$([ "$status" -eq 0 ] && echo ok)"
check "re-mirror: new branch is pushed" "$(pushed upstream-mirror-2-2 && echo ok)"
check "re-mirror: the old branch is left alone" "$(pushed upstream-mirror-2 && echo ok)"
new=$(grep -o '[0-9]*$' "$tmp/last.log" | tail -n 1)
check "re-mirror: the old PR is closed with a pointer to the new one" "$(grep -qx "102 Replaced by #$new, made again from the current master." "$GH_STUB/closed" && echo ok)"
check_has "re-mirror: new body says what it replaces" "$(body upstream-mirror-2-2)" "Replaces #102, made again from the current master."
check_has "re-mirror: new body still has the conflicts" "$(body upstream-mirror-2-2)" '| `code/a.dm` |'
check_has "re-mirror: new title" "$GH_STUB/title-upstream-mirror-2-2" "[MIRROR] Content conflict"
remirror "$new" upstream-mirror-2-2
check "re-mirror again: the next number is used" "$(pushed upstream-mirror-2-3 && echo ok)"
remirror 150 upstream-mirror-1
check "re-mirror of a clean mirror: new branch" "$(pushed upstream-mirror-1-2 && echo ok)"
check_lacks "re-mirror of a clean mirror: no conflict note" "$(body upstream-mirror-1-2)" "merge conflicts"
check_has "re-mirror of a clean mirror: says what it replaces" "$(body upstream-mirror-1-2)" "Replaces #150"

echo "--- re-mirror refuses what it should"
closed_before=$(wc -l < "$GH_STUB/closed")
remirror 5 some-other-branch; status=$?
check "not a mirror branch: fails" "$([ "$status" -ne 0 ] && echo ok)"
remirror 9 upstream-mirror-9; status=$?
check "skipped PR: fails" "$([ "$status" -eq 3 ] && echo ok)"
check "nothing was closed by those" "$([ "$(wc -l < "$GH_STUB/closed")" -eq "$closed_before" ] && echo ok)"

echo
if [ "$failures" -eq 0 ]; then
    echo "all passed"
else
    echo "$failures failed"
    exit 1
fi
