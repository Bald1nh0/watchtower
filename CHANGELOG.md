# Changelog

## Unreleased

- Fixed Docker API client initialization to use version negotiation by default.
- Removed the implicit `DOCKER_API_VERSION=1.25` default that could break against daemons requiring API `1.40+`.
- Updated GitHub Actions to use self-hosted Linux runners and publish images to this fork's GHCR package.
- Removed the upstream maintenance banner and refreshed repository links for this fork.
