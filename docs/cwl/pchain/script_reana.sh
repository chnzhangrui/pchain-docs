#!/bin/bash

job_name=$1
DAOD=$2

example=recast-zz
git clone https://gitlab.cern.ch/zhangruihpc/reana-zz.git ${example}
cd ${example}

## Update reana.yaml with corresponding dataset
\cp ../reana-template.yaml reana.yaml
sed -i "s|VAR_INPUT|$DAOD|g" reana.yaml

# connect to some REANA cloud instance and create a new workflow
export REANA_SERVER_URL=https://reana.cern.ch/
reana-client create -w $job_name
export REANA_WORKON=$job_name

echo "setup proxy for rucio:"
reana-client secrets-add --overwrite --file ../userkey.pem --file ../usercert.pem --env VOMSPROXY_PASS=<your_own_pass> --env VONAME=atlas

# delete the pem file from grid site after transferring to reana
rm -f ../keytab ../usercert.pem ../userkey.pem

reana-client upload
reana-client start
echo "get job_num immediately after submission in case other jobs submit a task with the same job_name"
job_num=`reana-client status --format NAME,RUN_NUMBER,STATUS | tr -s ' ' | cut -d " " -f 2 | sed -n 2p`
task_name=${job_name}.${job_num}
cd ../

# wait and download output results
while [[ $status != 'finished' ]]; do
    sleep 60
    status=`reana-client status --format NAME,RUN_NUMBER,STATUS | tr -s ' ' | cut -d " " -f 3 | sed -n 2p`
    echo new status: $status
    if [[ $status == 'failed' ]]; then
        break
    fi
done

echo "reana download"
reana-client download -w ${task_name}
tar -czvf output_from_reana.tar limit_stage/

# cleanup
rm -fr ${example}
