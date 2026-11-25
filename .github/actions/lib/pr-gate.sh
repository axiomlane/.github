#!/usr/bin/env bash
# Decide whether a Claude review should run on a pull request.
#
# Reads PR_NUMBER, BASE_BRANCH, TOKEN_SET, GH_TOKEN and GITHUB_REPOSITORY from
# the environment. Writes `run=true|false` and `head_sha=<sha>` to
# $GITHUB_OUTPUT. Skips, with a notice, unless the pull request is open, not a
# draft, targets BASE_BRANCH and comes from this repository (not a fork), and
# the Claude token is available (it isn't on Dependabot pull requests).
set -euo pipefail

skip() {
  echo "::notice title=Claude review skipped::$1"
  echo "run=false" >>"$GITHUB_OUTPUT"
  exit 0
}

[[ "$PR_NUMBER" =~ ^[0-9]+$ ]] || skip "no pull request number"
[[ "$TOKEN_SET" == "true" ]] || skip "CLAUDE_CODE_OAUTH_TOKEN is not available to this run"

pr=$(gh api "repos/$GITHUB_REPOSITORY/pulls/$PR_NUMBER")
state=$(jq -r .state <<<"$pr")
draft=$(jq -r .draft <<<"$pr")
base=$(jq -r .base.ref <<<"$pr")
head_repo=$(jq -r .head.repo.full_name <<<"$pr")
head_sha=$(jq -r .head.sha <<<"$pr")

[[ "$state" == "open" ]] || skip "pull request #$PR_NUMBER is $state"
[[ "$draft" == "false" ]] || skip "pull request #$PR_NUMBER is a draft"
[[ "$base" == "$BASE_BRANCH" ]] || skip "pull request #$PR_NUMBER targets $base, not $BASE_BRANCH"
[[ "$head_repo" == "$GITHUB_REPOSITORY" ]] || skip "pull request #$PR_NUMBER comes from a fork ($head_repo)"

{
  echo "run=true"
  echo "head_sha=$head_sha"
} >>"$GITHUB_OUTPUT"
