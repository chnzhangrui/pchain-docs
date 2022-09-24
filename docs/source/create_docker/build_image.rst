
.. _build_image:

Build an image
------------------------------------

We will introduce two ways to build an image: use your local laptop and docker desktop application or use GitLab.

Docker desktop
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

`Docker desktop <https://www.docker.com/products/docker-desktop/>`_ is an application to build an image from a Dockerfile.
Although it has a nice user-interface, we will use terminal to do the work.
Once you installed it and started it, the ``docker`` executable will be available.

.. code-block:: console

    $ which docker
    /usr/local/bin/docker

Go to your desired folder and run:

.. code-block:: console

    docker build -f docker/Dockerfile .

Check and delete containers and images:

.. code-block:: console

    docker image ls -a # Check available images
    docker container ls -a # Check available containers
    docker image rm <image_name> # Delete images
    docker rm <container_name> # Delete containers


GitLab Runner
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Besides other capabilities of the GitLab CI Runner, it is possible to build docker images.
As other tasks, you need to config this via the `.gitlab-ci.yml` file.
You should make this repository public.

.. _gitlab_ci_yml:
.. literalinclude:: ../../code/docker/gitlab-ci.yml
    :language: yaml
    :linenos:
    :emphasize-lines: 1,10
    :caption: An example of .gitlab-ci.yml

The code is largely reusable for any image building.
The customised bits are:

- **L1** the CI job name that will only affect the CI interface, no impact on the image.
- **L10** ``CI_PROJECT_DIR`` is pre-defined home path for this repository, i.e. in this example is ``./iddsAL``. Therefore, ``./iddsAD/docker/Dockerfile`` is expected. ``CI_REGISTRY_IMAGE`` is pre-defined image path which in this example is ``gitlab-registry.cern.ch/zhangruihpc/iddsal``. The tag name ``atlas-reana-submitter`` is hardcoded in this YAML file, but you could use a GitLab CI variable instead.

Where to find the image on GitLab?
Go to the main page of the repository.
On the left tool bar, click [Packages & Registries] -> [Container registry].
You will see the name of the container; further click on the name to see the available tags.
You are free to delete the tags or the whole container.
After you push a new commit to the repo next time, it will rebuild the container based on your ``.gitlab-ci.yml``.

.. tip::

    GitLab CI variables can be defined for a gitlab repository.
    Go to the main page of the repository.
    On the left tool bar, click [Settings] -> [CI/CD] -> [Variables [Expand]] -> [Add variable].
    ``Key`` is the name of the variable that can be used in the ``.gitlab-ci.yml`` file with a ``$``.
