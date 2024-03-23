# Part 1: Dockerize it

## Part 1: Overview

For part 1 of this project, the goals are to...
1. Create the new repository for projects 4 and 5 (which this file is currently in).
2. Create a folder within the new repo called website which will house your website content (html, css, and script files).
3. Install Docker, which is software used for creating and running container applications. Per the Docker site https://www.docker.com/resources/what-container/ a container is "A container is a standard unit of software that packages up code and all its dependencies so the application runs quickly and reliably from one computing environment to another. A Docker container image is a lightweight, standalone, executable package of software that includes everything needed to run an application: code, runtime, system tools, system libraries and settings."
4. Using Docker, create a container image that will run a webserver (nginx) that will be serving up your website. I assume this means creating a container that has all the files needed to run nginx and have nginx work enough to serve the website content.
5. Create a Dockerfile and use it. Per the Docker site https://docs.docker.com/reference/dockerfile/ a Dockerfile is "Docker can build images automatically by reading the instructions from a Dockerfile. A Dockerfile is a text document that contains all the commands a user could call on the command line to assemble an image. This page describes the commands you can use in a Dockerfile."
6. Ensure the website content and Dockerfile are all in this repo.

## Part 1: Process documentation

- Added directory to Project4 directory called website, and included my 7z archive which contains the files for my prototype website for Team Projects 1. The site is not complete, but it is complete enough to work/look fine.
- Installed Docker in my WSL Ubuntu system. Used this site: https://docs.docker.com/engine/install/ubuntu/
- The above website walks you through the commands needed to install and confirm installation of Docker.
- See screenshots...

![dockerinstall1](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/c001c720-02a1-47a5-8b0d-4f8822cc4a9e)
![dockerinstall2](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/eb440cf9-3075-462a-8c5a-5a0dc267cd3a)

## Part 1: Creating a container image and dockerfile

- Found https://medium.com/nerd-for-tech/deploy-a-custom-nginx-docker-image-and-push-it-to-docker-hub-118f1ab2186b. Seems like a good initial test.
- Started local ubuntu machine. Made a directory called proj4test to carry out this test.
- Put the 7z archive with my site files in proj4test.
- Made new directory /proj4test/containering and ran "sudo docker pull nginx:latest"

Output
```text
jacob@lappy:~/proj4test/containering$ sudo docker pull nginx:latest
[sudo] password for jacob:
latest: Pulling from library/nginx
8a1e25ce7c4f: Pull complete
e78b137be355: Pull complete
39fc875bd2b2: Pull complete
035788421403: Pull complete
87c3fb37cbf2: Pull complete
c5cdd1ce752d: Pull complete
33952c599532: Pull complete
Digest: sha256:6db391d1c0cfb30588ba0bf72ea999404f2764febf0f1f196acd5867ac7efa7e
Status: Downloaded newer image for nginx:latest
docker.io/library/nginx:latest
```

Verfied it worked
```text
jacob@lappy:~/proj4test/containering$ sudo docker images
REPOSITORY    TAG       IMAGE ID       CREATED         SIZE
nginx         latest    92b11f67642b   4 weeks ago     187MB
hello-world   latest    d2c94e258dcb   10 months ago   13.3kB
```

- Unzipped site files using "7z x 4980_testsite.7z"
- Created testfile which is my dockerfile based on the article.

```text
jacob@lappy:~/proj4test/containering$ cat testfile
FROM nginx:1.10.1-alpine
COPY /home/jacob/proj4test/4980_testsite/ /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
```

- Ran "sudo docker build -t testing ."
- Error, assuming because the file is named testfile not dockerfile, renamed and reran.
- Another error, more verbose, see below...

