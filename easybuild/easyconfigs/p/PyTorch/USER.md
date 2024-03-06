# PyTorch container user instructions

**BETA VERSION, problems may occur and may not be solved quickly.**

The PyTorch container is developed by AMD specifically for LUMI and contains the
necessary parts to run PyTorch on LUMI, including the plugin needed for RCCL when
doing distributed AI, and a suitable version of ROCm for the version of PyTorch.
The apex, torchvision, torchdata, torchtext and torchaudio packages are also included.

The EasyBuild installation with the EasyConfigs mentioned below will do three things:

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
        
3.  It creates 3 scripts in the $RUNSCRIPTS directory:

    -   `conda-python-simple`: This initialises Python in the container and then calls Python
        with the arguments of `conda-python-simple`. It can be used, e.g., to run commands
        through Python that utilise a single task but all GPUs.
        
    -   `conda-python-distributed`: Model script that initialises Python in the container
        and also creates the environment to run a distributed PyTorch session. 
        At the end, it will call Python with the arguments of the `conda-python-distributed`
        command.
        
    -   `get-master`: A helper command for `conda-python-distributed`.
        
The container uses a miniconda environment in which Python and its packages are installed.
That environment needs to be activated in the container when running, which can be done
with the command that is available in the container as the environment variable
`WITH_CONDA` (which for this container it is
`source /opt/miniconda3/bin/activate pytorch`).

Example of the use of `WITH_CONDA`: Check the Python packages in the container
in an interactive session:

```
module load LUMI PyTorch/2.1.0-rocm-5.6.1-python-3.10-singularity-20231123
singularity shell $SIF
```

which takes you in the container, and then in the container, at the `Singularity>` 
prompt:

```
$WITH_CONDA
pip list
```

The container (when used with `SINGULARITY_BINDPATH` of the module) also provides
several wrapper scripts to start Python from the
conda environment in the container. Those scripts are also available outside the 
container for inspection after loading the module in the 
`$RUNSCRIPTS` subdirectory and you can use those scripts as a source
of inspiration to develop a script that more directly executes your commands or
does additional initialisations.

Example (in an interactive session):

```
salloc -N1 -pstandard-g -t 30:00
module load LUMI PyTorch/2.1.0-rocm-5.6.1-python-3.10-singularity-20231123
srun -N1 -n1 --gpus 8 singularity exec $SIF /runscripts/conda-python-simple \
    -c 'import torch; print("I have this many devices:", torch.cuda.device_count())'
```

This command will start Python and run PyTorch on a single CPU core with access to
all 8 GPUs.

After loading the module, the docker definition file used when building the container
is available in the `$EBROOTPYTORCH/share/docker-defs` subdirectory (but not for all
versions). As it requires some
licensed components from LUMI and some other files that are not included, it currently
cannot be used to reconstruct the container and extend its definition.


## Example for distributed learning

The communication between LUMI's GPUs during training with Pytorch is done via 
[RCCL](https://github.com/ROCmSoftwarePlatform/rccl), which is a library of  collective 
communication routines for AMD GPUs. RCCL works out of the box on LUMI, however, 
a special plugin is required so it can take advantage of the Slingshot 11 interconnect]. 
That's the [`aws-ofi-rccl`](https://github.com/ROCmSoftwarePlatform/aws-ofi-rccl) plugin, 
which is a library that can be used as a back-end for RCCL to interact with the interconnect 
via libfabric. The plugin is already built in the containers that we provide here.

A proper distributed learning run does require setting some environment variables.
You can find out more by checking the scripts in `$EBROOTPYTORCH/runscripts` (after
installing and loading the module), and in particular the 
`conda-python-distributed` script and the `get-master` script used by the former.
Together these scripts make job scripts a lot easier.

