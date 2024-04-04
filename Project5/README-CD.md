# Part 1: Semantic Versioning

## Part 1: Overview
Currently, our Github workflow is pushing an image to Dockerhub, but it is not tracking the different versions it is just overwriting whats already been pushed. That means whenever we push to Dockerhub there will only ever be the "latest" image. This part of the project is where we implement processes to make sure we track the version number. This way we see the different versions that have been pushed. For example, we would have a version 1.0, and version 1.1, a verison 1.3, etc. We can research popular version numbering methods like semantic versioning and use that. Based on the resources provided, we will be using Github actions and metadata to accomplish this.

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
- Issues persist. Pending furhter testing.

After painstaking space policing in the yaml file, here is my working workflow (called test.yml in the .github/workflows directory)
```text
name: test

on:
  push:
    branches:
      - "main"
    tags:
      - "v*"

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
          tags: |
            type=semver,pattern={{major}}.{{minor}}
            type=semver,pattern={{major}}
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

- Important note: this will not work when committing/pushing in the browser since the browser is not including tag information.
- Important note: when pushing from remote (where we include the tag information needed for the workflow to work) there seems to be an interesting caveat. My workflow only tags images with vMAJOR.MINOR or vMAJOR. Despite this, the Github Action will get angry when running the command `git tag v1.0 -m "testing"`. It wants `git tag v1.0.0 -m "testing"` the patch as well even though it will not include it in the image tag that is pushed to Dockerhub.
- Here is how it works...
- The workflow above exists and kicks in when an event is detected, in this case, a push. Ideally a push from remote because that is where we can include the tag info it wants. Not sure if you can do so in the Github browser version.
- I run through this process in my remote repo...

```text
jacob@lappy:~/s24cicd-thornburyjac$ vim Dockerfile
jacob@lappy:~/s24cicd-thornburyjac$ git add .
jacob@lappy:~/s24cicd-thornburyjac$ git tag v1.0.0 -m "testing"
jacob@lappy:~/s24cicd-thornburyjac$ git tag
v1.0
v1.0.0
v1.1
v1.2
v1.3
v1.4
v1.5
v1.5.0
v1.6.0
v1.7.0
jacob@lappy:~/s24cicd-thornburyjac$ git commit -m "testing version control"
[main 5e8de06] testing version control
 1 file changed, 1 insertion(+), 1 deletion(-)
jacob@lappy:~/s24cicd-thornburyjac$ git push origin v1.0.0
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Writing objects: 100% (1/1), 164 bytes | 164.00 KiB/s, done.
Total 1 (delta 0), reused 0 (delta 0), pack-reused 0
To github.com:WSU-kduncan/s24cicd-thornburyjac.git
 * [new tag]         v1.0.0 -> v1.0.0
jacob@lappy:~/s24cicd-thornburyjac$
```

- Basically I make a change, I track the change, I make the appropriate tag, I commit the change, I push the change using `git push origin TAGYOUMADE`.
- Once the push from remote with the tag info is detected, the workflow kicks in.

![image](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/16d03e7e-9d2c-4043-baba-81dfa7ab7fb3)

- That workflow does all the building and pushing to Dockerhub, but now, instead of just overwriting what is there, it makes a specific version.

![image](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/47559d13-4121-48d1-a5a0-d44e83601323)

- As you can see, we have the latest version which gets overwritten each time the workflow runs. We have the vMAJOR version, and the vMAJOR.MINOR version.
- Obviously the real use case for this is to have a latest version which would be like the evolving beta almost, you have a vMAJOR version which is a version with no minor updates added on, and you have a vMAJOR.MINOR version which has the additional updates. I imagine vMAJOR.MINOR would be the one out in the wild the most, vMAJOR would be for people who dont want the minor version messing with their prod environments, and the latest version would be for devs and beta testers sort of. Essentially  this is an interesting proof of concept but in the real world the workflow and versioning would be far more complicated.
- I will go through the same process again, see below for new versions...

Process
```text
jacob@lappy:~/s24cicd-thornburyjac$ vim Dockerfile
jacob@lappy:~/s24cicd-thornburyjac$ git add .
jacob@lappy:~/s24cicd-thornburyjac$ git tag v1.1.0 -m "testing"
jacob@lappy:~/s24cicd-thornburyjac$ git tag
v1.0
v1.0.0
v1.1
v1.1.0
v1.2
v1.3
v1.4
v1.5
v1.5.0
v1.6.0
v1.7.0
jacob@lappy:~/s24cicd-thornburyjac$ git commit -m "testing version control"
[main 920b502] testing version control
 1 file changed, 1 insertion(+), 1 deletion(-)
jacob@lappy:~/s24cicd-thornburyjac$ git push origin v1.1.0
Enumerating objects: 6, done.
Counting objects: 100% (6/6), done.
Delta compression using up to 16 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (4/4), 431 bytes | 431.00 KiB/s, done.
Total 4 (delta 2), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (2/2), completed with 2 local objects.
To github.com:WSU-kduncan/s24cicd-thornburyjac.git
 * [new tag]         v1.1.0 -> v1.1.0
jacob@lappy:~/s24cicd-thornburyjac$
```

hub.docker
![image](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/1ff313b9-f0e8-4a05-a2ca-34d7cab6b3df)

- As you can see, now we have v1.1, as well as the previous version v1.0. It looks like it overwrote v1, I think that should not happen in a real situation but at this point I am not sure how to make that not happen.

## Part 1: Resources used

https://semver.org/ *semantic versioning info*

https://docs.docker.com/build/ci/github-actions/manage-tags-labels/ *used to figure out how to implement the tagging*

https://github.com/docker/metadata-action *used to figure out how to implement the tagging*

https://hub.docker.com/repository/docker/thornburyjac/sp2024-ceg3120-proj/general *link to dockerhub repo*