```text
jacob@lappy:~/proj4test/containering$ sudo docker build -t testing .
[+] Building 11.2s (6/6) FINISHED                                                         docker:default
 => [internal] load build definition from dockerfile                                                0.0s
 => => transferring dockerfile: 185B                                                                0.0s
 => [internal] load metadata for docker.io/library/nginx:1.10.1-alpine                             11.0s
 => [internal] load .dockerignore                                                                   0.0s
 => => transferring context: 2B                                                                     0.0s
 => [internal] load build context                                                                   0.0s
 => => transferring context: 2B                                                                     0.0s
 => CANCELED [1/2] FROM docker.io/library/nginx:1.10.1-alpine@sha256:dabd1d182f12e2a7d372338dfd0cd  0.1s
 => => resolve docker.io/library/nginx:1.10.1-alpine@sha256:dabd1d182f12e2a7d372338dfd0cde303ef042  0.0s
 => => sha256:dabd1d182f12e2a7d372338dfd0cde303ef042a6ba01cc829ef464982f9c9e2c 1.15kB / 1.15kB      0.0s
 => => sha256:2cd900f340dd52c646566742cc934f89d595c5eff820c7805b5ebf3be661a533 7.99kB / 7.99kB      0.0s
 => ERROR [2/2] COPY /home/jacob/proj4test/4980_testsite/index.html /usr/share/nginx/html           0.0s
------
 > [2/2] COPY /home/jacob/proj4test/4980_testsite/index.html /usr/share/nginx/html:
------
dockerfile:2
--------------------
   1 |     FROM nginx:1.10.1-alpine
   2 | >>> COPY /home/jacob/proj4test/4980_testsite/index.html /usr/share/nginx/html
   3 |     EXPOSE 8080
   4 |     CMD ["nginx", "-g", "daemon off;"]
--------------------
ERROR: failed to solve: failed to compute cache key: failed to calculate checksum of ref 9ac96ec4-99d0-4e2d-9141-7354d491c986::b227tkktf2d3dhnlsfyyr18wd: failed to walk /var/lib/docker/tmp/buildkit-mount3086396574/home/jacob/proj4test/4980_testsite: lstat /var/lib/docker/tmp/buildkit-mount3086396574/home/jacob/proj4test/4980_testsite: no such file or directory

```

- Permissions issue? Path issue?
- Made some changes. Now I have a directory /home/jacob/proj4test. In that is a dockerfile and the 4980testsite directory that contains all site related files. See below for dockerfile...

```text
FROM nginx:1.10.1-alpine
COPY 4980_testsite /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
```

- Ran "sudo docker build -t testing ." FROM the /home/jacob/proj4test directory.
- No errors apparently.
- Confirmed "testing" existed using "docker images" command.

```text
jacob@lappy:~/proj4test$ sudo docker images
REPOSITORY    TAG       IMAGE ID       CREATED         SIZE
testing       latest    7c5e552a2b39   3 minutes ago   60.9MB
nginx         latest    92b11f67642b   4 weeks ago     187MB
hello-world   latest    d2c94e258dcb   10 months ago   13.3kB

```

- Now attempting to build and deploy container using "docker run -d --name <name-container> -p 8080:80 <new_image_name>"
- So my command should be "sudo docker run -d --name testaroo -p 8080:80 testing" see below...

```text

jacob@lappy:~/proj4test$ sudo docker run -d --name testaroo -p 8080:80 testing
6ab104047f164a0c387467fa096924092467b3ec45ddbda0c2fe90600f9e1144
jacob@lappy:~/proj4test$ curl localhost
curl: (7) Failed to connect to localhost port 80 after 0 ms: Connection refused
jacob@lappy:~/proj4test$ curl localhost:8080
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>4980 prototype site</title>
    <link rel="stylesheet" href="styles/index-styles.css">
</head>
<body>
    <div class="banner">
        <h1>Welcome to the 4980 prototype</h1>
        <p>This is meant to be my working prototype of the website/web application functionality for the 4980 design challenge. I have yet to implement the opencv circle detection and cropping feature.</p>
    </div>
    <div class="grid-contain">
        <a href="base.html" class="button">Click here to view base images</a>
        <a href="images/baseimage/base.zip" class="button">Click here to download base images</a>
        <a href="cropped.html" class="button">Click here to view cropped vulnerabilities</a>
        <a href="images/croppedimage/cropped.zip" class="button">Click here to download cropped vulnerabilities</a>
    </div>
</body>
</html>jacob@lappy:~/proj4test$

```

- So it is working sort of, I can curl localhost:8080 and get the HTML, when I go their using a web browser though it only half works, the CSS and other pages are busted see below...

![workingsorta](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/8eddfcf0-e013-4b26-8a2b-107317770b1e)

- I also checked using "sudo docker ps" to see it running.
- Stopped the container using "sudo docker stop testaroo"

```text
jacob@lappy:~/proj4test$ sudo docker stop testaroo
testaroo
jacob@lappy:~/proj4test$ sudo docker images
REPOSITORY    TAG       IMAGE ID       CREATED          SIZE
testing       latest    7c5e552a2b39   11 minutes ago   60.9MB
nginx         latest    92b11f67642b   4 weeks ago      187MB
hello-world   latest    d2c94e258dcb   10 months ago    13.3kB
jacob@lappy:~/proj4test$ sudo docker ps -a
CONTAINER ID   IMAGE         COMMAND                  CREATED         STATUS                      PORTS     NAMES
6ab104047f16   testing       "nginx -g 'daemon of…"   5 minutes ago   Exited (0) 36 seconds ago             testaroo
b16a13fa8164   hello-world   "/hello"                 5 days ago      Exited (0) 5 days ago                 hardcore_swirles
7b68b3877a55   hello-world   "/hello"                 6 days ago      Exited (0) 6 days ago                 objective_clarke
jacob@lappy:~/proj4test$
```