An example job script using the [mnist example](https://github.com/Lumi-supercomputer/lumi-reframe-tests/tree/main/checks/containers/ML_containers/src/pytorch/mnist)
(itself based on an example by Google) is:


``` bash
#!/bin/bash -e
#SBATCH --nodes=4
#SBATCH --gpus-per-node=8
#SBATCH --tasks-per-node=8
#SBATCH --cpus-per-task=7
#SBATCH --output="output_%x_%j.txt"
#SBATCH --partition=standard-g
#SBATCH --mem=480G
#SBATCH --time=00:10:00
#SBATCH --account=project_<your_project_id>

module load LUMI  # Which version doesn't matter, it is only to get the container and wget.
module load wget  # Compute nodes don't have wget preinstalled. Version and toolchain don't matter in this example.
module load PyTorch/2.2.0-rocm-5.6.1-python-3.10-singularity-20240209

# Get the files from the LUMI ReFrame repository
# It is not recommended to do this in a jobscript but it works to ensure that
# you get the correct files for the example. And even worse, the example itself
# downloads a lot more data.
wget https://raw.githubusercontent.com/Lumi-supercomputer/lumi-reframe-tests/main/checks/containers/ML_containers/src/pytorch/mnist/mnist_DDP.py
mkdir -p model ; cd model
wget https://github.com/Lumi-supercomputer/lumi-reframe-tests/raw/main/checks/containers/ML_containers/src/pytorch/mnist/model/model_gpu.dat
cd ..

# Optional: Inject the environment variables for NCCL debugging into the container.   
# This will produce a lot of debug output!     
export SINGULARITYENV_NCCL_DEBUG=INFO
export SINGULARITYENV_NCCL_DEBUG_SUBSYS=INIT,COLL

c=fe
MYMASKS="0x${c}000000000000,0x${c}00000000000000,0x${c}0000,0x${c}000000,0x${c},0x${c}00,0x${c}00000000,0x${c}0000000000"

srun --cpu-bind=mask_cpu:$MYMASKS \
  singularity exec $SIFPYTORCH \
    conda-python-distributed -u mnist_DDP.py --gpu --modelpath model
```

??? Note "Container modules installed before March 9, 2024"
    In these versions of the container module, `conda-python-distributed` is not yet in
    the search path for executables, and you need to modify the job script to use
    `/runscripts/conda-python-distributed` instead.

The `get-master` script is a Python script to determine the master node for communication.

In the above example we do download all files, which of course is in general not a good idea, in particular
if those files are only read anyway. However, the example itself further downloads data it needs.

We use a CPU mask to ensure a proper mapping of CPU chiplets onto GPU chiplets. The GPUs are used in
the regular ordering, so we reorder the CPU cores for each task so that the first task on a node
gets the cores most closely to GPU 0, etc. 

The jobscript also shows how environment variables to enable debugging of the RCCL communication can be
set outside the container. Basically, if the name of an environment variable is prepended with `SINGULARITYENV_`,
it will be injected in the container by the `singularity` command. 

If you would check the code of `$EBROOTPYTORCH/runscripts/conda-python-distributed`, you'd note a couple more
environment variables are set. The ones starting with `NCCL_` are used by RCCL for the communication over
the Slingshot 11 interconnect:

```
export NCCL_SOCKET_IFNAME=hsn0,hsn1,hsn2,hsn3
export NCCL_NET_GDR_LEVEL=3
```

The `MIOPEN_` ones are needed to make 
[MIOpen](https://rocm.docs.amd.com/projects/MIOpen/en/latest/) create its caches on `/tmp`:

```
export MIOPEN_USER_DB_PATH="/tmp/$(whoami)-miopen-cache-$SLURM_NODEID"
export MIOPEN_CUSTOM_CACHE_DIR=$MIOPEN_USER_DB_PATH

# Set MIOpen cache to a temporary folder.
if [ $SLURM_LOCALID -eq 0 ] ; then
    rm -rf $MIOPEN_USER_DB_PATH
    mkdir -p $MIOPEN_USER_DB_PATH
fi
```

Furthermore some environment variables are needed by PyTorch itself.

**Note that the `conda-python-distributed` script that we provide, has to run on exclusive nodes.
Running, e.g., 2 4-GPU jobs on the same node with this command will not work as there will be
a conflict for the TCP port for communication on the master as `MASTER_PORT` is hard-coded in 
this version of the script.**


## Installation

To install the container with EasyBuild, follow the instructions in the
[EasyBuild section of the LUMI documentation, section "Software"](https://docs.lumi-supercomputer.eu/software/installing/easybuild/),
and use the dummy partition `container`, e.g.:

```
module load LUMI partition/container EasyBuild-user
eb PyTorch-2.1.0-rocm-5.6.1-python-3.10-singularity-20231123.eb
```

To use the container after installation, the `EasyBuild-user` module is not needed nor
is the `container` partition. The module will be available in all versions of the LUMI stack
and in [the `CrayEnv` stack](https://docs.lumi-supercomputer.eu/runjobs/lumi_env/softwarestacks/#crayenv)
(provided the environment variable `EBU_USER_PREFIX` points to the right location).
