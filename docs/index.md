<p style="text-align: center; margin-left: 1.6rem;">
  <img alt="Logotype depicting a lighthouse" src="./images/logo-450px.png" width="450" />
</p>
<h1 align="center">
  Watchtower
</h1>

<p align="center">
  A container-based solution for automating Docker container base image updates.
  <br/><br/>
  <a href="https://github.com/Bald1nh0/watchtower/actions/workflows/pull-request.yml">
    <img alt="Pull Request" src="https://github.com/Bald1nh0/watchtower/actions/workflows/pull-request.yml/badge.svg" />
  </a>
  <a href="https://github.com/Bald1nh0/watchtower/actions/workflows/release.yml">
    <img alt="Release" src="https://github.com/Bald1nh0/watchtower/actions/workflows/release.yml/badge.svg" />
  </a>
  <a href="https://github.com/Bald1nh0/watchtower/actions/workflows/publish-docs.yml">
    <img alt="Docs" src="https://github.com/Bald1nh0/watchtower/actions/workflows/publish-docs.yml/badge.svg" />
  </a>
  <a href="https://github.com/Bald1nh0/watchtower/releases">
    <img alt="Latest version" src="https://img.shields.io/github/v/tag/Bald1nh0/watchtower?label=release" />
  </a>
  <a href="https://www.apache.org/licenses/LICENSE-2.0">
    <img alt="Apache-2.0 License" src="https://img.shields.io/github/license/Bald1nh0/watchtower.svg" />
  </a>
</p>

## Quick Start

With watchtower you can update the running version of your containerized app simply by pushing a new image to GHCR or
your own image registry. Watchtower will pull down your new image, gracefully shut down your existing container
and restart it with the same options that were used when it was deployed initially. Run the watchtower container with
the following command:

=== "docker run"

    ```bash
    $ docker run -d \
    --name watchtower \
    -v /var/run/docker.sock:/var/run/docker.sock \
    ghcr.io/bald1nh0/watchtower:latest
    ```

=== "docker-compose.yml"

    ```yaml
    version: "3"
    services:
      watchtower:
        image: ghcr.io/bald1nh0/watchtower:latest
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock
    ```
