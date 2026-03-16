# Changelog

## Unreleased

- Fixed Docker API client initialization to use version negotiation by default.
- Removed the implicit `DOCKER_API_VERSION=1.25` default that could break against daemons requiring API `1.40+`.
- Updated GitHub Actions to use self-hosted Linux runners and publish images to this fork's GHCR package.
- Removed the upstream maintenance banner and refreshed repository links for this fork.
- Fixed the CodeQL workflow to install Go explicitly and use a manual build step on self-hosted runners.
- Updated GitHub Actions to Node 24 compatible action versions where available and disabled flaky `setup-go` cache restore on self-hosted runners.
- Fixed Dockerfile linting for the self-contained image build.
- Updated CI workflows to use Go `1.26.1` while keeping the module `go` directive unchanged.
- Replaced the pinned Staticcheck GitHub Action with a direct `go install` based lint step for better compatibility with newer Go toolchains.
