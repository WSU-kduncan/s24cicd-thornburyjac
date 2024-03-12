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

## Part 1: Resources used

https://docs.docker.com/engine/install/ubuntu/ Site used to install Docker in WSL Ubuntu

https://www.docker.com/resources/what-container/ Site used to define what a container is

https://docs.docker.com/reference/dockerfile/ Site used to define what a Dockerfile is

