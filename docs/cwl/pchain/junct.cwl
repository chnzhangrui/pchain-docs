  checkpoint:
    run: junction
    in:
      opt_inDS: inner_work_reana/outDS
      opt_containerImage:
        default: docker://gitlab-registry.cern.ch/zhangruihpc/steeringcontainer:0.0.7
      opt_exec:
        default: "bash script_junction.sh %{i} %{DS0} %{myparamMZD} %{myparamMHD}"
      opt_args:
        default: "--site CERN --outputs 'results.json,history.json' --persistentFile history.json --forceStaged"
    out: [outDS]
