.. _Create_your_own_container:

Create docker container
===================================
Container is a technique to preserve a full operating system and services in a deliverable and shareable file (docker image).
Some application scenarios includes that you want to share the same computing environments to someone else to reproduce your results, or you want to deploy hundreds of jobs across hundreds of nodes from the exact computing environment where your R&D happened.
If you have used commercial cloud such as AWS, Google Cloud, etc, you will probably already used a container regardless of your awareness.

Let's clarify a few terminologies before moving forward:

- Docker vs Singularity: People often say "docker container" but docker is not the only format available for the container techniques. On High Performance Computers, or LXPLUS, singularity is installed. They have different formats but singularity can build its container from a docker image.
- Container vs Image: A container is a runnable instance of an image. What we will learn in this section is to create a docker image file, store it somewhere, and use it in other machines to run our applications inside a container instance. In the following, image, docker image, container, and docker container will be interchangeable unless stated elsewhere.

We will discuss the following topics:

.. toctree::
   :maxdepth: 1

   docker_file
   build_image
   run_image
   other_types_image