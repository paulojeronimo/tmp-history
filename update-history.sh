#!/usr/bin/env bash
set -o pipefail

[ "$1" ] || { echo A date is required!; exit 1; }

history_dir=${history_repo:-../tmp-history}
changes_file="$history_dir"/changes.txt
cd "$(dirname "$0")"

declare -A history_files
cd "$history_dir"
for f in $(find . -type f ! \( -name $(basename "$changes_file") -o -path './.git/*' \))
do
  history_files[$f]=1
done
cd "$OLDPWD"

filter() {
  while IFS= read -r f
  do
    [ "${history_files[$f]}" ] || [ "$f" = './index.html' ] || echo $f
  done
}

for f in ${!history_files[@]}; do cp "$f" "$history_dir"/; done

echo -e "Update date/time: $1\n\nChanges:" > "$changes_file"
git status --short | grep -v index.html >> "$changes_file"
echo -e "\nTemporary files hashes:" >> "$changes_file"
find . -type f ! -path */.git/* | filter | sort | xargs sha256sum >> "$changes_file"

cd "$history_dir"
git add .
git commit -m "Updated tmp-history at $1"
git push
