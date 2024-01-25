#!/bin/bash
# it's not /usr/local/bin/bash on github
# shellcheck disable=SC2155

tmpdir=$(mktemp -d)
base_pipeline="base-pipeline.yml"

cp -rp ".github/workflows/${base_pipeline}" "${tmpdir}"
pipeline="${tmpdir}/${base_pipeline}"
params="params.yml"
cp -rp ".github/${params}" "${tmpdir}"
params="${tmpdir}/${params}"
