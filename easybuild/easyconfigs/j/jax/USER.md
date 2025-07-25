# JAX container user instructions

The JAX container is developed by AMD specifically for LUMI and contains the
necessary parts to run JAX on LUMI, including the plugin needed for RCCL when
doing distributed AI, and a suitable version of ROCm for the version of JAX.

**Note that JAX is still very much in development. Moreover, we sometimes have
to use newer version of ROCm than the drivers on LUMI support, so there is no
guarantee that this container will work for you (even though it did pass some
tests we did), and there might be problems that cannot be fixed by the
support team. JAX is software for users with a development spirit, not
for users who expect something that simply and always works, and this is
reflected in its 0.x version numbers. LUST cannot offer more than a best
effort support and has no link to the JAX developers.**


## Use via EasyBuild-generated modules

!!! Note "Changes to the EasyConfigs in late July 2025"

    The EasyConfigs for the jax containers for the 2025 versions received a major 
    update at the end of July. Instructions below are only valid if you (rei)installed
    the container afterwards.
    
    Re-installing is tricky as by default EasyBuild will take the already installed
    version of the EasyConfig, so before re-installing, change your directory to the
    directory containing the EasyConfigs, which is 
    `/appl/local/containers/LUMI-EasyBuild-containers/easybuild/easyconfigs/j/jax`.
    

The EasyBuild installation with the EasyConfigs mentioned below will do four things:

1.  It will copy the container to your own file space. We realise containers can be
    big, but it ensures that you have complete control over when a container is
    removed again.
    
    We will remove a container from the system when it is not sufficiently functional
    anymore, but the container may still work for you. E.g., after an upgrade of the 
    network drivers on LUMI, the RCCL plugin for the LUMI Slingshot interconnect may be broken,
    but if you run on only one node PyTorch may still work for you.

    If you prefer to use the centrally provided container, you can remove your copy 
    after loading of the module with `rm $SIF` followed by reloading the module. This
    is however at your own risk. 

2.  It will create a module file. 
    When loading the module, a number of environment variables will
    be set to help you use the module and to make it easy to swap the module with a
    different version in your job scripts.
    
    -   `SIF` and `SIFJAX` both contain the name and full path of the singularity
        container file.
        
    -   `SINGULARITY_BIND` will mount all necessary directories from the system,
        including everything that is needed to access the project, scratch and flash
        file systems.
        
    -   `RUNSCRIPTS` and `RUNSCRIPTSJAX` contain the full path of the directory
        containing some sample run scripts that can be used to run software in the 
        container, or as inspiration for your own variants.
        
3.  It creates the $RUNSCRIPTS directory with scripts to be run in the container:

    -   `conda-python-simple`: This initialises Python in the container and then calls Python
        with the arguments of `conda-python-simple`. It can be used, e.g., to run commands
        through Python that utilise a single task but all GPUs.
        
        Note that in the 2025 and later JAX containers this script doesn't make much 
        sense anymore and one could just as well call `python` in the container as the 
        activation of the conda environment used to install JAX is now fully automatic.
        It is left in for compatibility with older containers as it may be used in some
        3rd party documentation that we are not aware of.
        
    From the 2025 containers onwards, the directory with runscripts is in the PATH in 
    the container if the module is loaded before entering the container.
        
4.  It creates a `bin` directory with scripts to be run outside of the container:

    -   `start-shell`: Serves a double purpose:
    
        -   Without further arguments, it will start a shell in the container with 
            the Conda environment used to build the container activated.
            
        -   With arguments it simply runs a shell in the container, but the Conda 
            environment will not be activated.
            
    The `bin` directory is not mounted in the container, but if you would, the 
    scripts would recognise this and work or print a message that they cannot 
    be used in that environment.

5.  From the 2025 containers onwards, it also creates wrapper scripts for the
    `python`and `pip` commands (including the commands with major and major.minor Python
    version in their name), and also has a `list-packages` script. These scripts should work in the same 
    way as those in the CSC local software stacks as documented in the [CSC PyTorch documentation](https://docs.csc.fi/apps/jax/)
    and the [CSC machine learning guide](https://docs.csc.fi/support/tutorials/ml-guide/).

The container uses a miniconda environment in which Python and its packages are installed.
Before the 2025 containers, that environment needs to be activated in the container when running, which can be done
with the command that is available in the container as the environment variable
`WITH_CONDA` (which for this container it is
`source /opt/miniconda3/bin/activate jax`).

Example of the use of `WITH_CONDA`: Check the Python packages in the container
in an interactive session:

```
module load LUMI jax/0.4.28-rocm-6.2.0-python-3.12-singularity-20241007
singularity shell $SIF
```

which takes you in the container, and then in the container, at the `Singularity>` 
prompt:

```
$WITH_CONDA
pip list
```

An example of the use of `start-shell` that even works on the login nodes is:

```
module load LUMI jax/0.4.28-rocm-6.2.0-python-3.12-singularity-20241007
start-shell -c '/runscripts/conda-python-simple -c "import numpy ; import scipy ; import jax ; print( f'"'JAX {jax.__version__}, NumPy {numpy.__version__}, SciPy {scipy.__version__}.'"' )"'
```

The container (when used with `SINGULARITY_BIND` of the module) also provides
one or more wrapper scripts to start Python from the
conda environment in the container. Those scripts are also available outside the 
container for inspection after loading the module in the 
`$RUNSCRIPTS` subdirectory and you can use those scripts as a source
of inspiration to develop a script that more directly executes your commands or
does additional initialisations.

Example (in an interactive session):

```
salloc -N1 -pstandard-g -t 10:00
module load LUMI jax/0.4.28-rocm-6.2.0-python-3.12-singularity-20241007
srun -N1 -n1 --gpus 8 singularity exec $SIF /runscripts/conda-python-simple \
    -c 'import jax; print("I have these devices:", jax.devices("gpu"))'
```


### Installation

To install the container with EasyBuild, follow the instructions in the
[EasyBuild section of the LUMI documentation, section "Software"](https://docs.lumi-supercomputer.eu/software/installing/easybuild/),
and use the dummy partition `container`, e.g.:

```
module load LUMI partition/container EasyBuild-user
eb jax-0.4.28-rocm-6.2.0-python-3.12-singularity-20241007.eb
```

To use the container after installation, the `EasyBuild-user` module is not needed nor
is the `container` partition. The module will be available in all versions of the LUMI stack
and in [the `CrayEnv` stack](https://docs.lumi-supercomputer.eu/runjobs/lumi_env/softwarestacks/#crayenv)
(provided the environment variable `EBU_USER_PREFIX` points to the right location).


## Direct access (use without the container module)

The jax containers are available in the following subdirectories of `/appl/local/containers`:

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

Note that the list recommended bindings may change after a system update or between containers. E.g.,
the containers provided since early 2025 already contain their own `libcxi.so.1` but the container
is configured in such a way that binding the one from the system will do no harm. Some containers
in the past also required binding `/usr/lib64/libjansson.so.4` but there is now a version in the
newer containers, and overwriting that version may in fact create incompatibilities with other 
software in the container.


