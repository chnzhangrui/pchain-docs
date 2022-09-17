.. _reana_workflow:

REANA workflow
------------------------------------

A physics analysis usually starts with derivation files (DAOD), which should have been produced after the derivation step in Section :ref:`cwl_main`.
An analysis may consist of several steps, for example first event selection to slim ntuples, then histogram creation for statistical analysis, and last limit setting.
These steps can form a workflow and can run either on Grid via PanDA, or on smaller clusters or even laptops for convenience.
In active learning, the computing resources required is higher than to perform a single analysis.
Therefore, we will use a medium scaled system `REANA <https://docs.reana.io>`_ for active learning.
First, let's refresh what we need to do from the figure below.

.. image:: ../../fig/pchain_loop_reana.jpg
  :width: 600
  :alt: Analysis chain

.. note::
   REANA is a reproducible analysis platform.
   Currently, an instance at CERN (https://reana.cern.ch) is running.
   In the future, more instances may become available.
   You need to apply for a user account before using the CERN instance as it is now still under development and not open to everyone.

.. note::
   The real work that is running on REANA should be performed in containers.
   For more information about container and docker image, see `Docker Doc <https://docs.docker.com/get-started/overview/>`_.
   It is a dedicated topic to create containers for your analysis code.
   For now, let's assume that you know what container is and how to containerise your analysis code.

REANA supports several workflow languages such as CWL, Serial, Yadage, and Snakemake.
We will take CWL as an example since we should be familiar with it now.

Basic
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
A few examples can be found in the `REANA Doc <https://docs.reana.io/getting-started/>`_ .
However, these examples collect analysis code and REANA configurations together and have some repetition scripts to show the syntax for different computing backends.
To make it simple, one can refer to the `ATLAS HDBS-2018-55 example <https://gitlab.cern.ch/zhangruihpc/reana-zz/-/tree/demonstrate>`_.
It only contains three files:

::

    ├── reana.yaml
    └── specs
        ├── steps.yml
        └── workflow.yml
    1 directory, 3 files

The REANA specification file is at the top level whose name has to be ``reana.yaml``.
Besides it, all other file and directory names are user-defined.
The specification file defines input data, output files, reference to the name of a file where the real workflow is defined (``specs/workflow.yml``), and resource options.
Note that in REANA, it is possible to mount ``cvmfs`` if you config it properly.

In the ``specs/workflow.yml`` file, four stages are defined.
Names of the stages are user-defined, and they can be used in ``dependencies`` to indicate the workflow order.
Let's go through one of the stage line by line and explain what each line does.

.. code-block:: yaml
    :linenos:

    - name: ntuple_stage
        dependencies: [rucio_download]
        scheduler:
            scheduler_type: singlestep-stage
        parameters:
            local_dr: {step: rucio_download, output: pub_local_dr}
            outputfile: '{workdir}/my.output.root'
        step: {$ref: 'specs/steps.yml#/ntupleselection'}

- **L1** defines the name of the stage.
- **L2** configs that this stage will start after ``rucio_download`` stage finishes.
- **L3-4** is related to job scheduling that users usually do not care about.
- **L5-7** defines two local variables called ``local_dr`` and ``outputfile``. They will be used in ``specs/steps.yml``. The value of ``local_dr`` is defined by the local parameter ``pub_local_dr`` in the previous step; so it can dynamically change according to the previous output. The value of ``outputfile`` is ``{workdir}/my.output.root``. In REANA, variables are called by ``{variable_name}`` and ``{workdir}`` is pre-defined variable **in scheduler block** storing a common path where all the stages have access to. Therefore it is very useful share files between stages.
- **L8** is a reference to a code block in ``specs/steps.yml``.

The real executions are defined in ``specs/steps.yml``.
In that file, the commands under ``script`` are closely related to your analysis container except the first one that is dedicated to downloading DAOD via Rucio.
The rest of the part are output files (in ``publisher:publish``) and the container (in ``environment:image``).
In order to use Rucio, one needs to not only enable ``voms_proxy: true``, but also provide your Grid certificate as `REANA secretes <https://docs.reana.io/reference/reana-client-cli-api/#secrets-add>`_.

.. tip::
   Try to use a large ``kubernetes_memory_limit`` as insufficient memory will lead to job failure and not always easy to notice.
   ``kubernetes_uid: 1000`` is used in all these examples as these containers happen to have the user ID as 1000. Check your own user ID in container by ``echo $UID``.

.. caution::
   Do not use ``{workdir}`` in the ``process`` block in ``specs/steps.yml`` - it will cause an error *KeyError: 'workdir'*.
   To get around the error, you could define a ``parameters`` in ``scheduler`` and use that parameter in ``process`` as shown in this example.

Use Rucio
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Currently REANA is not part of the ATLAS Grid and no native Rucio is installed on REANA.
However, we could run a container that has Rucio installed, download the DAOD we need (since they are only signal samples, the size will be affordable), and place them in ``{workdir}`` to share with the rest stages.
You can either make your own container or use this one (``gitlab-registry.cern.ch/zhangruiforked/reana-demo-atlas-recast-2:0.4``) as used in the above example.
To use Rucio, you need to config ``voms_proxy: true`` at that stage and provide a VOMS proxy (`instruction <https://docs.reana.io/advanced-usage/access-control/voms-proxy/>`_) before submitting REANA tasks.

Integrate to pchain
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
A standalone REANA workflow can be submitted from `lxplus` as illustrated in the `example <https://docs.reana.io/getting-started/first-example/>`_ of REANA.
But our goal is to run the REANA step seamlessly with the production chain that is running on Grid.
One solution is to let PanDA do the submission on behalf of users.
A better scheme may be worked out in the future with both the PanDA team and the REANA team involved, while right now, this simple scheme works fine.
To use this solution, we can simply to the following.
We append following lines to the end of the :ref:`CWL code<pchain_cwl_code>` (continue in ``steps`` block as an additional step).

.. _pchain_cwl_code2:
.. literalinclude:: ../../cwl/pchain/reana.cwl
    :language: yaml
    :linenos:
    :caption: REANA step in pchain

The output dataset from ``inner_work_deriv`` step is taken, i.e. the DAOD, whose name is hold by ``%{DS0}``.
The job will run in a container ``gitlab-registry.cern.ch/zhangruihpc/iddsal:atlas-reana-submitter`` in which REANA related libraries are installed.
You can use it for your own task too.
It will run a script and the output given by ``--outputs`` will be staged out (upload to Rucio).
You may notice ``--useSecrets`` in the argument list.
We use the `PanDA secrete <https://panda-wms.readthedocs.io/en/latest/client/secret.html>`_ feature to tell PanDA our ``REANA_ACCESS_TOKEN`` so that it can submit REANA task on behalf of us.
That said, before running ``pchain`` workflow, one must create PanDA secrets.
Follow the instruction from the above link.
Here are the secretes you will need:

.. code-block:: console

    $ pbook
    >>> list_secrets()
    Key                : Value
    ------------------ : --------------------
    REANA_ACCESS_TOKEN : **********
    usercert.pem       : **********
    userkey.pem        : **********

- `REANA_ACCESS_TOKEN` is the token you will get along with your REANA account.
- `usercert.pem` and `userkey.pem` are the Grid certificate to Rucio download on REANA. They are not directly used by PanDA and PanDA will pass these secrets to REANA secretes as shown in later ``script_reana.sh`` **L20**.

All the rest magic is in the ``script_reana.sh`` script, which takes a string of ``prod_ZZ`` and the DAOD name, and outputs ``output_from_reana.tar``.
Let's peek what's inside this script.

.. _pchain_script_reana:
.. literalinclude:: ../../cwl/pchain/script_reana.sh
    :language: bash
    :linenos:
    :emphasize-lines: 11,12,32-40
    :caption: script_reana.sh

This is just an example and you can replace it by your own.
However, you may find the highlight blocks unusual w.r.t. the example from REANA.
In the first highlighted block, we actually secretly replaced the ``reana.yaml`` file by a template which contains a placeholder as input.
This block of code will insert the proper DAOD name.
The second highlight block periodically check whether the REANA task is done and download the output from the REANA workflow when it is finished.
In our example, this output is a folder called ``limit_stage`` inside of which are a couple of text files.
The whole folder is compressed to ``output_from_reana.tar`` and will be staged out (rucio upload) at the end of the job (if you remember, we had ``--outputs output_from_reana.tar`` in **L10** of :ref:`CWL file<pchain_cwl_code2>`.)

