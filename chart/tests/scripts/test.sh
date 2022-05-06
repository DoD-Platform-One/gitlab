#!/bin/bash
set -ex

export HOME=/test

echo "cloning repo..."
git clone ${GITLAB_REPOSITORY}/${GITLAB_USER}/${GITLAB_PROJECT}.git

echo "changing into repo directory..."
cd ${GITLAB_PROJECT}

# set credentials
git config --local user.email ${GITLAB_EMAIL}
git config --local user.name ${GITLAB_USER}
git config --local user.password ${GITLAB_PASS}

/go/bin/crane auth login ${GITLAB_REGISTRY} -u ${GITLAB_USER} -p ${GITLAB_PASS}

echo "modifying repo..."
touch Dockerfile
echo "FROM alpine" > Dockerfile

echo "pushing changes to repo..."
git add Dockerfile
git commit -m 'initial commit' --allow-empty
git remote rm origin
git remote add origin ${GITLAB_ORIGIN}/${GITLAB_USER}/${GITLAB_PROJECT}.git
export testbranch=test-$RANDOM
git checkout -b $testbranch
git push -u origin $testbranch

echo "pulling image..."
/go/bin/crane pull alpine:latest alpine-latest.tar

echo "pushing image to gitlab registry..."
/go/bin/crane push alpine-latest.tar ${GITLAB_REGISTRY}/${GITLAB_USER}/${GITLAB_PROJECT}/alpine:latest

echo "All tests complete!"