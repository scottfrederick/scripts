#!/usr/bin/env bash
#
# Read a KEY=VALUE file and add each entry as a concealed field on a 1Password item.
# Keys are lower-cased. Existing fields with the same name are overwritten.
#
# By default the KEY=VALUE file is read from a file attached to the same 1Password
# item the fields are written to. Pass --env-file to read from a local file instead.
#
# Usage: ./op-import-fields.sh <item> [--vault <vault>] [--attachment <name>]
#                                     [--env-file <path>] [--only <key>]
#                                     [--limit <n>] [--dry-run]
#
#   <item>          item name, UUID, or share link
#   --attachment    name of the attached file to read (default: the only
#                   attachment, or one named like *.env / .env)
#   --env-file      read KEY=VALUE lines from a local file instead of the
#                   item's attachment ("-" for stdin)
#
set -euo pipefail

usage() {
    cat >&2 <<USAGE
Usage: $0 <item> [--vault <vault>] [--attachment <name>]
                 [--env-file <path>] [--only <key>] [--limit <n>] [--dry-run]

  <item>              item name, UUID, or share link
  --vault <vault>     vault to look in
  --attachment <name> name of the .env file attached to the item
  --env-file <path>   read a local file instead of the attachment ('-' = stdin)
  --only <key>        import just this one key (repeatable, case-insensitive)
  --limit <n>         import only the first n entries (useful for a first test)
  --dry-run           print the op commands that would run; change nothing
USAGE
    exit 2
}

