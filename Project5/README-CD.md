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

# Part 2: Deployment

## Part 2: Overview
For this part of the project, we will be installing Docker on an AWS instance, and configuring that instance to run a container, stop the "old" container, remove the old container, pull the "new" image from Dockerhub, and start a new container using the new image. All this should be done using a script, a Github workflow, and an open source "webhook" that will listen for a message that will prompt the script to run, and a webhook set up on Github that will send the message. This message will come from Github ideally, after a workflow run.

## Part 2: Process documentation
- The instance I will use is the one we created at the start of the semester.

AWS instance
![image](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/ad5d62a5-ae70-4b6f-a158-467c39449a55)

- Installed Docker using https://docs.docker.com/engine/install/ubuntu/ which walks through all the commands you need to run to get it working.

Docker installed successfully and hello-world container was run
![image](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/2e7701b3-6bdb-41c3-9181-8467611093ba)

- Ran command `sudo apt-get install webhook`

Webhook installed
![image](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/6eeac5db-ae2c-4a14-9e77-be621484a80d)

![image](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/fd47bb84-2fd3-4169-810b-e4e34a49bf0c)

- Created initial script, will need to test to confirm functionality.

Test script
```text
#! /bin/bash
sudo docker stop <CONTAINERNAME>
sudo docker remove <CONTAINERNAME>
sudo docker pull <USERNAME/REPO:TAG>
sudo docker run -d -p 8080:80 --name <CONTAINER_NAME> --restart always <IMAGE_NAME>
```

- Manually pulled latest image from Dockerhub.
- Manually ran container from image I just pulled
- Ran this script...

```text
#! /bin/bash
sudo docker stop testscript
sudo docker remove testscript
sudo docker pull thornburyjac/sp2024-ceg3120-proj:latest
sudo docker run -d -p 8080:80 --name testscript --restart always thornburyjac/sp2024-ceg3120-proj:latest
```
Script breakdown: The first line stops the currently running container. The second line removes that stopped container. The third line pulls the latest image from Dockerhub. The fourth line starts the new container using the new image that was just pulled. It is set to run in detached mode which means the terminal will not be held up. The port 8080:80 is specified meaning the host is listening on port 8080 for requests, and those requests will be sent to port 80 on the container. The --restart always option means the container will automatically restart if it stops for any reason, unless it was explicitly stopped by the user. 

- Appears to work, seems to stop old container and start a new one.
- Created this script file on my instance in /home/ubuntu/script.
- Ideally, if I wanted others to be able to use this script I would either run `sudo chmod 755 /home/ubuntu/script` which would make it executable by everyone OR put it in /usr/local/bin which is a location PATH knows to look for stuff like that and alter the permissions. If I put it there I would probably rename it to something more descriptive than "script".
- Created /etc/webhook.conf, this way the webhook.service can start since it has this file, and the contents of the file are the hooks the service will use.

webhook.conf contents...
```text
[
  {
    "id": "redeploy-webhook",
    "execute-command": "/home/ubuntu/script"
  }
]
```
This is essentially the "hook" our webhook.service will use. It is named "redeploy-webhook" and it executes the command "/home/ubuntu/script" which will run the script we have created.

- webhook service still stopped, leaving it stopped for now until I am ready to test.
- Altered systemd service file for webhook to ensure when this instance reboots our webhook service still works...

/lib/systemd/system/webhook.service contents
```text
[Unit]
Description=Small server for creating HTTP endpoints (hooks)
Documentation=https://github.com/adnanh/webhook/
ConditionPathExists=/etc/webhook.conf

[Service]
ExecStart=/usr/bin/webhook -nopanic -hooks /etc/webhook.conf -verbose

[Install]
WantedBy=multi-user.target
```
So this is the file for the webhook.service. While I am not very familiar with how to configure these, you can see that there is a condition that webhook.conf exists, and that if that condition is met the service starts running this command `/usr/bin/webhook -nopanic -hooks /etc/webhook.conf -verbose`. That command uses the /usr/bin/webhook program with the options -nopanic and -verbose and is provided the path to the hook(s) to use which is the /etc/webhook.conf file I created. Alternatively I could create my own hooks file, and point this file to it by altering the condition line to ConditionPathExists=/path/to/hooks/file and command `/usr/bin/webhook -nopanic -hooks /path/to/hooks/file -verbose`. If you wanted to do this manually, you could just run the command `webhook -nopanic -hooks /etc/webhook.conf -verbose` as long as webhook was configured correctly.

