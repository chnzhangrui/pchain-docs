
.. _jobOption:

Parametrise signal MC jobOption
------------------------------------------------
You must have a jobOption script to generate the signal events you would like to study.
This `repository <https://gitlab.cern.ch/atlas-physics/pmg/mcjoboptions>`_ stores ATLAS official MC jobOptions (accessible from ATLAS internal).
Go and look for the one you want to perform active learning on, or ask your MC contact to provide it for you.

In the official jobOption file, values of some key parameters are defined in the file by hardcoding.
For example in the `DSID 503000 <https://gitlab.cern.ch/atlas-physics/pmg/mcjoboptions/-/blob/master/503xxx/503000/mc.MGPy8EG_hh_bbtt_vbf_novhh_lh_l2cvv1cv1.py>`_ jobOption, the Higgs mass is set to 125 GeV by this line:

.. code-block:: python
    :linenos:
    :lineno-start: 33

    parameters['MASS']={'25':'1.250000e+02'} #MH 

It is not flexible if one wants to study different Higgs mass hypotheses via active learning.
Instead, one could replace this line by the following lines (note that either ``string`` or ``float`` is acceptable by the jobOption):

.. code-block:: python
    
    import os
    parameters['MASS']={'25': float(os.environ['envMyHiggsMass'])}


So the job option is parametrised by the shell environment variable ``envMyHiggsMass``.
This variable needs to be defined with proper values - you will learn how to do it in :ref:`cwl_main`.
