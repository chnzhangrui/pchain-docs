
.. _run_image:

Run an image
------------------------------------

Before deploying the image or share it with other people, it is better to test the image.
We will discuss how to run an image based on the two ways you have built it: on your local machine or on GitLab.

On your local machine
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you have an image locally, run it with:

.. code-block:: console
    
	docker run -it --rm -v "$(pwd)":/workarea <docker name:tag> /bin/bash

If the image is available on GitLab, run it with:

.. code-block:: console

	docker login gitlab-registry.cern.ch -u {lxplus_account} -p {lxplus_password}
    docker run --rm -it -v "$(pwd)":/workarea <gitlab-registry.cern.ch/zhangruihpc/iddsal:atlas-reana-submitter> /bin/bash

Replace ``<gitlab-registry.cern.ch/zhangruihpc/iddsal:atlas-reana-submitter>`` with your desired image name and tag.

The option ``-v "$(pwd)":/workarea`` mount the current folder ``$(pwd)`` to ``/workarea`` inside the container.

Since the container is just an instance of the image, changing the contents in the container will not change the image.
You are free to save output files to anywhere inside the container but they will be gone when you quit the container.
By mounting ``$(pwd)`` to ``/workarea``, you will be able to store outputs to ``/workarea`` inside the container and still have access to them outside.

To quit the image, type ``exit`` or ``Ctrl+D``.

At the first time running the image, the image file will be pulled.
The next time starting a container instance will be quicker.
However, if the image on GitLab is updated (with the same tag), you will have to update it manually by:

.. code-block:: console

    docker pull <gitlab-registry.cern.ch/zhangruihpc/iddsal:atlas-reana-submitter>

The changes will be pulled and once it is done the new image will be used if you run ``docker run``.

For major changes, it is better to create new images with a different tag.

On LXPLUS
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

On LXPLUS, two options are available to run an image:

.. code-block:: console

    # option 1
    /cvmfs/atlas.cern.ch/repo/containers/sw/apptainer/x86_64-el7/1.0.2/bin/apptainer exec gitlab-registry.cern.ch/zhangruihpc/iddsal:atlas-reana-submitter /bin/bash

    # option 2
    singularity shell -B /afs -B /eos -B /cvmfs gitlab-registry.cern.ch/zhangruihpc/iddsal:atlas-reana-submitter
