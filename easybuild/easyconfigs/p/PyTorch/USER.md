# PyTorch container user instructions

**BETA VERSION, problems may occur and may not be solved quickly.**

The PyTorch container is developed by AMD specifically for LUMI and contains the
necessary parts to run PyTorch on LUMI, including the plugin needed for RCCL when
doing distributed AI, and a suitable version of ROCm for the version of PyTorch.
The apex, torchvision, torchdata, torchtext and torchaudio packages are also included.

The EasyBuild installation with the EasyConfigs mentioned below will do two things:

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
    
    -   `SIF` and `SIFPYTORCH` both contain the name and full path of the singularity
        container file.
        
    -   `SINGULARITY_BINDPATH` will mount all necessary directories from the system,
        including everything that is needed to access the project, scratch and flash
        file systems.
        
    -   `RUNSCRIPTS` and `RUNSCRIPTSPYTORCH` contain the full path of the directory
        containing some sample run scripts that can be used to run software in the 
        container, or as inspiration for your own variants.
        
3.  It creates 4 scripts in the $RUNSCRIPTS directory:

    -   `conda-python-simple`: This initialises Python in the container and then calls Python
        with the arguments of `conda-python-simple`. It can be used, e.g., to run commands
        through Python that utilise a single task but all GPUs.
        
    -   `conda-python-distributed`: Model script that initialises Python in the container
        and also creates the environment to run a distributed PyTorch session. 
        At the end, it will call Python with the arguments of the `conda-python-distributed`
        command.
        
    -   `conda-torchrun`: Model script similar to `conda-python-distributed`, but calling 
        the `torchrun` command in the container rather than `python`.
        
    -   `get-master`: A helper command for `conda-python-distributed` and `conda-torchrun`.
        
The container uses a miniconda environment in which Python and its packages are installed.
That environment needs to be activated in the container when running, which can be done
with the command that is available in the container as the environment variable
`WITH_CONDA` (which for this container it is
`source /opt/miniconda3/bin/activate pytorch`).

The container (when used with `SINGULARITY_BINDPATH` of the module) also provides
several wrapper scripts to start Python or torchrun from the
conda environment in the container. Those scripts are also available outside the 
container for inspection after loading the module in the 
`$RUNSCRIPTS` subdirectory and you can use those scripts as a source
of inspiration to develop a script that more directly executes your commands or
does additional initialisations.

Example (in an interactive session):

```
salloc -N1 -pstandard-g -t 30:00
module load LUMI PyTorch/2.1.0-rocm-5.6.1-python-3.10-singularity-20231108
srun -N1 -n1 --gpus 8 singularity exec $SIF /runscripts/conda-python-simple \
    -c 'import torch; print("I have this many devices:", torch.cuda.device_count())'
```

This command will start Python and run PyTorch on a single CPU core with access to
all 8 GPUs.

After loading the module, the docker definition file used when building the container
is available in the `$EBROOTPYTORCH/share/docker-defs` subdirectory. As it requires some
licensed components from LUMI and some other files that are not included, it currently
cannot be used to reconstruct the container and extend its definition.


## Installation

To install the container with EasyBuild, follow the instructions in the
[EasyBuild section of the LUMI documentation, section "Software"](https://docs.lumi-supercomputer.eu/software/installing/easybuild/),
and use the dummy partition `container`, e.g.:

```
module load LUMI partition/container EasyBuild-user
eb PyTorch-2.1.0-rocm-5.6.1-python-3.10-singularity-20231108.eb
```

To use the container after installation, the `EasyBuild-user` module is not needed nor
is the `container` partition. The module will be available in all versions of the LUMI stack
and in [the `CrayEnv` stack](https://docs.lumi-supercomputer.eu/runjobs/lumi_env/softwarestacks/#crayenv)
(provided the environment variable `EBU_USER_PREFIX` points to the right location).