- Permissions issue causing the broken site? Tried again but changed dockerfile to...

```text
FROM nginx:1.10.1-alpine
COPY 4980_testsite /usr/share/nginx/html
RUN chown -R www-data:www-data /usr/share/nginx/html/4980_testsite \
    && chmod -R 750 /usr/share/nginx/html/4980_testsite
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]

```

- Issue persists after building and testing with that new dockerfile.
- Testing with this dockerfile

```text
FROM nginx:1.10.1-alpine
COPY 4980_testsite /usr/share/nginx/html
RUN chown -R www-data:www-data /usr/share/nginx/html/4980_testsite \sudo docker run --rm myimage ls -l /usr/share/nginx/html
    && chmod -R 750 /usr/share/nginx/html/4980_testsite
RUN rm /etc/nginx/sites-available/default
RUN echo "server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html/4980_testsite;

        index index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files $uri $uri/ =404;
        }
}
" > /etc/nginx/sites-available/default
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
```

- Issue persists, links and css still broken. It does still work sorta, as in I can navigate to localhost:8080 and get some html, and the links still go the the files they are just broken.
- Changed the dockerfile to instead make root the owner of the site files instead of www-data.
- Issue persists.
- Changed permission to be 755 instead of 750 for www-data. This is based on the output of the "sudo docker logs testaroo4" command which shows permission denied messages.
- During troubleshooting it seems that the directory copy was not working as expected, see commands and output...

```text
jacob@lappy:~/proj4test$ sudo docker run --rm testing ls -l /usr/share/nginx/html/4980_testsite
ls: /usr/share/nginx/html/4980_testsite: No such file or directory
jacob@lappy:~/proj4test$ sudo docker run --rm testing ls -l /usr/share/nginx/html/
total 24
-rw-r--r--    1 root     root           537 Oct 18  2016 50x.html
-rw-r--r--    1 root     root           969 Mar 15 11:57 base.html
-rw-r--r--    1 root     root          1057 Mar 15 12:44 cropped.html
drwx------    4 root     root          4096 Mar 15 11:55 images
-rw-r--r--    1 root     root          1006 Mar 15 12:27 index.html
drwx------    2 root     root          4096 Mar  2 12:42 styles
```

- Issue persists.
- **ORDER OF OPERATIONS MATTER**, may be causing these issues due to completely muddling up the order multiple times. Get the base image you want, setup the dockerfile, build your image, deploy/run the container, test. If issues are happening you need to start FROM THE BEGINNING. Because I have been messing up the order sometimes I cannot be sure what worked/what didnt work as I am not sure what tests I followed the correct order.
- Remember WORKDIR in the dockerfile, allows you to specify where you want your working directory to be.
- Remember CMD, different then RUN in the dockerfile, just look up different dockerfile stuff to do.
- Pending...

## Part 1: Return of the Containers

- After another half hour of testing, this is where we are at...

Dockerfile
```text
FROM nginx:1.10.1-alpine
COPY 4980_testsite /usr/share/nginx/html
RUN chmod -R 777 /usr/share/nginx/html
EXPOSE 8080
```

Environment
```text
jacob@lappy:~/proj4test$ pwd
/home/jacob/proj4test
jacob@lappy:~/proj4test$ ls -l
total 8
drwx------ 4 jacob jacob 4096 Mar  2 08:06 4980_testsite
-rw-r--r-- 1 jacob jacob  118 Mar 19 14:59 Dockerfile
```

- Ran command `sudo docker build -t myimage .`. This command builds the "myimage" image using the Dockerfile in the working directory. The Dockerfile contains commands that basically pull from the base image and make your personal alterations. The product "myimage" will be the base image you pulled from in the Dockerfile (in this case nginx:1.10.1-alpine) plus the alterations you made (in this case, adding my site files to a specific directory, changing ownership and permissions on those files, and exposing port 8080 so it can receive http requests. NOTE exposing the port is not all, the command to deploy the container you need to specify that port again)
- Successfully created images, confirmed in now appears in the list of images.
- Ran command `docker run -d --name mycontain -p 8080:80 myimage`. This command deploys the container "mycontain" using the image I built in the earlier command. That container is serving web content on port 8080.
- No errors, appears to have started.
- In my browser on my local machine, went to localhost:8080

