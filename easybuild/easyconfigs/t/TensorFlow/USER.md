# Tensorflow container user instructions

**BETA VERSION, problems may occur and may not be solved quickly, 
and the documentation needs further development.**

The TensorFlow container is developed by AMD specifically for LUMI and contains the
necessary parts to run TensorFlow on LUMI, including the plugin needed for RCCL when
doing distributed AI, and a suitable version of ROCm for the version of TensorFlow.
Horovod is also provided, with support for Cray MPI.


## Use via EasyBuild-generated modules

The EasyBuild installation with the EasyConfigs mentioned below will do three things:

1.  It will copy the container to your own file space. We realise containers can be
    big, but it ensures that you have complete control over when a container is
    removed again.
    
    We will remove a container from the system when it is not sufficiently functional
    anymore, but the container may still work for you. E.g., after an upgrade of the 
    network drivers on LUMI, the RCCL plugin for the LUMI Slingshot interconnect may be broken,
    but if you run on only one node TensorFlow may still work for you.

    If you prefer to use the centrally provided container, you can remove your copy 
    after loading of the module with `rm $SIF` followed by reloading the module. This
    is however at your own risk. 

2.  It will create a module file. 
    When loading the module, a number of environment variables will
    be set to help you use the module and to make it easy to swap the module with a
    different version in your job scripts.
    
    -   `SIF` and `SIFTENSORFLOW` both contain the name and full path of the singularity
        container file.
        
    -   `SINGULARITY_BIND` will mount all necessary directories from the system,
        including everything that is needed to access the project, scratch and flash
        file systems.
        
    -   `RUNSCRIPTS` and `RUNSCRIPTSTENSORFLOW` contain the full path of the directory
        containing some sample run script(s) that can be used to run software in the 
        container, or as inspiration for your own variants.
        
3.  It creates currently 1 script in the $RUNSCRIPTS directory:

    -   `conda-python-simple`: This initialises Python in the container and then calls Python
        with the arguments of `conda-python-simple`. It can be used, e.g., to run commands
        through Python that utilise a single task but all GPUs.
        
4.  It creates a `bin` directory with scripts to be run outside of the container:

    -   `start-shell`: Serves a double purpose:
    
        -   Without further arguments, it will start a shell in the container with 
            the Conda environment used to build the container activated.
            
        -   With arguments it simply runs a shell in the container, but the Conda 
            environment will not be activated.
            
    The `bin` directory is not mounted in the container, but if you would, the 
    scripts would recognise this and work or print a message that they cannot 
    be used in that environment.
        
The container uses a miniconda environment in which Python and its packages are installed.
That environment needs to be activated in the container when running, which can be done
with the command that is available in the container as the environment variable
`WITH_CONDA` (which for this container is
`source /opt/miniconda3/bin/activate tensorflow`).

The container (when used with `SINGULARITY_BIND` of the module) also provides
the wrapper script `/runscripts/conda-python-simple` to start the Python command from the
conda environment in the container. That script is also available outside the 
container for inspection after loading the module as
`$RUNSCRIPTS/conda-python-simple` and you can use that script as a source
of inspiration to develop a script that more directly executes your commands or
does additional initialisations.

Example (in an interactive session):

```
salloc -N1 -pstandard-g -t 10:00
module load LUMI TensorFlow/2.16.1-rocm-6.2.0-python-3.10-horovod-0.28.1-singularity-20241007
srun -N1 -n1 --gpus 8 singularity exec $SIF /runscripts/conda-python-simple \
    -c 'import tensorflow'
```
(and the warning shown about being built with the oneAPI Deep Neural Network Library
is just a warning, as AVX2 and FMA are indeed the instructions that should be used 
on the LUMI CPUs).

After loading the module, the docker definition file used when building the container
is available in the `$EBROOTTENSORFLOW/share/docker-defs` subdirectory. As it requires some
licensed components from LUMI and some other files that are not included, it currently
cannot be used to reconstruct the container and extend its definition.

!!! Note "Checking the packages in the container"
    After installing and loading the module, run
    ```
    start-shell /runscripts/conda-python-simple -m pip list
    ```


### Installation

To install the container with EasyBuild, follow the instructions in the
[EasyBuild section of the LUMI documentation, section "Software"](https://docs.lumi-supercomputer.eu/software/installing/easybuild/),
and use the dummy partition `container`, e.g.:

```
module load LUMI partition/container EasyBuild-user
eb TensorFlow-2.16.1-rocm-6.2.0-python-3.10-horovod-0.28.1-singularity-20241007.eb
```

To use the container after installation, the `EasyBuild-user` module is not needed nor
is the `container` partition. The module will be available in all versions of the LUMI stack
and in [the `CrayEnv` stack](https://docs.lumi-supercomputer.eu/runjobs/lumi_env/softwarestacks/#crayenv)
(provided the environment variable `EBU_USER_PREFIX` points to the right location).


## Direct access (use without the container module)

The Tensorflow containers are available in the following subdirectories of `/appl/local/containers`:

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
system files are needed for, e.g., MPI. The recommended minimal bindings are:

```
-B /var/spool/slurmd,/opt/cray/,/usr/lib64/libcxi.so.1
```

and the bindings you need to access the files you want to use from `/scratch`, `/flash` and/or `/project`.
You can get access to your files on LUMI in the regular location by also using the bindings

```
-B /pfs,/scratch,/projappl,/project,/flash,/appl
```

Note that the list recommended bindings may change after a system update or between 
different containers. We do try to keep the EasyBuild recipes for the modules 
up-to-date though to reflect those changes.

