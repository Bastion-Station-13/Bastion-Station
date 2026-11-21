#!/bin/bash
# Run in a checkout where a git cherry-pick just stopped on conflicts, before anything is staged.
# Prints the note for the mirror PR body: which files conflict and what kind of conflict each one is.
# Prints nothing if no file is unmerged.
# usage: mirror_conflict_report.sh <file with the output of the cherry-pick>
set -u

output_file=$1

mapfile -d '' -t files < <(git diff --name-only --diff-filter=U -z)
if [ "${#files[@]}" -eq 0 ]; then
    exit 0
fi

# the line git printed about a file, for example "CONFLICT (content): Merge conflict in code/a.dm"
find_message() {
    local file=$1 message
    message=$(grep -F -x -m1 -e "CONFLICT (content): Merge conflict in $file" -e "CONFLICT (add/add): Merge conflict in $file" -- "$output_file")
    [ -z "$message" ] && message=$(grep -F -m1 -e "CONFLICT (modify/delete): $file deleted in" -- "$output_file")
    [ -z "$message" ] && message=$(grep -F -- "$file" "$output_file" | grep -m1 '^CONFLICT ')
    echo "$message"
}

# how many <<<<<<< markers a file has and where, for example " (2 regions, lines 5, 9)"
regions() {
    local count lines
    count=$(grep -c '^<<<<<<< ' -- "$1")
    [ "$count" -eq 0 ] && return
    lines=$(grep -n '^<<<<<<< ' -- "$1" | cut -d: -f1 | head -n 6 | paste -sd, - | sed 's/,/, /g')
    if [ "$count" -eq 1 ]; then
        echo " (1 region, line $lines)"
    else
        echo " ($count regions, lines $lines)"
    fi
}

describe() {
    local file=$1 message kind marked=""
    message=$(find_message "$file")
    kind=$(sed -nE 's/^CONFLICT \(([^)]*)\).*/\1/p' <<< "$message")

    if [ -s "$file" ] && ! grep -qI . -- "$file"; then
        echo "Binary file that both sides changed. The Bastion version was kept, pick the right one by hand."
        return
    fi
    [ -e "$file" ] && marked=$(regions "$file")

    case "$kind" in
        content)
            echo "Both sides changed the same part of the file${marked}."
            ;;
        add/add)
            echo "Both sides added this file with different contents${marked}."
            ;;
        modify/delete)
            if grep -q 'deleted in HEAD' <<< "$message"; then
                echo "Deleted in Bastion, but this PR changes it. The file has this PR's version."
            else
                echo "This PR deletes it, but Bastion changed it. The file has Bastion's version."
            fi
            ;;
        '')
            # git did not name it, so work it out from which sides have the file
            case "$(git ls-files -u -- "$file" | awk '{print $3}' | sort -u | tr -d '\n')" in
                23) echo "Both sides added this file with different contents${marked}." ;;
                13) echo "Deleted in Bastion, but this PR changes it." ;;
                12) echo "This PR deletes it, but Bastion changed it." ;;
                *) echo "Merge conflict${marked}." ;;
            esac
            ;;
        *)
            echo "${kind} conflict: ${message#*: }"
            ;;
    esac
}

echo "**Has merge conflicts, fix them before merging.**"
echo
if [ "${#files[@]}" -eq 1 ]; then
    echo "The cherry-pick stopped on 1 file. The bot committed the result as it is, so the PR will not compile until the file is fixed."
else
    echo "The cherry-pick stopped on ${#files[@]} files. The bot committed the result as it is, so the PR will not compile until they are fixed."
fi
echo
echo "Files with a content conflict have \`<<<<<<<\` markers in them."
echo
echo "| File | Conflict |"
echo "| --- | --- |"
# a PR body can only be so long
max_rows=100
shown=0
for file in "${files[@]}"; do
    if [ "$shown" -ge "$max_rows" ]; then
        echo "| ... | $((${#files[@]} - max_rows)) more files |"
        break
    fi
    echo "| \`${file//|/\\|}\` | $(describe "$file") |"
    shown=$((shown + 1))
done
echo
echo "If master has changed since this PR was opened, add the \`RE-MIRROR\` label to get a fresh copy made from the current master."
echo
echo "<details><summary>What git said</summary>"
echo
echo '```'
grep -E '^(CONFLICT|warning:)' "$output_file" | cut -c1-300 | head -n 40
echo '```'
echo
echo "</details>"