![WORKING](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/6aabd952-868b-4131-8065-f54c08967dc0)
![WORKING2](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/31cb8516-8a7c-418e-9792-52c8b63a9ce7)
![WORKING3](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/20d6b41b-cd4a-42ec-ba38-c06d41e991fe)
I know this last one says exited, thats because at the point of taking this screenshot I had exited that container.

- Links and CSS appear to be working. Ran command `sudo docker logs mycontain` and logs appear clean, only http requests.
- Still, the issue persists where it is not copying the directory, it is copying the directory contents, see below...

```text
jacob@lappy:~/proj4test$ sudo docker run --rm myimage ls -l /usr/share/nginx/html
total 32
-rwxrwxrwx    1 root     root           537 Oct 18  2016 50x.html
-rwxrwxrwx    1 root     root           969 Mar 15 11:57 base.html
-rwxrwxrwx    1 root     root          1057 Mar 15 12:44 cropped.html
drwxrwxrwx    1 root     root          4096 Mar 15 11:55 images
-rwxrwxrwx    1 root     root          1006 Mar 15 12:27 index.html
drwxrwxrwx    1 root     root          4096 Mar  2 12:42 styles
```

- The links and CSS being broken was a permissions issue, I set the permissions to 777 but I think you could get away with 755 or 750, not sure. Basically the CSS and images were in directories and whatever user, I assume www-data, did not have access to those directories.
- I thought in my previous testing I had fixed that by running chmod and chown commands in my dockerfile, but either I messed it up or did not build a fresh image with the chmod and chown commands added, not sure.
- Removed my container and image and tried again with a Dockerfile where I tried to change the owner and group to www-data. Error, user does not exist. Checked Dockerhub nginx documentation https://hub.docker.com/_/nginx. Apparently they use the user nginx.
- Tried again with slight changes to Dockerfile. This time it worked, see below Dockerfile that now makes a little more sense in terms of not giving rwx access to literally everyone.

Last version of Dockerfile that is working well enough, still not sure why its copying 4980_testsite contents and not the directory itself.
```text
FROM nginx:1.10.1-alpine
COPY 4980_testsite /usr/share/nginx/html
RUN chown -R nginx:nginx /usr/share/nginx/html
RUN chmod -R 750 /usr/share/nginx/html
EXPOSE 8080
```

- Confirmed this worked by navigating to localhost:8080 and making sure the links and CSS was working.

## Part 1: Frequent commands
Run this command in the directory with your dockerfile to create your image using the dockerfile: `sudo docker build -t <IMAGE_NAME> .`

Run this command to build/deploy container: `docker run -d --name <CONTAINER_NAME> -p 8080:80 <IMAGE_NAME>`

Run this command to view running containers: `sudo docker ps`

Run this command to view ALL containers running and stopped: `sudo docker ps -a`

Run this command to stop container that was deployed: `sudo docker stop <CONTAINER_NAME>`

Run this command to view files in image: `sudo docker run --rm <IMAGE_NAME> ls -l /file/path`

Run this command to view container logs: `sudo docker logs <CONTAINER_NAME>`

Run this command to view images: `sudo docker images`

Run this command to remove images (-f to force): `sudo docker rmi <IMAGENAME>`

Run this command to burn the mound of dead containers: `sudo docker container prune`

## Part 1: Resources used

https://docs.docker.com/engine/install/ubuntu/ Site used to install Docker in WSL Ubuntu

https://www.docker.com/resources/what-container/ Site used to define what a container is

https://docs.docker.com/reference/dockerfile/ Site used to define what a Dockerfile is

https://medium.com/nerd-for-tech/deploy-a-custom-nginx-docker-image-and-push-it-to-docker-hub-118f1ab2186b Initial test for building webserver container

https://docs.docker.com/reference/dockerfile/ Dockerfile reference material

https://hub.docker.com/_/nginx nginx container image info

# Part 2: GitHub Actions and DockerHub

## Part 2: Overview

For part 2 of this project, the goals are to...
1. Create a free Dockerhub account.
2. Create a public repo in Dockerhub.
3. Setup GitHub Secrets per specification.
4. Setup GitHub Actions workflow per specification.

## Part 2: Process documentation

- Setup free Dockerhub account at https://hub.docker.com/

![dockerhubaccount](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/9e480b52-3196-47d1-9182-621e15df77c6)

- Selected Create a Repository. See below screenshot for details.

 ![pubrepo](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/4a7c39b3-b5cf-4aa2-9e96-c1fc7649419a)

- Link to repo https://hub.docker.com/repository/docker/thornburyjac/sp2024-ceg3120-proj/general
- Navigated to this repo's settings > secrets and variables > actions > new repo secret. See below...

