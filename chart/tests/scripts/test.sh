#!/bin/bash
set -ex

# set credentials
git config --global user.email ${GITLAB_EMAIL}
git config --global user.name ${GITLAB_USER}
git config --global user.password ${GITLAB_PASS}
crane auth login ${GITLAB_REGISTRY} -u ${GITLAB_USER} -p ${GITLAB_PASS}

echo "cloning repo..."
git clone ${GITLAB_REPOSITORY}/${GITLAB_USER}/${GITLAB_PROJECT}.git

echo "changing into repo directory..."
cd ${GITLAB_PROJECT}

echo "modifying repo..."
touch Dockerfile
echo "FROM alpine" > Dockerfile

echo "pushing changes to repo..."
git add Dockerfile
git commit -m 'initial commit'
git remote rm origin
git remote add origin ${GITLAB_ORIGIN}/${GITLAB_USER}/${GITLAB_PROJECT}.git
git checkout -b test
git push -u origin test

echo "pulling image..."
crane pull alpine:latest alpine-latest.tar

echo "pushing image to gitlab registry..."
crane push alpine-latest.tar ${GITLAB_REGISTRY}/${GITLAB_USER}/${GITLAB_PROJECT}/alpine:latest

echo "All tests complete!"