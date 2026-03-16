#!/usr/bin/env bash

set -euo pipefail

write_output() {
  echo "$1=$2" >>"$GITHUB_OUTPUT"
}

write_multiline_output() {
  local key="$1"
  local value="$2"
  {
    echo "${key}<<__WATCHTOWER_EOF__"
    printf '%s\n' "$value"
    echo "__WATCHTOWER_EOF__"
  } >>"$GITHUB_OUTPUT"
}

fail() {
  echo "$*" >&2
  exit 1
}

valid_tag() {
  [[ "$1" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

latest_release_tag() {
  git tag -l 'v*.*.*' --sort=-version:refname | head -n1 || true
}

previous_release_tag() {
  local current_tag="$1"
  git tag -l 'v*.*.*' --sort=-version:refname | grep -Fvx "$current_tag" | head -n1 || true
}

generate_changelog() {
  local from_ref="$1"
  local to_ref="$2"

  if [[ -n "$from_ref" ]]; then
    git log --no-merges --pretty=format:'- %s (%h)' "${from_ref}..${to_ref}"
  else
    git log --no-merges --pretty=format:'- %s (%h)' "$to_ref"
  fi
}

detect_release_type() {
  local from_ref="$1"
  local to_ref="$2"
  local subjects=""
  local bodies=""

  if [[ -n "$from_ref" ]]; then
    subjects="$(git log --format='%s' "${from_ref}..${to_ref}")"
    bodies="$(git log --format='%B' "${from_ref}..${to_ref}")"
  else
    subjects="$(git log --format='%s' "$to_ref")"
    bodies="$(git log --format='%B' "$to_ref")"
  fi

  if grep -Eq 'BREAKING CHANGE:|^[^[:space:]]+(\([^)]+\))?!:' <<<"$bodies"; then
    echo "major"
  elif grep -Eq '^feat(\([^)]+\))?:' <<<"$subjects"; then
    echo "minor"
  else
    echo "patch"
  fi
}

bump_semver() {
  local current_tag="$1"
  local release_type="$2"
  local major=0
  local minor=0
  local patch=0

  if [[ -n "$current_tag" ]]; then
    if [[ ! "$current_tag" =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
      fail "Latest release tag '$current_tag' is not a valid semantic version."
    fi
    major="${BASH_REMATCH[1]}"
    minor="${BASH_REMATCH[2]}"
    patch="${BASH_REMATCH[3]}"
  fi

  case "$release_type" in
    major)
      major=$((major + 1))
      minor=0
      patch=0
      ;;
    minor)
      minor=$((minor + 1))
      patch=0
      ;;
    patch)
      patch=$((patch + 1))
      ;;
    *)
      fail "Unsupported release type '$release_type'."
      ;;
  esac

  echo "v${major}.${minor}.${patch}"
}

emit_release_outputs() {
  local should_release="$1"
  local release_tag="$2"
  local release_ref="$3"
  local release_type="$4"
  local previous_tag="$5"
  local changelog="$6"
  local release_reason="$7"
  local created_tag="$8"

  write_output "should_release" "$should_release"
  write_output "release_tag" "$release_tag"
  write_output "release_ref" "$release_ref"
  write_output "release_version" "${release_tag#v}"
  write_output "release_type" "$release_type"
  write_output "previous_tag" "$previous_tag"
  write_output "release_reason" "$release_reason"
  write_output "created_tag" "$created_tag"
  write_multiline_output "changelog" "${changelog:-No user-facing changes detected.}"
}

main() {
  local ref_type="${GITHUB_REF_TYPE:-}"
  local ref_name="${GITHUB_REF_NAME:-}"
  local release_bump="${RELEASE_BUMP:-auto}"
  local custom_tag="${CUSTOM_TAG:-}"
  local dry_run="${RELEASE_DRY_RUN:-false}"
  local initial_release_tag="${INITIAL_RELEASE_TAG:-}"
  local initial_release_ref="${INITIAL_RELEASE_REF:-}"
  local current_latest_tag=""
  local base_release_tag=""
  local history_base_ref=""
  local previous_tag=""
  local release_tag=""
  local release_ref=""
  local release_type=""
  local release_reason=""
  local changelog=""

  current_latest_tag="$(latest_release_tag)"
  base_release_tag="$current_latest_tag"

  if [[ -z "$base_release_tag" ]] && [[ -n "$initial_release_tag" ]]; then
    if ! valid_tag "$initial_release_tag"; then
      fail "Initial release tag '$initial_release_tag' does not match the expected v<major>.<minor>.<patch> format."
    fi
    base_release_tag="$initial_release_tag"
  fi

  if [[ -z "$current_latest_tag" ]] && [[ -n "$initial_release_ref" ]]; then
    if ! git rev-parse -q --verify "${initial_release_ref}^{commit}" >/dev/null; then
      fail "Initial release ref '$initial_release_ref' was not found in the repository history."
    fi
    history_base_ref="$initial_release_ref"
  else
    history_base_ref="$current_latest_tag"
  fi

  if [[ "$ref_type" == "tag" ]]; then
    if ! valid_tag "$ref_name"; then
      fail "Tag '$ref_name' does not match the expected v<major>.<minor>.<patch> format."
    fi

    previous_tag="$(previous_release_tag "$ref_name")"
    changelog="$(generate_changelog "$previous_tag" "$ref_name")"
    emit_release_outputs "true" "$ref_name" "refs/tags/$ref_name" "tag" "$previous_tag" "$changelog" "tag_push" "false"
    return
  fi

  if [[ -n "$history_base_ref" ]] && [[ "$(git rev-list --count "${history_base_ref}..HEAD")" -eq 0 ]] && [[ -z "$custom_tag" ]]; then
    emit_release_outputs "false" "" "" "" "$base_release_tag" "" "no_changes" "false"
    return
  fi

  if [[ -n "$custom_tag" ]]; then
    if ! valid_tag "$custom_tag"; then
      fail "Custom tag '$custom_tag' does not match the expected v<major>.<minor>.<patch> format."
    fi
    release_tag="$custom_tag"
    release_type="custom"
    release_reason="workflow_dispatch"
  else
    if [[ "$release_bump" == "auto" ]]; then
      release_type="$(detect_release_type "$history_base_ref" HEAD)"
    else
      release_type="$release_bump"
    fi

    release_tag="$(bump_semver "$base_release_tag" "$release_type")"
    release_reason="$release_type"
  fi

  if git rev-parse -q --verify "refs/tags/${release_tag}" >/dev/null; then
    fail "Tag '${release_tag}' already exists."
  fi

  if [[ -n "$history_base_ref" ]]; then
    changelog="$(generate_changelog "$history_base_ref" HEAD)"
    previous_tag="$base_release_tag"
  else
    changelog="$(git log --no-merges --pretty=format:'- %s (%h)' -n 30 HEAD)"
    previous_tag="$base_release_tag"
  fi
  release_ref="refs/tags/${release_tag}"

  if [[ "$dry_run" != "true" ]]; then
    git tag -a "$release_tag" -m "Release ${release_tag}"
    git push origin "$release_ref"
  fi

  emit_release_outputs "true" "$release_tag" "$release_ref" "$release_type" "$previous_tag" "$changelog" "$release_reason" "true"
}

main "$@"
