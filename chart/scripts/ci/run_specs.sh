#!/bin/bash
set -e

if [[ -n "${VARIABLES_FILE}" ]]; then
  source "${VARIABLES_FILE}"
  ./scripts/ci/feature_spec_setup.sh
else
  ./scripts/ci/integration_spec_setup.sh
fi

bundle config set --local path 'gems'
bundle config set --local frozen 'true'
bundle install -j $(nproc)

# For tests not being run on a cluster, use knapsack for parallelizing
if [[ "${RSPEC_TAGS}" == "~type:feature" ]] && [[ "${KNAPSACK_GENERATE_REPORT}" != "true" ]]; then
  bundle exec rake "knapsack:rspec[--color --format documentation --tag '${RSPEC_TAGS}']"
else
  bundle exec rspec -c -f d spec -t "${RSPEC_TAGS}"
fi
