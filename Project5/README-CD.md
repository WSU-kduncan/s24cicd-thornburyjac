# Part 1: Semantic Versioning

## Part 1: Overview
Currently, our Github workflow is pushing an image to Dockerhub, but it is not tracking the different versions it is just overwriting whats already been pushed. That means whenever we push to Dockerhub there will only ever be the "latest" image. This part of the project is where we implement processes to make sure we track the version number. This way we see the different versions that have been pushed. For example, we would have a version 1.0, and version 1.1, a verison 1.3, etc. We can research popular version numbering methods and maybe use those. Based on the resources provided, we will be using Github actions and metadata to accomplish this.

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

- Committed again to test, it looks the same, need to tweak the workflow.

Tweaked workflow
```text
name: ci

on:
  push:
    branches:
      - "main"
    tags:
      - "v*.*"

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
         images: |
           ${{ secrets.DOCKERHUB_USERNAME }}/sp2024-ceg3120-proj
         tags: |
           type=ref,event=branch
           type=ref,event=pr
           type=semver,pattern={{version}}
           type=semver,pattern={{major}}.{{minor}}
           type=semver,pattern={{major}}
           type=sha     
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

- When commits happen here is how it looks...

![workflowworkingmore](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/ba471ada-7147-4270-844b-373271b41f95)

- So now we are getting multiple versions with the old versions remaining, but the new versions are showing up as hash values? and Main keeps getting overwritten? Further tweaking required.
- Removed `type=sha` line from the workflow in the `name: Docker meta` section.

## Part 1: Resources used

https://semver.org/ *semantic versioning info*

https://docs.docker.com/build/ci/github-actions/manage-tags-labels/ *used to figure out how to implement the tagging*

https://github.com/docker/metadata-action *used to figure out how to implement the tagging*
