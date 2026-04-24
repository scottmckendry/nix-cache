update-readme:
    #!/usr/bin/env bash
    set -euo pipefail

    packages=$(nix flake show --json \
      | jq -r '.packages."x86_64-linux" | keys[]')

    table="| Package | Source |\n| --- | --- |"
    while IFS= read -r pkg; do
      url=$(nix flake metadata --json \
        | jq -r --arg pkg "$pkg" '
          .locks.nodes |
          to_entries[] |
          select(.key == $pkg) |
          .value.original |
          if .type == "github" then
            "https://github.com/\(.owner)/\(.repo)" +
            (if .ref then "/tree/\(.ref)" elif .rev then "/tree/\(.rev)" else "" end)
          else .url // "–"
          end
        ' 2>/dev/null || echo "–")
      table="$table\n| \`$pkg\` | $url |"
    done <<< "$packages"

    marker_start="<!-- packages-start -->"
    marker_end="<!-- packages-end -->"

    printf '%b\n' "$marker_start" "$table" "$marker_end" > /tmp/pkg-block.txt

    if grep -q "$marker_start" README.md; then
      sed -i "/<!-- packages-start -->/,/<!-- packages-end -->/d" README.md
      line=$(grep -n "## Packages" README.md | cut -d: -f1)
      sed -i "${line}r /tmp/pkg-block.txt" README.md
    else
      printf "\n## Packages\n\n" >> README.md
      cat /tmp/pkg-block.txt >> README.md
    fi

    echo "README updated."
