#!/usr/bin/env bash
set -e

STOP_PATCH="$1"
VERSION="helm-chart-4.12.2"

project_root="$(realpath $(dirname -- "${BASH_SOURCE[0]}")/..)"
cd $project_root

nginx_patch_dir="${project_root}/scripts/nginx-patches/"
nginx_chart_dir="${project_root}/charts/nginx-ingress/"

source_chart_dir="$(mktemp -d)"

echo "Checking out upstream repo to $source_chart_dir"
git clone --branch "$VERSION" --depth 1 https://github.com/kubernetes/ingress-nginx.git $source_chart_dir

echo "Dropping current NGINX chart"
rm -r $nginx_chart_dir

echo "Copying new NGINX chart sources"
mkdir $nginx_chart_dir
cp -r $source_chart_dir/charts/ingress-nginx/templates \
      $source_chart_dir/charts/ingress-nginx/*.yaml \
      $nginx_chart_dir

echo -e "This is a modified fork of https://github.com/kubernetes/ingress-nginx. Do not edit this chart manually." > $nginx_chart_dir/README.md

echo "Applying patches from $nginx_patch_dir"
for patch in $nginx_patch_dir*.patch; do
  if [[ "$STOP_PATCH" != "" && "$patch" =~ "$STOP_PATCH"_* ]]; then
      break
  fi

  echo "Applying $patch";
  git apply $patch
done

