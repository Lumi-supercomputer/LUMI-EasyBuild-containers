#! /usr/bin/env bash

imagedir="easybuild-sif-images"

# That cd will work if the script is called by specifying the path or is simply
# found on PATH. It will not expand symbolic links.
cd $(dirname $0)
cd ..
repo=${PWD##*/}
cd ..
installroot=$(pwd)
#echo "DEBUG: Detected repo = ${repo}, container installation directory ${installroot}"

if [[ "$installroot" ==  "/appl/local/containers" ]]; 
then 
    echo -e "This script is to help creating a clone of /appl/local/containers without copying all images,"
    echo -e "so it should never be run from /appl/local/containers/LUMI-EasyBuild-containers/scripts.\n"
    exit 1
fi

#
# Make sure the directory for the images exists
#
mkdir -p "$installroot/$imagedir"

#
# Remove existing links from $installroot/easybuild-sif-images
#
cd "$installroot/$imagedir"
#echo "DEBUG: In $PWD."

# As "lfs find" does not have the -exec option, we use a loop.
for file in $(lfs find . -maxdepth 1 -type l)
do
    /bin/rm -f $file
done

#
# Now create the new links
#
for file in $(lfs find /appl/local/containers/easybuild-sif-images -name "*.sif")
do
    ln -s $file ${file##*/}
done


