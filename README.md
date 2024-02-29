# LUMI-EasyBuild-containers

This is a repository with EasyConfig files that make using the containers provided
through `/appl/local/containers` easier and safer.

Most EasyConfigs will not only create a module that sets appropriate bindings
so that they don't have to be added by hand, but will also copy the container
file to your local installation directory.

We realise those files can be big. Whenever indicated in the documentation
for the container, you can remove these files. But this is at the rist of the
user: There is no guarantee that the container will remain available in the
system directories. Container images are removed when they are simply old and
several newer versions are available, or when we know that there are problems
with them that are solved in newer versions.


## Developing new EasyConfigs

All development work should be done on a clone of the repositories, and to reduce 
the risk of accidentally removing an image file in /appl/local/containers/easybuild-sif-images,
a "clone" of this directory is made containing links to the image files in the main
repository. To this end we provide the script `link_images.sh` in the script directory
of this repository. It is sufficient to run that script from within the repository
to create or update that image directory. It will only update links and not replace
regular files that are placed in that directory.

All this is best combined with a clone of the software stack also for development,
but it is not necessary. It is necessory though to tell the EasyBuild configuration
modules where the repository can images can be found, and that is done by setting
the environment variable `LUMI_CONTAINER_REPOSITORY_ROOT` to the directory that
contains the clone of `LUMI-EasyBuild-containers` and the `easybuild-sif-images`
clone before loading those configuration modules.
