# ROCm container user instructions

**BETA VERSION, problems are possible and they may not be solved quickly.**

The rocm container is developed by AMD specifically for LUMI and contains the
necessary parts explore ROCm. The use is rather limited because at the moment
the methods that can be used to build upon an existing container are rather
limited on LUMI due to security concerns with certain functionality needed for 
that. The can however
[be used as a base image for cotainr](index.md#using-the-images-as-base-image-for-cotainr)
and it is also possible in some cases to extend them using the so-called
[SingularityCE "unprivileged proot build" process](https://docs.sylabs.io/guides/3.11/user-guide/build_a_container.html#unprivilged-proot-builds).

**It is entirely normal that some features in some of the containers will not work.
Each ROCm driver supports only particular versions of packages. E.g., the ROCm 
driver from ROCm 6.0.3 is only guaranteed to support ROCm versions between 5.6 and 
6.2 and hence problems can be expected with ROCm 5.5 or older and ROCm 6.3 or newer.
There is nothing LUMI
support can do about it. Only one driver version can be active on the system,
and installing a newer version depends on other software on the system also and
is not as trivial as it would be on a PC.**

## Use via EasyBuild-generated modules

The EasyBuild installation with the EasyConfigs mentioned below will do three things:

1.  It will copy the container to your own file space. We realise containers can be
    big, but it ensures that you have complete control over when a container is
    removed.
    
    We will remove a container from the system when it is not sufficiently functional
    anymore, but the container may still work for you.

    If you prefer to use the centrally provided container, you can remove your copy 
    after loading of the module with `rm $SIF` followed by reloading the module. This
    is however at your own risk. 

2.  It will create a module file. 
    When loading the module, a number of environment variables will
    be set to help you use the module and to make it easy to swap the module with a
    different version in your job scripts.
    
    -   `SIF` and `SIFROCM` both contain the name and full path of the singularity
        container file.
        
    -   `SINGULARITY_BINDPATH` will mount all necessary directories from the system,
        including everything that is needed to access the project, scratch and flash
        file systems.

3.  It will create the `runscripts` subdirectory in the installation directory that 
    can be used to store scripts that should be available in the container, and the
    `bin` subdirectory for scripts that run outside the container.

    Currently there is one script outside the container: `start-shell` will start a
    bash session in the container, and can take arguments just as bash. It is provided
    for consistency with planned future extensions of some other containers, but really
    doesn't do much more than calling

    ```
    singularity exec $SIFROCM bash
    ```

    and passing it the arguments that were given to the command.

    **Note that the installation directory is fully erased when you re-install the 
    container module using EasyBuild. So if you chose to use it to add scripts, make
    sure you store them elsewhere also so that they can be copied again if you 
    rebuild the container module for some reason.**


### Installation via EasyBuild

To install the container with EasyBuild, follow the instructions in the
[EasyBuild section of the LUMI documentation, section "Software"](https://docs.lumi-supercomputer.eu/software/installing/easybuild/),
and use the dummy partition `container`, e.g.:

```
module load LUMI partition/container EasyBuild-user
eb rocm-6.0.3-singularity-20241004.eb
```

To use the container after installation, the `EasyBuild-user` module is not needed nor
is the `container` partition. The module will be available in all versions of the LUMI stack
and in [the `CrayEnv` stack](https://docs.lumi-supercomputer.eu/runjobs/lumi_env/softwarestacks/#crayenv)
(provided the environment variable `EBU_USER_PREFIX` points to the right location).

## Direct access

The ROCm containers are available in the following subdirectories of `/appl/local/containers`:

-   `/appl/local/containers/sif-images`: Symbolic link to the latest version of the container
    for each ROCm version provided. Those links can change without notice!

-   `/appl/local/containers/tested-containers`: Tested containers provided as a Singulartiy `.sif` file
    and a docker-generated tarball. Containers in this directory are removed quickly when a new version
    becomes available.

-   `/appl/local/containers/easybuild-sif-images`: Singularity `.sif` images used with the EasyConfigs
    that we provide. They tend to be available for a longer time than in the other two subdirectories.

If you depend on a particular version of a container, we recommend that you copy the container to
your own file space (e.g., in `/project`) as there is no guarantee the specific version will remain
available centrally on the system for as long as you want.

When using the containers without the modules, you will have to take care of the bindings as some
system files are needed for, e.g., RCCL. The recommended minimal bindings are:

```
-B /var/spool/slurmd,/opt/cray/,/usr/lib64/libcxi.so.1
```

or, for those containers where MPI still fails to load due to a missing libjansson,

```
-B /var/spool/slurmd,/opt/cray/,/usr/lib64/libcxi.so.1,/usr/lib64/libjansson.so.4
```

and the bindings you need to access the files you want to use from `/scratch`, `/flash` and/or `/project`.
You can get access to your files on LUMI in the regular location by also using the bindings

```
-B /pfs,/scratch,/projappl,/project,/flash,/appl
```

Note that the list recommended bindings may change after a system update.


## Using the images as base image for cotainr

We recommend using these images as the base image for cotainr if you want to 
[build a container with cotainr](https://lumi-supercomputer-docs-preview.rahtiapp.fi/origin/pytorch/software/containers/singularity/#building-containers-using-the-cotainr-tool) 
that needs ROCm. You can use the `--base-image=<my base image>` flag of the `cotainr` command
to indicate the base image that should be used.

If you do so, please make sure that the GPU software you install from conda-forge or via `pip` 
with cotainr is compatible with the version of ROCm in the container that you use as the base
image.

??? Example "PyTorch with cotainr (click to expand)"
    To start, create a Yaml file to tell cotainr which software should be installed.
    As an example, consider the file below which we name `py312_rocm603_pytorch.yml`  

    ```yaml
    name: minimal_pytorch
    channels:
    - conda-forge
    dependencies:
    - filelock=3.15.4
    - fsspec=2024.9.0
    - jinja2=3.1.4
    - markupsafe=2.1.5
    - mpmath=1.3.0
    - networkx=3.3
    - numpy=2.1.1
    - pillow=10.4.0
    - pip=24.0
    - python=3.12.3
    - sympy=1.13.2
    - typing-extensions=4.12.2
    - pip:
        - --extra-index-url https://download.pytorch.org/whl/rocm6.0/
        - pytorch-triton-rocm==3.0.0
        - torch==2.4.1+rocm6.0
        - torchaudio==2.4.1+rocm6.0
        - torchvision==0.19.1+rocm6.0
    ```

    Now we are ready to generate a new Singularity `.sif` file with this defintion:

    ```bash
    module load LUMI
    module load cotainr
    cotainr build my-new-image.sif --base-image=/appl/local/containers/sif-images/lumi-rocm-rocm-6.0.3.sif --conda-env=py312_rocm603_pytorch.yml
    ```

    As we are using a PyTorch wheel for ROCm 6.0, we use the container image for ROCm 6.0.3.

    You're now ready to use the new image with the direct access method. As in this example we installed
    PyTorch, the information on the [PyTorch page](../../p/PyTorch/) page in this guide is also very
    relevant. And if you understand very well what you're doing, you may even adapt one of the EasyBuild
    recipes for the PyTorch containers to use your new image and install the wrapper scripts etc. that 
    those modules provide (pointing EasyBuild to your image with the `--sourcepath` flag of the `eb` 
    command).

