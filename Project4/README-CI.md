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

## Part 1: Resources used

https://docs.docker.com/engine/install/ubuntu/ Site used to install Docker in WSL Ubuntu

https://www.docker.com/resources/what-container/ Site used to define what a container is

https://docs.docker.com/reference/dockerfile/ Site used to define what a Dockerfile is

https://medium.com/nerd-for-tech/deploy-a-custom-nginx-docker-image-and-push-it-to-docker-hub-118f1ab2186b Initial test for building webserver container

