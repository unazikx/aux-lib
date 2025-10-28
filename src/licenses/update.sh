#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nixfmt
# shellcheck shell=bash

set -eo pipefail
alias nix="nix --extra-experimental-features nix-command --extra-experimental-features pipe-operators --extra-experimental-features pipe-operator"

# update the source
# old_url="$(jq -r '.url' source.json)"
# url="$(curl -L \
#   -H "Accept: application/vnd.github+json" \
#   -H "X-GitHub-Api-Version: 2022-11-28" \
#   -H "User-Agent: Aux (https://auxolotl.org) license metadata update script" \
#   https://api.github.com/repos/spdx/license-list-data/tags |
#   jq -r '.[0].tarball_url')"

# if test "$url" != "$old_url"; then
#   new_hash="$(nix hash to-sri --type sha256 "$(nix-prefetch-url --type sha256 --unpack "$url")")"
#   cat >source.json <<EOF
# {
#   "url": "$url",
#   "sha256": "$new_hash"
# }
# EOF
# fi

# get the source
nix build --impure --expr 'builtins.fetchTarball (builtins.fromJSON (builtins.readFile ./source.json))'

# build the license list
nix eval --impure --raw --file ./generate-spdx-licenses.nix | nixfmt >spdx-licenses.nix

# build the exception list
nix eval --impure --raw --file ./generate-spdx-exceptions.nix | nixfmt >spdx-exceptions.nix
