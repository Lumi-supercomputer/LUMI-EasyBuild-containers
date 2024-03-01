#! /usr/bin/env bash

projectid="462000394"

repo="lumi-${projectid}-private"

echo "Backing up /appl/local/containers/easybuild-sif-images to $repo:easybuild-sif-images..."

module load lumio-ext-tools

rclone mkdir "${repo}:easybuild-sif-images/"
rclone copy "/appl/local/containers/easybuild-sif-images/" "$repo:easybuild-sif-images/"
