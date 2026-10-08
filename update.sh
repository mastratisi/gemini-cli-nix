#!/usr/bin/env bash
# Rewrite release.json from the npm registry (dist-tag "latest").
set -euo pipefail
cd "$(dirname "$0")"

latest=$(curl -fsS https://registry.npmjs.org/@google/gemini-cli/latest)
version=$(jq -r .version <<<"$latest")

if [[ -f release.json && $(jq -r .version release.json) == "$version" ]]; then
  echo "up to date: $version"
  exit 0
fi

# npm's dist.integrity is already an SRI hash (sha512-...), which fetchurl accepts.
jq '{version, url: .dist.tarball, hash: .dist.integrity}' <<<"$latest" > release.json
echo "updated to $version"
