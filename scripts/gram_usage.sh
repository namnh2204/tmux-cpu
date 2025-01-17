#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

gram_usage_format="%dMB/%dMB"

print_gram_usage() {
  gram_usage_format=$(get_tmux_option "@gram_usage_format" "$gram_usage_format")

  if command_exists "nvidia-smi"; then
    loads=$(cached_eval nvidia-smi | sed -nr 's/.*\s([0-9]+)MiB\s*\/\s*([0-9]+)MiB.*/\1 \2/p')
  elif command_exists "cuda-smi"; then
    loads=$(cached_eval cuda-smi | sed -nr 's/.*\s([0-9.]+) of ([0-9.]+) MB.*/\1 \2/p' | awk '{print $2-$1" "$2}')
  else
    echo "No GPU"
    return
  fi
  echo "$loads" | awk -v format="$gram_usage_format" '{used+=$1; tot+=$2} END {printf format, used, tot}'
}

main() {
  print_gram_usage
}
main "$@"
