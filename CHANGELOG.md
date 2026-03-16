# Changelog

## Unreleased

- Fixed Docker API client initialization to use version negotiation by default.
- Removed the implicit `DOCKER_API_VERSION=1.25` default that could break against daemons requiring API `1.40+`.
- Updated GitHub Actions to use self-hosted Linux runners and publish images to this fork's GHCR package.
- Added automated release tag creation on `main` and optional Telegram notifications for queued/completed releases.
- Removed the upstream maintenance banner and refreshed repository links for this fork.
- Fixed the CodeQL workflow to install Go explicitly and use a manual build step on self-hosted runners.
- Updated the CodeQL workflow to use `github/codeql-action@v4` and removed the legacy `git checkout HEAD^2` step.
- Updated GitHub Actions to Node 24 compatible action versions where available and disabled flaky `setup-go` cache restore on self-hosted runners.
- Updated Docker GitHub Actions to Node 24 compatible major versions for GHCR publishing.
- Fixed Dockerfile linting for the self-contained image build.
- Updated CI workflows to use Go `1.26.1` and raised the module baseline to Go `1.26`.
- Replaced the pinned Staticcheck GitHub Action with a direct `go install` based lint step for better compatibility with newer Go toolchains.
- Fixed the `latest-dev` image workflow to build from this fork and publish a multi-arch image for `linux/amd64` and `linux/arm64`.
- Reworked the documentation workflow to use the official GitHub Pages build-and-deploy flow with `configure-pages`, `upload-pages-artifact`, and `deploy-pages`.
- Added OCI image description metadata for GHCR packages and annotated multi-arch image indexes for published tags.
- Updated the docs workflow to use `actions/setup-python@v6` and an explicit `upload-artifact@v6` step to reduce Node 20 deprecation warnings.
