  inner_work_reana:
    run: reana
    in:
      opt_inDS: inner_work_deriv/outDS
      opt_containerImage:
        default: docker://gitlab-registry.cern.ch/zhangruihpc/iddsal:atlas-reana-submitter
      opt_exec:
        default: "source script_reana.sh pchain_ZZ %{DS0}"
      opt_args:
        default: "--site CERN --outputs output_from_reana.tar --useSecrets"
    out: [outDS]