item=""
vault=""
attachment=""
env_file=""
limit=0
only_keys=()
dry_run=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --vault)
            [[ $# -ge 2 ]] || usage
            vault="$2"
            shift 2
            ;;
        --attachment)
            [[ $# -ge 2 ]] || usage
            attachment="$2"
            shift 2
            ;;
        --env-file)
            [[ $# -ge 2 ]] || usage
            env_file="$2"
            shift 2
            ;;
        --only)
            [[ $# -ge 2 ]] || usage
            only_keys+=("${2,,}")
            shift 2
            ;;
        --limit)
            [[ $# -ge 2 ]] || usage
            if [[ ! "$2" =~ ^[0-9]+$ ]] || [[ "$2" -lt 1 ]]; then
                echo "--limit needs a positive integer, got: $2" >&2
                exit 2
            fi
            limit="$2"
            shift 2
            ;;
        --dry-run)
            dry_run=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage
            ;;
        *)
            if [[ -z "$item" ]]; then
                item="$1"
            else
                echo "Unexpected argument: $1" >&2
                usage
            fi
            shift
            ;;
    esac
done

[[ -n "$item" ]] || usage

command -v op >/dev/null 2>&1 || { echo "op CLI not found on PATH" >&2; exit 1; }

# Quote a single argument the way it would need to be typed at a shell.
quote_arg() {
    if [[ "$1" =~ ^[A-Za-z0-9._:/=@-]+$ ]]; then
        printf '%s' "$1"
    else
        printf "'%s'" "${1//\'/\'\\\'\'}"
    fi
}

# Print a command on one line, shell-quoted.
quote_cmd() {
    local out="" arg
    for arg in "$@"; do
        out+="$(quote_arg "$arg") "
    done
    echo "${out% }"
}

# Print a command wrapped to the terminal width, using backslash continuations
# so it stays copy-pasteable. Continuation lines are indented.
print_cmd_wrapped() {
    local width indent="      " line="" piece first=true
    width=${COLUMNS:-0}
    [[ "$width" -gt 0 ]] || width=$(tput cols 2>/dev/null || echo 80)
    [[ "$width" -ge 40 ]] || width=80

    line="  "
    for arg in "$@"; do
        piece=$(quote_arg "$arg")
        if $first; then
            line+="$piece"
            first=false
            continue
        fi
        # +2 leaves room for the trailing " \"
        if (( ${#line} + 1 + ${#piece} + 2 > width )); then
            printf '%s \\\n' "$line"
            line="${indent}${piece}"
        else
            line+=" $piece"
        fi
    done
    printf '%s\n' "$line"
}

# ---------------------------------------------------------------------------
# Locate and read the KEY=VALUE source
# ---------------------------------------------------------------------------

get_args=(item get "$item")
[[ -n "$vault" ]] && get_args+=(--vault "$vault")

if [[ -z "$env_file" ]]; then
    command -v jq >/dev/null 2>&1 || { echo "jq is required to read item attachments" >&2; exit 1; }

    if $dry_run; then
        echo "Commands that would run:"
        echo
        echo "  # 1. list the files attached to the item"
        print_cmd_wrapped op "${get_args[@]}" --format json
    fi

    item_json=$(op "${get_args[@]}" --format json)

    files_json=$(jq -c '[.files[]? | {id, name, section: (.section.label // .section.id // "")}]' <<<"$item_json")

    # Resolve the item's real vault/item names; the user may have passed a UUID
    # or share link, and a secret reference needs identifiers op can resolve.
    ref_vault=$(jq -r '.vault.name // .vault.id // ""' <<<"$item_json")
    ref_item=$(jq -r '.title // .id // ""' <<<"$item_json")
    file_count=$(jq 'length' <<<"$files_json")

    if [[ "$file_count" -eq 0 ]]; then
        echo "No files are attached to item '$item'." >&2
        echo "Attach the .env to the item, or pass --env-file to read a local file." >&2
        exit 1
    fi

    if [[ -n "$attachment" ]]; then
        match=$(jq -c --arg n "$attachment" '[.[] | select(.name == $n)]' <<<"$files_json")
    elif [[ "$file_count" -eq 1 ]]; then
        match="$files_json"
    else
        # Several attachments: prefer the ones that look like env files.
        match=$(jq -c '[.[] | select(.name == ".env" or (.name | test("(^|\\.)env$")))]' <<<"$files_json")
    fi

    match_count=$(jq 'length' <<<"$match")

    if [[ "$match_count" -eq 0 ]]; then
        echo "No attachment matched on item '$item'. Attached files:" >&2
        jq -r '.[] | "  " + .name' <<<"$files_json" >&2
        echo "Pick one with --attachment <name>." >&2
        exit 1
    fi

    if [[ "$match_count" -gt 1 ]]; then
        echo "Multiple attachments matched on item '$item':" >&2
        jq -r '.[] | "  " + .name' <<<"$match" >&2
        echo "Pick one with --attachment <name>." >&2
        exit 1
    fi

    file_name=$(jq -r '.[0].name' <<<"$match")
    file_section=$(jq -r '.[0].section' <<<"$match")

    if [[ -z "$ref_vault" || -z "$ref_item" ]]; then
        echo "Could not determine the vault/item name needed to read the attachment." >&2
        exit 1
    fi

    # Attachments on a regular item are read with a secret reference:
    #   op://<vault>/<item>/[section/]<file-name>
    # ('op document get' only works on Document-category items.)
    if [[ -n "$file_section" ]]; then
        file_ref="op://${ref_vault}/${ref_item}/${file_section}/${file_name}"
    else
        file_ref="op://${ref_vault}/${ref_item}/${file_name}"
    fi

    fetch_cmd=(op read "$file_ref")

    if $dry_run; then
        echo
        echo "  # 2. read the env file ($file_name) -- really run, to get field names"
        print_cmd_wrapped "${fetch_cmd[@]}"
    fi

    env_source="attachment '$file_name' on '$item'"
    content=$("${fetch_cmd[@]}")
elif [[ "$env_file" == "-" ]]; then
    env_source="stdin"
    content=$(cat)
else
    if [[ ! -r "$env_file" ]]; then
        echo "Cannot read file: $env_file" >&2
        exit 1
    fi
    env_source="$env_file"
    content=$(cat -- "$env_file")
fi

# ---------------------------------------------------------------------------
# Parse KEY=VALUE lines
# ---------------------------------------------------------------------------

assignments=()
keys=()
line_no=0

while IFS= read -r line || [[ -n "$line" ]]; do
    line_no=$((line_no + 1))
    line="${line%$'\r'}"

    # Skip blanks and comments
    [[ -z "${line//[[:space:]]/}" ]] && continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue

    # Tolerate a leading "export "
    line="${line#export }"

    if [[ "$line" != *=* ]]; then
        echo "Line $line_no: no '=' found, skipping: $line" >&2
        continue
    fi

    key="${line%%=*}"
    value="${line#*=}"

    # Trim surrounding whitespace from the key
    key="${key#"${key%%[![:space:]]*}"}"
    key="${key%"${key##*[![:space:]]}"}"

    if [[ -z "$key" ]]; then
        echo "Line $line_no: empty key, skipping" >&2
        continue
    fi

    # Strip one layer of matching quotes from the value
    if [[ "$value" =~ ^\"(.*)\"$ ]] || [[ "$value" =~ ^\'(.*)\'$ ]]; then
        value="${BASH_REMATCH[1]}"
    fi

    key="${key,,}"

    keys+=("$key")
    assignments+=("${key}[password]=${value}")
done <<<"$content"

if [[ ${#assignments[@]} -eq 0 ]]; then
    echo "No usable KEY=VALUE entries found in $env_source" >&2
    exit 1
fi

# --only: keep just the named keys.
if [[ ${#only_keys[@]} -gt 0 ]]; then
    sel_keys=() sel_assignments=()
    for i in "${!keys[@]}"; do
        for want in "${only_keys[@]}"; do
            if [[ "${keys[$i]}" == "$want" ]]; then
                sel_keys+=("${keys[$i]}")
                sel_assignments+=("${assignments[$i]}")
                break
            fi
        done
    done
    if [[ ${#sel_keys[@]} -eq 0 ]]; then
        echo "None of the --only keys were found in $env_source." >&2
        echo "Available keys:" >&2
        printf '  %s\n' "${keys[@]}" >&2
        exit 1
    fi
    for want in "${only_keys[@]}"; do
        found=false
        for k in "${sel_keys[@]}"; do
            [[ "$k" == "$want" ]] && { found=true; break; }
        done
        $found || echo "Warning: --only key '$want' not found in $env_source" >&2
    done
    keys=("${sel_keys[@]}")
    assignments=("${sel_assignments[@]}")
fi

# --limit: keep only the first n entries.
if [[ "$limit" -gt 0 && "$limit" -lt ${#assignments[@]} ]]; then
    total=${#assignments[@]}
    keys=("${keys[@]:0:$limit}")
    assignments=("${assignments[@]:0:$limit}")
    echo "Note: --limit $limit -- importing $limit of $total entries." >&2
fi

op_args=(item edit "$item")
[[ -n "$vault" ]] && op_args+=(--vault "$vault")
op_args+=("${assignments[@]}")

if $dry_run; then
    # One command per field, so each line is readable and individually
    # copy-pasteable. Values are masked; printing them would leak every
    # secret to the terminal and shell history.
    echo
    echo "  # 3. write ${#assignments[@]} field(s), values masked as <...>"
    for k in "${keys[@]}"; do
        edit_args=(item edit "$item")
        [[ -n "$vault" ]] && edit_args+=(--vault "$vault")
        edit_args+=("${k}[password]=<...>")
        print_cmd_wrapped op "${edit_args[@]}" --format json
    done
    echo
    echo "Would set ${#assignments[@]} field(s) on '$item'"
    echo "from $env_source."
    echo "(The real run batches these into a single 'op item edit' call.)"
    exit 0
fi

op "${op_args[@]}" --format json >/dev/null
echo "Set ${#assignments[@]} field(s) on '$item' from $env_source."
