
.. _docker_file:

The *Dockerfile*
------------------------------------

The only configuration file that is essential for creating a docker image is a text file called *Dockerfile*.
The name is conventional but you are free to name it differently when necessary.
Below is a simple Dockerfile example; let's go through it line by line and explain what each line does.

.. _docker_Dockerfile_base:
.. literalinclude:: ../../code/docker/Dockerfile_base
    :language: bash
    :linenos:
    :caption: An example of Dockerfile

- **L1** is the ancestor image from with name:tag format. Note: every image can inherit from other images so that you save time and effort to build and maintain the common part. When you build image, the builder service will look for `https://hub.docker.com <https://hub.docker.com>`_. So this image will build from `this image <https://hub.docker.com/layers/tensorflow/tensorflow/2.10.0/images/sha256-7f9f23ce2473eb52d17fe1b465c79c3a3604047343e23acc036296f512071bc9?context=explore>`_ (Go up by one level and check which tags are available).
- **L2** is optional to show the contact person of this image.
- **L4** defines a variable called ``PROJECT`` that is only available during the build of the docker image, in contrast of ``ENV`` variable that will be available after building (i.e. inside containers). You could see that this variable is used as the folder name where I will copy all local files to. If they include code, packages, data files, etc, they will be baked to the image and you will be able to access to them `inside` the container at ``/myHOME``.
- **L6-8** installs some linux packages.
- **L9** copy all files in the folder where you execute the docker building command.
- **L10-11** installs some python packages. As you can imagine, ``requirements.txt`` is a file that I copied over from local to the image. After **L9** it becomes available and I can use it.

With this Dockerfile (and the requirements.txt), you are ready to build an image.