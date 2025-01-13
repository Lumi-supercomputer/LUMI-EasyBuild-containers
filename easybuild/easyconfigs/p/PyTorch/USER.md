# PyTorch container user instructions

**BETA VERSION, problems may occur and may not be solved quickly.**

The containers that are provided by the LUMI User Support Team can be used in
two possible ways:

-   [Through modules and wrapper scripts generated via EasyBuild](index.md#module-and-wrapper-scripts)

-   [Directly, with you taking care of all bindings and all necessary environment
    variables.](index.md#alternative-direct-access-without-the-easybuild-generated-pytorch-module)

    These instructions will likely also work for the 
    [containers built on top of the ROCm containers with cotainr](../../r/rocm/index.md#using-the-images-as-base-image-for-cotainr).

Containers with PyTorch provided in local software stacks (e.g., the CSC software stack)
may be build differently with different wrapper scripts so instructions on this page
may not apply to those.


## Module and wrapper scripts

The PyTorch container is developed by AMD specifically for LUMI and contains the
necessary parts to run PyTorch on LUMI, including the plugin needed for RCCL when
doing distributed AI, and a suitable version of ROCm for the version of PyTorch.
The apex, torchvision, torchdata, torchtext and torchaudio packages are also included.

The EasyBuild installation with the EasyConfigs mentioned below will do three or four things:

1.  It will copy the container to your own EasyBuild software installation space. 
    We realise containers can be big, but it ensures that you have complete control 
    over when a container is removed.
    
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

    Container modules installed after March 9, 2024 also define 
    `SINGULARITYENV_PREPEND_PATH` in a way that ensures that the `/runscripts` 
    subdirectory in the container will be in the search path in the container.

    The containers with support for a virtual environment (from 20240315 on) define
    a few other `SINGULARITYENV_*` environment variables that inject environment variables
    in the container that are equivalent to those created by the activate scripts for the
    Conda environment and the Python virtual environment.
        
3.  It creates 3 scripts in the $RUNSCRIPTS directory:

    -   `conda-python-simple`: This initialises Python in the container and then calls Python
        with the arguments of `conda-python-simple`. It can be used, e.g., to run commands
        through Python that utilise a single task but all GPUs.
        
    -   `conda-python-distributed`: Model script that initialises Python in the container
        and also creates the environment to run a distributed PyTorch session. 
        At the end, it will call Python with the arguments of the `conda-python-distributed`
        command.
        
    -   `get-master`: A helper command for `conda-python-distributed`.
  
    These scripts are available in the container in the `/runscripts` subdirectory but can
    also be reached with their full path name, and can be inspected outside the container
    in the `$RUNSCRIPTS` subdirectory.

    Those scripts don't cover all use cases for PyTorch on LUMI, but can be used as a source of
    inspiration for your own scripts.

4.  For the containers with support for virtual environments (from 20240315 on),
    it also creates a number of commands intended to be used outside the container:

    -   `start-shell`: To start a bash shell in the container. Arguments can be used
        to, e.g., tell it to start a command. Without arguments, the conda and Python 
        virtual environments will be initialised, but this is not the case as soon as
        arguments are used. It takes the command line arguments that bash can also take.

    -   `make-squashfs`: Make the user-software.squashfs file that would then be mounted
        in the container after reloading the module. This will enhance performance if
        the extra installation in user-software contains a lot of files.

    -   `unmake-squashfs`: Unpack the user-software.squashfs file into the user-software
        subdirectory of $CONTAINERROOT to enable installing additional packages.
            
The container uses a miniconda environment in which Python and its packages are installed.
That environment needs to be activated in the container when running, which can be done
with the command that is available in the container as the environment variable
`WITH_CONDA` (which for this container it is
`source /opt/miniconda3/bin/activate pytorch`).

From the 20240315 version onwards, EasyBuild will already initialise the Python virtual
environment `pytorch`. Inside the container, the virtual environment is available in
`/user-software/venv` while outside the container the files can be found in 
`$CONTAINERROOT/user-software/venv` (if this directory has not been removed after creating
a SquashFS file from it for better file system performance). You can also use the 
`/user-software` subdirectory in the container to install other software through other methods.
In these containers it is also very easy to check which Python packages are installed 
with

```
singularity exec $SIF pip list
```

or if the `start-shell` script is available (which is the case for most of these containers,

```
start-shell -c 'pip list'
```


## Examples with the wrapper scripts

Note: In the examples below you may need to replace the `standard-g` queue with a [different
slurm partition allocatable per node](https://docs.lumi-supercomputer.eu/runjobs/scheduled-jobs/partitions/#slurm-partitions-allocatable-by-node)
if your user category has no access to `standard-g`. 


### List the Python packages in the container

#### Containers up to and including the 20240209 ones

For the containers up to the 20240209 ones, this example also illustrated how the
`WITH_CONDA` environment variable should be used.
The example can be run in an interactive session and works even on the login nodes.

In these containers, the Python packages
can be listed using the following steps: First execute, e.g., 

```
module load LUMI PyTorch/2.2.0-rocm-5.6.1-python-3.10-singularity-20240209
singularity shell $SIF
```

which takes you in the container, and then in the container, at the `Singularity>` 
prompt:

```
$WITH_CONDA
pip list
```

The same can be done without opening an interactive session in the container with

```
module load LUMI PyTorch/2.2.0-rocm-5.6.1-python-3.10-singularity-20240209
singularity exec $SIF bash -c '$WITH_CONDA ; pip list'
```

Notice the use of single quotes as with double quotes `$WITH_CONDA` would be expanded
by the shell before executing the singularity command, and at that time `WITH_CONDA` is
not yet defined. To use the container it also doesn't matter which version of the 
LUMI module is loaded, and in fact, loading CrayEnv would work as well.


#### Containers from 20240315 on

For the containers from version 20240315 on, the `$WITH_CONDA` is no longer needed.
In an interactive session, you still need to load the module and go into the container:

```
module load LUMI PyTorch/2.2.0-rocm-5.6.1-python-3.10-singularity-20240315
singularity shell $SIF
```

but once in the container, at the `Singularity>` prompt, all that is needed is

```
pip list
```

Without an interactive session in the container, all that is now needed is

```
module load LUMI PyTorch/2.2.0-rocm-5.6.1-python-3.10-singularity-20240315
singularity exec $SIF pip list
```

as the `pip` command is already in the search path.


### Executing Python code in the container (single task)

#### Containers up to and including the 20240209 ones

The wrapper script `conda-python-single` which can be found in the `/runscripts` directory
in the container, takes care of initialising the Conda environment and then passes its
arguments to the `python` command. E.g., the example below will import the `torch`
package in Python and then show the number of GPUs available to it:

```
salloc -N1 -pstandard-g -t 30:00
module load LUMI PyTorch/2.1.0-rocm-5.6.1-python-3.10-singularity-20240209
srun -N1 -n1 --gpus 8 singularity exec $SIF conda-python-simple \
    -c 'import torch; print("I have this many devices:", torch.cuda.device_count())'
exit
```

This command will start Python and run PyTorch on a single CPU core with access to
all 8 GPUs.

??? Note "Container modules installed before March 9, 2024"
    In these versions of the container module, `conda-python-simple` is not yet in
    the search path for executables, and you need to modify the job script to use
    `/runscripts/conda-python-simple` instead.


#### Containers from 20240315 on

As the Conda environment and Python virtual environment are properly initialised by the
module, the `conda-python-simple` script is not even needed anymore (though still provided
for compatibility with job scripts developed before those containers became available).

The following commands now work just as well:

```
salloc -N1 -pstandard-g -t 30:00
module load LUMI PyTorch/2.2.0-rocm-5.6.1-python-3.10-singularity-20240315
srun -N1 -n1 --gpus 8 singularity exec $SIF python \
    -c 'import torch; print("I have this many devices:", torch.cuda.device_count())'
exit
```


### Distributed learning example

The communication between LUMI's GPUs during training with PyTorch is done via 
[RCCL](https://github.com/ROCmSoftwarePlatform/rccl), which is a library of  collective 
communication routines for AMD GPUs. RCCL works out of the box on LUMI, however, 
a special plugin is required so it can take advantage of the Slingshot 11 interconnect. 
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

1.  The mnist example needs some data files. We can get them in the job script (as we did before)
    but also simply install them now, avoiding repeated downloads when using the script multiple times
    (in the example with wrappers it was in the job script to have a one file example).
    First create a directory for your work on this example and go into that directory.
    In that directory we'll create a subdirectory `mnist` with some files. The first run of 
    the jobscript will download even more files.
    Assuming you are working on the login nodes where the `wget` program is already available,

    ``` bash
    mkdir mnist ; pushd mnist
    wget https://raw.githubusercontent.com/Lumi-supercomputer/lumi-reframe-tests/main/checks/containers/ML_containers/src/pytorch/mnist/mnist_DDP.py
    mkdir -p model ; cd model
    wget https://github.com/Lumi-supercomputer/lumi-reframe-tests/raw/main/checks/containers/ML_containers/src/pytorch/mnist/model/model_gpu.dat
    popd
    ```

    will fetch the two files we need to start.

2.  We can now create the jobscript `mnist.slurm`:

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

    module load LUMI  # Which version doesn't matter, it is only to get the container.
    module load PyTorch/2.2.0-rocm-5.6.1-python-3.10-singularity-20240315

    # Optional: Inject the environment variables for NCCL debugging into the container.   
    # This will produce a lot of debug output!     
    export SINGULARITYENV_NCCL_DEBUG=INFO
    export SINGULARITYENV_NCCL_DEBUG_SUBSYS=INIT,COLL

    c=fe
    MYMASKS="0x${c}000000000000,0x${c}00000000000000,0x${c}0000,0x${c}000000,0x${c},0x${c}00,0x${c}00000000,0x${c}0000000000"

    cd mnist
    srun --cpu-bind=mask_cpu:$MYMASKS \
      singularity exec $SIFPYTORCH \
        conda-python-distributed -u mnist_DDP.py --gpu --modelpath model
    ```

    ??? Note "Container modules installed before March 9, 2024"
        In these versions of the container module, `conda-python-distributed` is not yet in
        the search path for executables, and you need to modify the job script to use
        `/runscripts/conda-python-distributed` instead.

    We use a CPU mask to ensure a proper mapping of CPU chiplets onto GPU chiplets. The GPUs are used in
    the regular ordering, so we reorder the CPU cores for each task so that the first task on a node
    gets the cores most closely to GPU 0, etc. 

    The jobscript also shows how environment variables to enable debugging of the RCCL communication can be
    set outside the container. Basically, if the name of an environment variable is prepended with `SINGULARITYENV_`,
    it will be injected in the container by the `singularity` command. 

??? Note "Inside the `conda-python-distributed` script (if you need to modify things)"

    ``` bash
    #!/bin/bash -e

    # Make sure GPUs are up
    if [ $SLURM_LOCALID -eq 0 ] ; then
        rocm-smi
    fi
    sleep 2

    # MIOPEN needs some initialisation for the cache as the default location
    # does not work on LUMI as Lustre does not provide the necessary features.
    export MIOPEN_USER_DB_PATH="/tmp/$(whoami)-miopen-cache-$SLURM_NODEID"
    export MIOPEN_CUSTOM_CACHE_DIR=$MIOPEN_USER_DB_PATH

    if [ $SLURM_LOCALID -eq 0 ] ; then
        rm -rf $MIOPEN_USER_DB_PATH
        mkdir -p $MIOPEN_USER_DB_PATH
    fi
    sleep 2

    # Set interfaces to be used by RCCL.
    # This is needed as otherwise RCCL tries to use a network interface it has
    # no access to on LUMI.
    export NCCL_SOCKET_IFNAME=hsn0,hsn1,hsn2,hsn3
    export NCCL_NET_GDR_LEVEL=3

    # Set ROCR_VISIBLE_DEVICES so that each task uses the proper GPU
    export ROCR_VISIBLE_DEVICES=$SLURM_LOCALID

    # Report affinity to check
    echo "Rank $SLURM_PROCID --> $(taskset -p $$); GPU $ROCR_VISIBLE_DEVICES"

    # The usual PyTorch initialisations (also needed on NVIDIA)
    # Note that since we fix the port ID it is not possible to run, e.g., two
    # instances via this script using half a node each.
    export MASTER_ADDR=$(/runscripts/get-master "$SLURM_NODELIST")
    export MASTER_PORT=29500
    export WORLD_SIZE=$SLURM_NPROCS
    export RANK=$SLURM_PROCID

    # Run application
    python "$@"
    ```

    The script sets a number of environment variables. Some are fairly standard when using PyTorch
    on an HPC cluster while others are specific for the LUMI interconnect and architecture or the 
    AMD ROCm environment.

    The `MIOPEN_` environment variables are needed to make 
    [MIOpen](https://rocm.docs.amd.com/projects/MIOpen/en/latest/) create its caches on `/tmp`
    as doing this on Lustre fails because of file locking issues:

    ``` bash
    export MIOPEN_USER_DB_PATH="/tmp/$(whoami)-miopen-cache-$SLURM_NODEID"
    export MIOPEN_CUSTOM_CACHE_DIR=$MIOPEN_USER_DB_PATH

    if [ $SLURM_LOCALID -eq 0 ] ; then
        rm -rf $MIOPEN_USER_DB_PATH
        mkdir -p $MIOPEN_USER_DB_PATH
    fi
    ```

    It is also essential to tell RCCL, the communication library, which network adapters to use. 
    These environment variables start with `NCCL_` because ROCm tries to keep things as similar as
    possible to NCCL in the NVIDIA ecosystem:

    ```
    export NCCL_SOCKET_IFNAME=hsn0,hsn1,hsn2,hsn3
    export NCCL_NET_GDR_LEVEL=3
    ```

    Without this RCCL may try to use a network adapter meant for system management rather than
    inter-node communications!

    We also set `ROCR_VISIBLE_DEVICES` to ensure that each task uses the proper GPU.

    Furthermore some environment variables are needed by PyTorch itself that are also needed on
    NVIDIA systems.

    PyTorch needs to find the master for communication which is done through

    ``` bash
    export MASTER_ADDR=$(/runscripts/get-master "$SLURM_NODELIST")
    export MASTER_PORT=29500
    ```

    The `get-master` script that is used here is a Python script to determine the master node 
    for communication and also already provided in the `/runscripts` subdirectory in the 
    container (or `$RUNSCRIPTS` outside the container).

    **As we fix the port number here, the `conda-python-distributed` script that we provide, 
    has to run on exclusive nodes.
    Running, e.g., 2 4-GPU jobs on the same node with this command will not work as there will be
    a conflict for the TCP port for communication on the master as `MASTER_PORT` is hard-coded in 
    this version of the script.**


## Installation with EasyBuild

To install the container with EasyBuild, follow the instructions in the
[EasyBuild section of the LUMI documentation, section "Software"](https://docs.lumi-supercomputer.eu/software/installing/easybuild/),
and use the dummy partition `container`, e.g.:

```
module load LUMI partition/container EasyBuild-user
eb PyTorch-2.2.0-rocm-5.6.1-python-3.10-singularity-20240315.eb
```

To use the container after installation, the `EasyBuild-user` module is not needed nor
is the `container` partition. The module will be available in all versions of the LUMI stack
and in [the `CrayEnv` stack](https://docs.lumi-supercomputer.eu/runjobs/lumi_env/softwarestacks/#crayenv)
(provided the environment variable `EBU_USER_PREFIX` points to the right location).

After loading the module, the docker definition file used when building the container
is available in the `$EBROOTPYTORCH/share/docker-defs` subdirectory (but not for all
versions). As it requires some
licensed components from LUMI and some other files that are not included, it currently
cannot be used to reconstruct the container and extend its definition.


## Extending the containers with virtual environment support

**This text is for containers from 20240315 on. Other containers can be extended with virtual
environments also but you'll have to do a lot more work by hand that is now done by the module,
or adapt the EasyConfig for those based on what is in the more recent EasyConfigs.**

<!--
TODO: The general idea will apply to several of the AMD containers (also, e.g., the jax and TensorFlow containers)
so the general principles really need to be discussed in the main LUMI docs.
-->

### Manual procedure

Let's demonstrate how the module can be extended by using `pip` to install packages in the virtual
environment. We'll demonstrate using the `PyTorch/2.2.0-rocm-5.6.1-python-3.10-singularity-20240315`
module where we assume that you have already installed this module:

``` bash
module load CrayEnv
module load PyTorch/2.2.0-rocm-5.6.1-python-3.10-singularity-20240315
```

Let's check a directory outside the container:

``` bash
ls -l $CONTAINERROOT/user-software/venv/pytorch
```

which produces something along the lines of

```
drwxrwsr-x 2 username project_46XYYYYYY 4096 Mar 25 17:15 bin
drwxrwsr-x 2 username project_46XYYYYYY 4096 Mar 25 17:14 include
drwxrwsr-x 3 username project_46XYYYYYY 4096 Mar 25 17:14 lib
lrwxrwxrwx 1 username project_46XYYYYYY    3 Mar 25 17:14 lib64 -> lib
-rw-rw-r-- 1 username project_46XYYYYYY   94 Mar 25 17:15 pyvenv.cfg
```

The output is typical for a freshly initialised Python virtual environment.

We can now enter the container:

``` bash
singularity shell $SIF
```

At the singularity prompt, try

``` bash
ls -l /user-software/venv/pytorch
```

and notice that we have the same output as with the previous `ls` command that we executed outside
the container. So the `RCONTAINERROOT/user-software` subdirectory is available in the container
as `/user-software`.

Executing

``` bash
which python
which python3
```

which return the lines

```
/user-software/venv/pytorch/bin/python
/user-software/venv/pytorch/bin/python3
```

also shows that the virtual environment is already activated and that we get the `python` wrapper script
from the virtual environment and not the system `python3` (there is a `python3` executable in `/usr/bin`)
or the Conda `python` in `/opt/miniconda3/envs/pytorch/bin`.

Let us install the `torchmetrics` package using `pip`:

``` bash
pip install torchmetrics
```

To check if the package is present and can be loaded, try

``` bash
python -c 'import torchmetrics ; print( torchmetrics.__version__ )'
```

and notice that it does print the version number of `torchmetrics`, so the package was
successfully loaded.

Now execute 

``` bash
ls /user-software/venv/pytorch/lib/python3.10/site-packages/
```

and you'll get output similar to

```
_distutils_hack			              pkg_resources
distutils-precedence.pth	          setuptools
lightning_utilities		              setuptools-65.5.0.dist-info
lightning_utilities-0.11.1.dist-info  torchmetrics
pip				                      torchmetrics-1.3.2.dist-info
pip-23.0.1.dist-info
```

which confirms that the `torchmetrics` package is indeed installed in the virtual environment.

Let's leave the container (by executing the `exit` command) and check again what has happened outside
the container:

``` bash
ls $CONTAINERROOT/user-software/venv/pytorch/lib/python3.10/site-packages/
```

and we get the same output as with the previous `ls` command. I.e., the installation file of the package
is indeed saved outside the container.

Now there is one remaining problem. Try

``` bash
lfs find $CONTAINERROOT/user-software | wc -l
```

where `lfs find` is a version of the `find` command with some restrictions, but one that is a lot more
friendly to the Lustre metadata servers. The output suggests that there are over 2300 files and directories
in the `user-software` subdirectory. The Lustre filesystem doesn't like working with lots of small files
and Python can sometimes open a lot of those files in a short amount of time. 

The module also provides a solution for this: The content of `$CONTAINERROOT/user-software` can be packed
in a single SquashFS file `$CONTAINERROOT/user-software.squashfs` and after reloading the `PyTorch` module that
is being used, that file will be mounted in the container and provide `/user-software`. This may improve
performance of Python in the container and is certainly appreciated by your fellow LUMI users.
To this end, the module provides the `make-squashfs` script. Try

``` bash
make-squashfs
ls $CONTAINERROOT
```

The second command outputs something along the lines of

```
bin
easybuild
lumi-pytorch-rocm-5.6.1-python-3.10-pytorch-v2.2.0-dockerhash-7392c9d4dcf7.sif
runscripts
user-software
user-software.squashfs
```

so we see that there is now indeed a file `user-software.squashfs` in that subdirectory.
We do not automatically delete the `user-software` subdirectory, but you can delete it safely using

```
rm -rf $CONTAINERROOT/user-software
```

as it can be reconstructed (except for the file dates) from the SquashFS file using the script
`unmake-squashfs` which is also provided by the module.

Reload the module to let the changes take effect and go again in the container:

``` bash
module load PyTorch/2.2.0-rocm-5.6.1-python-3.10-singularity-20240315
singularity shell $SIF
```

Now try

``` bash
echo "Test" > /user-software/test.txt
```

and notice that we can no longer write in `/user-software`.

Installing further packages with `pip` would not fail, but they would not be installed where you expect and instead
would be installed in your home directory. The `pip` command would warn with

```
Defaulting to user installation because normal site-packages is not writeable
```

Try, e.g.,

``` bash
pip install lightning-utilities
```

and notice that the package (likely) landed in `~/.local/lib/python3.10/site-packages`:

```
ls ~/.local/lib/python3.10/site-packages
```

will among other subdirectories contain the subdirectory `pytorch_lightning` and this is 
not entirely what we want.

Yet it is still possible to install additional packages by first unsquashing the `user-software.squashfs` file
with 

``` bash
unmake-squashfs
```

(assuming that you had removed the `$CONTAINERROOT/user-software` subdirectory before),
then deleting the SquashFS file:

``` bash
rm $CONTAINERROOT/user-software.squashfs
``` 

and reload the module. Make sure though that you first remove the packages that were accidentally installed
in `~/.local`.

One big warning is needed here though: **If you do a complete re-install of the module with EasyBuild,
everything in the installation directory is erased, including your own installation. So just to make sure,
you may want to keep a copy of the `user-software.squashfs` file elsewhere.**


### Automation of the procedure

**Try this procedure preferably from a directory that doesn't contain too many files or subdirectories
as that may slow down EasyBuild considerably.**

In some cases it is possible to adapt the EasyConfig file to also install the additional Python packages
that are not yet included in the container. This is demonstrated in the 
`PyTorch-2.2.0-rocm-5.6.1-python-3.10-singularity-exampleVenv-20240315.eb` example EasyConfig file
which is available on LUMI. First load EasyBuild to install containers, e.g.,

``` bash
module load LUMI partition/container EasyBuild-user
```

and then we can use EasyBuild to copy the recipe to our current directory:

``` bash
eb --copy-ec PyTorch-2.2.0-rocm-5.6.1-python-3.10-singularity-exampleVenv-20240315.eb .
```

You can now inspect the `.eb` file with your favourite editor. This file basically defines a lot
of Python variables that EasyBuild uses, but is also a small program so we can even define and use
extra variables that EasyBuild does not know. The magic happens in two blocks.

First,

``` python
local_pip_requirements = """
torchmetrics
pytorch-lightning

"""
```

<!-- TODO: Is that empty line really needed? -->
(with an empty line at the end) defines the content that we will put in a `requirements.txt` file to 
tell `pip` which packages we want to install.

The second part of the magic happens in some lines in the `postinstallcmds` block, a list of commands
that EasyBuild will execute after the default installation procedure (which only copies the container
`.sif` file to its location). Four lines in particular perform the magic:

``` python
    f'cat >%(installdir)s/user-software/venv/requirements.txt <<EOF {local_pip_requirements}EOF',
    f'singularity exec --bind {local_singularity_bind} --bind %(installdir)s/user-software:/user-software %(installdir)s/{local_sif} bash -c \'source /runscripts/init-conda-venv ; cd /user-software/venv ; pip install -r requirements.txt\'',
    '%(installdir)s/bin/make-squashfs',
    '/bin/rm -rf %(installdir)s/user-software',
```

The first line creates the `requirements.txt` file from the `local_pip_requirements` variable that we have
created. The way to do this is a bit awkward by creating a shell command from it, but it works in most cases.
The second line then calls `pip install` in the singularity container. At this point there is no module yet
so we need to do all bindings by hand and use variables that are known to EasyBuild. 
The third line then creates the `user-software.squashfs` file and the last line deletes the `user-software`
subdirectory. These four lines are generic as the package list is defined via the 
`local_pip_requirements` environment variable.


## Alternative: Direct access (without the EasyBuild-generated PyTorch module)

### Getting the container image

The PyTorch containers are available in the following subdirectories of `/appl/local/containers`:

-   `/appl/local/containers/sif-images`: Symbolic link to the latest version of the container
    with the given mix of components/packages mentioned in the filename.
    Other packages in the container may vary over time and change without notice.

-   `/appl/local/containers/tested-containers`: Tested containers provided as a Singulartiy `.sif` file
    and a docker-generated tarball. Containers in this directory are removed quickly when a new version
    becomes available.

-   `/appl/local/containers/easybuild-sif-images`: Singularity `.sif` images used with the EasyConfigs
    that we provide. They tend to be available for a longer time than in the other two subdirectories.

If you depend on a particular version of a container, we recommend that you copy the container to
your own file space (e.g., in `/project`,) as there is no guarantee the specific version will remain
available centrally on the system for as long as you want.

When using the containers without the modules, you will have to take care of the bindings as some
system files are needed for, e.g., RCCL. The recommended mininmal bindings are:

```
-B /var/spool/slurmd,/opt/cray/,/usr/lib64/libcxi.so.1
```

and the bindings you need to access the files you want to use from `/scratch`, `/flash` and/or `/project`: 

```
-B /pfs,/scratch,/projappl,/project,/flash,/appl
```

Note that the list recommended bindings may change after a system update.

If you want to quickly check what Python packages are available in the containers in those directories,
you don't need all the bind points and a quick

```
singularity exec <path-to-sif-file> bash -c '$WITH_CONDA ; pip list'
```

will do. Note the single quotes though as we don't want the `$WITH_CONDA` to be expanded outside 
the container (and of course replace `<path-to-sif-file>` with the actual path to and name of 
the SIF file you want to check.)

Alternatively, you can also build your [own container image on top of the
ROCm containers that we provide with cotainr](../../r/rocm/index.md#using-the-images-as-base-image-for-cotainr).

If you use PyTorch containers from other sources, take into account that

-   They need to explicitly use ROCm-enabled versions of the packages. NVIDIA packages
    will not work.

-   The RCCL implementation provided in the container will likely not work well with the
    communication network and the 
    [AWS RCCL plugin for OFI](../../a/aws-ofi-rccl/index.md) plugin will still need to be 
    installed in a way that the libfabric library on LUMI is used.

-   Similarly the `mpi4py` package (if included) may not be compatible with the interconnect
    on LUMI, also resulting in poor performance or failure. For AI packages, things will
    often still be OK as MPI is often only used during the initialisation after which 
    communication is done through RCCL. 
    You may want to make sure that an
    MPI implementation that is ABI-compatible with Cray MPICH is used so that you can then try
    to overwrite it with Cray MPICH.

The LUMI User Support Team tries to support the containers that it provides as good as possible,
but we are not the PyTorch support team and have limited resources. In no way is it the task of
the LUST to support any possible container from any possible source. See also our page
["Software Install Policy](https://docs.lumi-supercomputer.eu/software/policy/)
in the main LUMI documentation.


### Example: Distributed learning without the wrappers

For easy comparison, we use the same
[mnist example](https://github.com/Lumi-supercomputer/lumi-reframe-tests/tree/main/checks/containers/ML_containers/src/pytorch/mnist)
already used in the ["Distributed learning example" with the wrapper scripts](index.md#distributed-learning-example).
The text is written in such a way though that it can be read without first reading that section.


1.  First one needs to create the script `get-master.py` that will be used to determine the
    master node for communication:

    ``` python
    import argparse
    def get_parser():
        parser = argparse.ArgumentParser(description="Extract master node name from Slurm node list",
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
        parser.add_argument("nodelist", help="Slurm nodelist")
        return parser


    if __name__ == '__main__':
        parser = get_parser()
        args = parser.parse_args()

        first_nodelist = args.nodelist.split(',')[0]

        if '[' in first_nodelist:
            a = first_nodelist.split('[')
            first_node = a[0] + a[1].split('-')[0]

        else:
            first_node = first_nodelist

        print(first_node)
    ```
2.  Next we need another script that will run in the container to set up a number of
    environment variables that are needed to run PyTorch successfully on LUMI and at
    the end, call Python to run our example. Let's store the following script as
    `run-pytorch.sh`.

    ``` bash
    #!/bin/bash -e

    # Make sure GPUs are up
    if [ $SLURM_LOCALID -eq 0 ] ; then
        rocm-smi
    fi
    sleep 2

    # !Remove this if using an image extended with cotainr or a container from elsewhere.!
    # Start conda environment inside the container
    $WITH_CONDA

    # MIOPEN needs some initialisation for the cache as the default location
    # does not work on LUMI as Lustre does not provide the necessary features.
    export MIOPEN_USER_DB_PATH="/tmp/$(whoami)-miopen-cache-$SLURM_NODEID"
    export MIOPEN_CUSTOM_CACHE_DIR=$MIOPEN_USER_DB_PATH

    if [ $SLURM_LOCALID -eq 0 ] ; then
        rm -rf $MIOPEN_USER_DB_PATH
        mkdir -p $MIOPEN_USER_DB_PATH
    fi
    sleep 2

    # Optional! Set NCCL debug output to check correct use of aws-ofi-rccl (these are very verbose)
    export NCCL_DEBUG=INFO
    export NCCL_DEBUG_SUBSYS=INIT,COLL

    # Set interfaces to be used by RCCL.
    # This is needed as otherwise RCCL tries to use a network interface it has
    # no access to on LUMI.
    export NCCL_SOCKET_IFNAME=hsn0,hsn1,hsn2,hsn3
    export NCCL_NET_GDR_LEVEL=3

    # Set ROCR_VISIBLE_DEVICES so that each task uses the proper GPU
    export ROCR_VISIBLE_DEVICES=$SLURM_LOCALID

    # Report affinity to check
    echo "Rank $SLURM_PROCID --> $(taskset -p $$); GPU $ROCR_VISIBLE_DEVICES"

    # The usual PyTorch initialisations (also needed on NVIDIA)
    # Note that since we fix the port ID it is not possible to run, e.g., two
    # instances via this script using half a node each.
    export MASTER_ADDR=$(python get-master.py "$SLURM_NODELIST")
    export MASTER_PORT=29500
    export WORLD_SIZE=$SLURM_NPROCS
    export RANK=$SLURM_PROCID
    export ROCR_VISIBLE_DEVICES=$SLURM_LOCALID

    # Run app
    cd /workdir/mnist
    python -u mnist_DDP.py --gpu --modelpath model
    ```

    ??? Note "What's going on in this script? (click to expand)"
        The script sets a number of environment variables. Some are fairly standard when using PyTorch
        on an HPC cluster while others are specific for the LUMI interconnect and architecture or the 
        AMD ROCm environment.

        At the start we just print some information about the GPU. We do this only ones on each node
        on the process which is why we test on `$SLURM_LOCALID`, which is a numbering starting from 0
        on each node of the job:

        ``` bash
        if [ $SLURM_LOCALID -eq 0 ] ; then
            rocm-smi
        fi
        sleep 2
        ```

        The container uses a Conda environment internally. So to make the right version of Python
        and its packages availabe, we need to activate the environment. The precise command to
        activate the environment is stored in `$WITH_CONDA` and we can just call it by specifying
        the variable as a bash command.

        The `MIOPEN_` environment variables are needed to make 
        [MIOpen](https://rocm.docs.amd.com/projects/MIOpen/en/latest/) create its caches on `/tmp`
        as doing this on Lustre fails because of file locking issues:

        ``` bash
        export MIOPEN_USER_DB_PATH="/tmp/$(whoami)-miopen-cache-$SLURM_NODEID"
        export MIOPEN_CUSTOM_CACHE_DIR=$MIOPEN_USER_DB_PATH

        if [ $SLURM_LOCALID -eq 0 ] ; then
            rm -rf $MIOPEN_USER_DB_PATH
            mkdir -p $MIOPEN_USER_DB_PATH
        fi
        ```

        It is also essential to tell RCCL, the communication library, which network adapters to use. 
        These environment variables start with `NCCL_` because ROCm tries to keep things as similar as
        possible to NCCL in the NVIDIA ecosystem:

        ```
        export NCCL_SOCKET_IFNAME=hsn0,hsn1,hsn2,hsn3
        export NCCL_NET_GDR_LEVEL=3
        ```

        Without this RCCL may try to use a network adapter meant for system management rather than
        inter-node communications!

        We also set `ROCR_VISIBLE_DEVICES` to ensure that each task uses the proper GPU.
        This is again based on the local task ID of each Slurm task.

        Furthermore some environment variables are needed by PyTorch itself that are also needed on
        NVIDIA systems.

        PyTorch needs to find the master for communication which is done through the
        `get-master.py` script that we created before:

        ``` bash
        export MASTER_ADDR=$(python get-master.py "$SLURM_NODELIST")
        export MASTER_PORT=29500
        ```

        **As we fix the port number here, the `conda-python-distributed` script that we provide, 
        has to run on exclusive nodes.
        Running, e.g., 2 4-GPU jobs on the same node with this command will not work as there will be
        a conflict for the TCP port for communication on the master as `MASTER_PORT` is hard-coded in 
        this version of the script.**

    Make sure the `run-pytorch.sh` script is executable:

    ``` bash
    chmod ug+x run-pytorch.sh
    ```

3.  The mnist example also needs some data files. We can get them in the job script (as we did before)
    but also simply install them now, avoiding repeated downloads when using the script multiple times
    (in the example with wrappers it was in the job script to have a one file example).
    Assuming you do this on the login nodes where the `wget` program is already available,

    ``` bash
    mkdir mnist ; pushd mnist
    wget https://raw.githubusercontent.com/Lumi-supercomputer/lumi-reframe-tests/main/checks/containers/ML_containers/src/pytorch/mnist/mnist_DDP.py
    mkdir -p model ; cd model
    wget https://github.com/Lumi-supercomputer/lumi-reframe-tests/raw/main/checks/containers/ML_containers/src/pytorch/mnist/model/model_gpu.dat
    popd
    ```

4.  Finaly we can create our jobscript, e.g. `mnist.slurm`, which we will launch from the directory
    that also contains the `mnist` subdirectory and `get-master.py` and `run-pythorch.sh` scripts and the
    container image.

    ```bash
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

    CONTAINER=your-container-image.sif

    c=fe
    MYMASKS="0x${c}000000000000,0x${c}00000000000000,0x${c}0000,0x${c}000000,0x${c},0x${c}00,0x${c}00000000,0x${c}0000000000"

    srun --cpu-bind=mask_cpu:$MYMASKS \
    singularity exec \
        -B /var/spool/slurmd \
        -B /opt/cray \
        -B /usr/lib64/libcxi.so.1 \
        -B $PWD:/workdir \
        $CONTAINER /workdir/run-pytorch.sh
    ```
    
    (if you get mpi4py-related error messages in some of the older containers you may have to add `-B /usr/lib64/libjansson.so.4` also.)


## Links

-   [Latest edition of the "Moving your AI training jobs to LUMI" workshop](https://lumi-supercomputer.github.io/AI-latest)

    