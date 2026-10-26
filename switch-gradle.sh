#!/usr/bin/env bash
# Usage: ./switch-gradle.sh 9.7.1   (edits the wrapper only; then sync in the IDE)
set -euo pipefail
v="${1:?usage: $0 <gradle-version>}"
sed -i -E "s#gradle-[0-9.]+-bin\.zip#gradle-${v}-bin.zip#" "$(dirname "$0")/gradle/wrapper/gradle-wrapper.properties"
grep distributionUrl "$(dirname "$0")/gradle/wrapper/gradle-wrapper.properties"