- Now we need to setup an automatic process, ideally using our github workflow run, to trigger the hook to run the script when we push a fresh image to Dockerhub. While webhook.service is running, we need to send a HTTP get or post request to http://34.199.215.59:9000/hooks/redeploy-webhook
- Added the below webhook to github...

![githubwebhook](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/307ddedd-ffea-42ff-97e1-97a31fadb817)
![githubwebhook2](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/5f068259-f107-47dc-b48d-72b61a2b8dff)
Basically this means when our workflow run is complete, Github will hit that link we provided in the first screenshot.

- Now github knows about our hooks link, the secret "redeploy" (I dont think this is necessary), and the action we want it to happen on which is workflow runs.
- Checked "demo-Lab1SecurityGroup", it seems to allow all traffic all ports.
- Ran `sudo systemctl restart webhook.service`
- Error: The unit file, source configuration file or drop-ins of webhook.service changed on disk. Run 'systemctl daemon-reload' to reload units.
- Ran `sudo systemctl daemon-reload`
- Checked webhook.service status, seems to be running, starting first test.
- Ran through this process (on the instance I have a cloned repo)...

```text
jacob@lappy:~/s24cicd-thornburyjac$ vim Dockerfile
jacob@lappy:~/s24cicd-thornburyjac$ git add .
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
v2.0.0
v3.0.0
jacob@lappy:~/s24cicd-thornburyjac$ git tag v3.1.0 -m "testing"
jacob@lappy:~/s24cicd-thornburyjac$ git commit -m "testing version control"
[main 9a8158c] testing version control
 1 file changed, 1 insertion(+), 1 deletion(-)
jacob@lappy:~/s24cicd-thornburyjac$ git push origin ^C
jacob@lappy:~/s24cicd-thornburyjac$ git push origin v3.1.0
Enumerating objects: 6, done.
Counting objects: 100% (6/6), done.
Delta compression using up to 16 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (4/4), 440 bytes | 440.00 KiB/s, done.
Total 4 (delta 2), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (2/2), completed with 2 local objects.
To github.com:WSU-kduncan/s24cicd-thornburyjac.git
 * [new tag]         v3.1.0 -> v3.1.0
```

- Confirmed workflow ran.
- Checked instance, see below screenshot...

![workedmaybe](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/7987e33d-29d4-4f97-8a1d-42f7c9e4c667)

- I believe that means its working, I ran through the process and after the workflow ran I checked my instance and see a container that started 25 seconds after I ran through the process and whatnot.
- Need to create the video showing this working, but I think were good.

## Part 2: Resources used

https://docs.docker.com/engine/install/ubuntu/ *used to install Docker on the Ubuntu AWS instance*

https://github.com/pattonsgirl/CEG3120/blob/main/CourseNotes/webhook.md *used to install webhook on AWS instance*

# Part 3: Diagram

## Part 3: Diagramming

![Project5Diagram](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/fbff7a11-35a2-4e41-bde2-aa88c05e07a9)
I think the diagram well explains the process, but to sum it up here...
1. You have a cycle of development where code exists, is changed, is pushed, etc.
2. The workflow in Github is what will push the current version to Dockerhub when a push with a tag happens, that tag is used to track versioning using semantic versioning.
3. When the workflow finishes and the new version is in Dockerhub, we have a webhook configured in Github to send a message to the EC2 webhook.
4. The EC2 webhook receives the message, which triggers the script to run and stop the current container, and start a new container with the fresh image pulled from Dockerhub
5. This means that when a new version is created and pushed to Dockerhub, the container running the service on the EC2 instance is not down for much time at all since it stops the container, removes it, pulls the new image, creates the new container from the new image, and runs it.

## Part 3: Resources used

https://lucid.app/documents *used to create the diagram*
