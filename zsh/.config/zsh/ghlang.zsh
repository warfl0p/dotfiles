# GitHub-style language breakdown: stacked bar + colored legend (proportional
# widths, linguist colors). Pass any tokei args, e.g. `ghlang src/`.
ghlang() {
  tokei -o json "$@" \
    | jq -r '
        to_entries
        | map(select(.key != "Total" and .key != "Markdown"))
        | map({key: (if .key == "BASH" then "Shell" else .key end), code: .value.code})
        | group_by(.key)
        | map({key: .[0].key, code: (map(.code) | add)})[]
        | "\(.key)\t\(.code)"' \
    | sort -t$'\t' -k2 -rn \
    | awk '
    BEGIN {
      FS = "\t"
      width = 42
      # GitHub linguist colors as "R;G;B"
      col["Go"]="0;173;216"; col["Python"]="53;114;165"; col["QML"]="68;165;28"
      col["JavaScript"]="241;224;90"; col["TypeScript"]="49;120;198"; col["TSX"]="49;120;198"
      col["HTML"]="227;76;38"; col["CSS"]="86;61;124"; col["SCSS"]="198;83;140"; col["Sass"]="165;59;99"
      col["Shell"]="137;224;81"; col["Bash"]="137;224;81"; col["Zsh"]="137;224;81"; col["Fish"]="137;224;81"
      col["C"]="85;85;85"; col["C Header"]="85;85;85"; col["C++"]="243;75;125"; col["C++ Header"]="243;75;125"
      col["Rust"]="222;165;132"; col["Java"]="176;114;25"; col["Kotlin"]="169;123;255"
      col["Ruby"]="112;21;22"; col["Lua"]="0;0;128"; col["Vim Script"]="25;159;75"; col["Vim script"]="25;159;75"
      col["YAML"]="203;23;30"; col["JSON"]="64;64;64"; col["TOML"]="156;66;33"; col["INI"]="215;215;215"
      col["Dockerfile"]="56;77;84"; col["Makefile"]="66;120;25"; col["CMake"]="218;218;218"
      col["Nix"]="126;126;255"; col["Swift"]="240;81;56"; col["PHP"]="79;93;149"; col["Zig"]="236;145;92"
      col["Perl"]="2;152;195"; col["Haskell"]="94;80;134"; col["Elixir"]="110;74;126"; col["Erlang"]="184;57;152"
      col["Go Template"]="0;173;216"; col["Emacs Lisp"]="192;101;219"; col["Clojure"]="219;185;54"
      col["Scala"]="194;45;54"; col["Dart"]="0;180;175"; col["R"]="25;140;190"; col["Julia"]="162;112;186"
      col["SQL"]="227;134;18"; col["GraphQL"]="225;0;152"; col["Svelte"]="255;62;0"; col["Vue"]="65;184;131"
      col["XML"]="0;96;0"; col["Batch"]="192;192;192"; col["PowerShell"]="1;36;86"; col["Assembly"]="110;125;145"
      defcol="110;118;129"
    }
    { name[NR]=$1; code[NR]=$2; sum+=$2 }
    END {
      if (sum == 0) { print "No code found."; exit }
      maxlen = 0
      for (i=1;i<=NR;i++) if (length(name[i])>maxlen) maxlen=length(name[i])
      # segment widths with largest-remainder rounding so they sum to `width`
      used = 0
      for (i=1;i<=NR;i++) {
        raw = code[i]/sum*width
        w[i] = int(raw); frac[i] = raw - w[i]; used += w[i]
      }
      # largest-remainder: hand out the leftover cells to the biggest fractions.
      # This is monotonic, so a bigger percentage never gets a smaller segment.
      # Sub-cell languages get no bar segment (they still show in the legend).
      leftover = width - used
      for (k=0;k<leftover;k++) {
        best=-1; bf=-1
        for (i=1;i<=NR;i++) if (frac[i]>bf) { bf=frac[i]; best=i }
        if (best<0) break
        w[best]++; frac[best]=-1
      }

      bar = ""
      for (i=1;i<=NR;i++) {
        if (w[i]<=0) continue
        c = (name[i] in col) ? col[name[i]] : defcol
        seg = ""
        for (j=0;j<w[i];j++) seg = seg "\xe2\x96\x88"   # full block
        bar = bar "\033[38;2;" c "m" seg "\033[0m"
      }
      printf "\n  %s\n\n", bar

      for (i=1;i<=NR;i++) {
        if (code[i]<=0) continue
        c = (name[i] in col) ? col[name[i]] : defcol
        printf "  \033[38;2;%sm\xe2\x97\x8f\033[0m %-*s \033[2m%5.1f%%\033[0m\n", \
               c, maxlen, name[i], code[i]/sum*100
      }
      print ""
    }'
}
