#!/bin/bash
set -ex

# set credentials
git config --global user.email "testuser@example.com"
git config --global user.name "testuser"
git config --global user.password "12345678"
crane auth login gitlab-registry-test-svc.gitlab.svc.cluster.local:80 -u "testuser" -p "12345678"

echo "cloning repo..."
git clone http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/testuser/my-awesome-project.git

echo "changing into repo directory..."
cd my-awesome-project

echo "modifying repo..."
touch Dockerfile
echo "FROM alpine" > Dockerfile

echo "pushing changes to repo..."
git add Dockerfile
git commit -m 'initial commit'
git remote rm origin
git remote add origin http://testuser:12345678@gitlab-webservice-default.gitlab.svc.cluster.local:8181/testuser/my-awesome-project.git
git push -u origin master

echo "pulling image..."
crane pull alpine:latest alpine-latest.tar

echo "pushing image to gitlab registry..."
crane push alpine-latest.tar gitlab-registry-test-svc.gitlab.svc.cluster.local:80/testuser/my-awesome-project/alpine:latest

echo "All tests complete!"