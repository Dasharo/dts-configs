#!/bin/bash

set -euo pipefail

print_usage(){
    echo "Usage: $(basename "${BASH_SOURCE[0]}") <path-to-dts-configs>

Parses <dts-configs>/configs/*.json, extracts every value whose key
contains _path_ or _link_ (or is exactly platform_sign_key), strips
the last path element (which is a file), and creates the resulting
directory tree under local-server directory. Then starts an HTTP
server on port 8080."
}

if [[ $# -ne 1 || "$1" == "-h" || "$1" == "--help" ]]; then
    print_usage
    exit 0
fi

CONFIGS_DIR="$(realpath "${1}")/configs"
OUTPUT_BASE="./test-server"

# ── dependency check ──────────────────────────────────────────────────────────
for cmd in jq python3; do
    if ! command -v "${cmd}" &>/dev/null; then
        echo "Error: '${cmd}' is required but not installed." >&2
        exit 1
    fi
done

if [[ ! -d "${CONFIGS_DIR}" ]]; then
    echo "Error: configs directory not found: ${CONFIGS_DIR}" >&2
    print_usage
    exit 1
fi

# ── jq filter ────────────────────────────────────────────────────────────────
# Recurse into every object, pick values whose key:
#   • contains "_path_" or "_link_", OR
#   • is exactly "platform_sign_key"
JQ_FILTER='
  .. | objects | to_entries[] |
  select(.key | (test("_path_|_link_") or . == "platform_sign_key")) |
  .value | strings
'

# ── process each config file ──────────────────────────────────────────────────
echo "Scanning : ${CONFIGS_DIR}"
echo "Output   : ${OUTPUT_BASE}"
echo

for json_file in "${CONFIGS_DIR}"/*.json; do
    config_name="$(basename "${json_file}" .json)"

    echo "── ${config_name}.json"

    while IFS= read -r raw_value; do
        [[ -z "${raw_value}" ]] && continue

        # platform_sign_key may hold space-separated paths — split on whitespace
        for single_path in ${raw_value}; do
            single_path="${single_path%/}"          # strip any trailing slash
            dir_part="$(dirname "${single_path}")"  # last element is a file

            # dirname returns "." for a bare filename with no directory part
            [[ "${dir_part}" == "." ]] && continue

            target="${OUTPUT_BASE}/${dir_part}"
            if [[ ! -d "${target}" ]]; then
                echo "   mkdir  ${dir_part}"
                mkdir -p "${target}"
            fi
        done
    done < <(jq -r "${JQ_FILTER}" "${json_file}" | sort -u)
done

echo
echo "Directory structure complete."
echo
echo "Starting Python HTTP server on port 8080 (serving ${OUTPUT_BASE}) ..."
echo "Press Ctrl-C to stop."
echo

cd "${OUTPUT_BASE}"
exec python3 -m http.server 8080
