# Part 1: Semantic Versioning

## Part 1: Overview

## Part 1: Process documentation
- Used provided resources to familiarize myself with semantic versioning, and how to implement tagging with github workflows.

Current workflow
```text
name: ci

on:
  push:
    branches:
      - "main"

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      -
        name: Checkout
        uses: actions/checkout@v4
      -
        name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      -
        name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      -
        name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: ${{ secrets.DOCKERHUB_USERNAME }}/sp2024-ceg3120-proj:latest
```

- Named current workflow ci.yml.old
- Created new file named ci.yml

New workflow
```text
name: ci

on:
  push:
    branches:
      - "main"

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      -
        name: Checkout
        uses: actions/checkout@v4
      -
        name: Docker meta
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ secrets.DOCKERHUB_USERNAME }}/sp2024-ceg3120-proj
      -
        name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      -
        name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      -
        name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
```

- After one push heres how it looks.

![workflowworkingmaybe](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/5ef535da-d46e-4ad5-a0f8-47460f2b16ab)

- Committed again to test, heres how it looks.



## Part 1: Resources used

https://semver.org/ *semantic versioning info*

https://docs.docker.com/build/ci/github-actions/manage-tags-labels/ *used to figure out how to implement the tagging*

https://github.com/docker/metadata-action *used to figure out how to implement the tagging*
