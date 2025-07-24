#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_ROOT="$(dirname -- "${SCRIPT_DIR}"/..)"

pushd $PROJECT_ROOT

export KNAPSACK_GENERATE_REPORT="true"
export KNAPSACK_REPORT_PATH="knapsack_rspec_report.json"
export RSPEC_TAGS="~type:feature"

./scripts/ci/run_specs.sh

popd