![githubactions](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/41fad4f6-62aa-4445-b8df-12533e5adfda)

- Set up DOCKER_USERNAME and DOCKER_PASSWORD with their values set accordinlgy. See below...

![secretusername](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/32c80af7-d09c-4c23-a188-4431b8c7687e)

- Navigated to this repo's Actions > Skip this and set up a workflow yourself. See below...

![setupwork](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/de242023-77d2-4ca7-9048-f0f5eef6ddc0)

- This brings us to a new workflow file. From the links I looked at (see resources used section) the file will be a YAML file that specifies the workflow.
- Copied one of the templates from the links. See below...

```text
name: proj4workflow

on:
  release:
    types: [published]

jobs:
  push_to_registry:
    name: Push Docker image to Docker Hub
    runs-on: ubuntu-latest
    steps:
      - name: Check out the repo
        uses: actions/checkout@v4

      - name: Log in to Docker Hub
        uses: docker/login-action@f4ef78c080cd8ba55a85445d5b36e214a81df20a
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Extract metadata (tags, labels) for Docker
        id: meta
        uses: docker/metadata-action@9ec57ed1fcdbf14dcef7dfbe97b2010124a938b7
        with:
          images: thornburyjac/sp2024-ceg3120-proj

      - name: Build and push Docker image
        uses: docker/build-push-action@3b5e8027fcad23fda98b2e3ac259d8d67585f671
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
```

- In this YAML all I changed was the name, and added my Dockerhub namespace and repo thornburyjac/sp2024-ceg3120-proj where the template has my-docker-hub-namespace/my-docker-hub-repository
- See below screenshot...

![workflowcompl](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/e182602d-410a-4277-ab6c-400fd103daec)

- Pending push test.

## Part 2: Pushing to Dockerhub with and without Github Actions

### Part 2: Using command line to push to Dockerhub
- Just pushing from a command line environment should be creating an image, and then running the command `docker push DOCKERHUB-USERNAME/IMAGE-YOU-CREATED`
- Navigated to the directory where I have my Dockerfile.
- Ran command `sudo docker build -t proj4image .`
- Confirmed image created.
- Attempted command `docker push thornburyjac/proj4image` but received an error. Realized I was attempting to push thornburyjac/proj4image but my image was called just proj4image.
- Ran command `sudo docker tag proj4image:latest thornburyjac/proj4image:latest` to rename the image and reran push command.
- Error access denied. Needed to first run `docker login` command to authenticate, then reran push command.
- See screenshots...

![commmandout](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/b19c28cf-c98f-4a7c-aff1-f9f2373da726)
![commandout2](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/ae8a4974-7bbc-43db-9b9b-befd19048546)

- Realized I had pushed it to its own repo, instead of the repo I had created.
- Ran command `docker tag proj4image:latest thornburyjac/sp2024-ceg3120-proj:latest`
- Ran command `docker push thornburyjac/sp2024-ceg3120-proj:latest`
- Confirmed it was in the right repo, see below screenshots...

![commmandout3](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/897f61f6-2a6a-436c-9a2e-70b958a65454)
![imageindocker](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/9b7132a4-1c30-40ba-9d4a-a09958b8476e)

### Part 2: Using Github Actions to push to Dockerhub
- Going over my workflow, I am not sure how to start it.
- Per https://docs.docker.com/build/ci/github-actions/ which seems easier to use, I changed my workflow to...

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
          password: ${{ secrets.DOCKERHUB_PASSWORD }}
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

- All I changed was the last tag to add "sp2024-ceg3120-proj" instead of the provided example text "clockbox"
- Renamed and replaced my previous workflow with this.
- Added Dockerfile to the ./ directory of this repo since that is where the workflow is looking. I probably could have it look in my Dockerfiles folder but for this initial test this is fine.
- Committed changes to this README to see if it would push the image to Dockerhub.
- Errors regarding authentication, see below...

![image](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/cf0416c6-2f80-44d5-96c9-61373c12a2ba)

- Setup a access token on Dockerhub. See below...

![image](https://github.com/WSU-kduncan/s24cicd-thornburyjac/assets/111811243/87bfe380-f2b1-4c4d-ab48-0c26de01b6ee)

- Updated workflow to look for DOCKERHUB_TOKEN and added the token that was generated from Dockerhub as the value.
- 

## Part 2: Resources used

https://docs.docker.com/build/ci/github-actions/

https://github.com/marketplace/actions/build-and-push-docker-images

https://docs.github.com/en/actions/publishing-packages/publishing-docker-images#publishing-images-to-docker-hub **This is the YAML file template I used.**
