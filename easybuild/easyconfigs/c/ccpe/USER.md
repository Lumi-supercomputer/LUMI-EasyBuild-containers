# User instructions for the HPE CPE containers.

!!! Warning "These containers are beta software"
    They are made available by HPE without guarantee of suitability for your
    purpose, as a way for users to test programming environments that are not
    (yet) on the system. 
    
    LUST together with HPE have made modules and implemented changes to the 
    containers to adapt them to LUMI and integrate somewhat in the regular 
    environment.
    
    However, working with these containers is different from working with a 
    programming environment that is installed natively on the system and requires
    a good insight in how containers work. So they are not for every user, and
    LUST can only offer very limited support. These containers are only for 
    users who are very experienced with the Cray Programming Environment and also
    understand how singularity containers work.
    
    The container only offers `PrgEnv-cray` and `PrgEnv-gnu`. 
    With some imports from the system, we also offer `PrgEnv-amd`, but it
    may not be entirely as intended by the version of the PE as we may be 
    using a different version of ROCm. The container does contain some
    elements of `PrgEnv-nvidia` but that is obviously not functional on LUMI.
    `PrgEnv-aocc` is not available.
    
    HPE has a community Slack channel for feedback and questions at
    [slack.hpdev.io](https://slack/hpdev.io/), channel `#hpe-cray-programming-environment`,
    but bear in mind that this is mostly a community channel, monitored
    by some developers, but those developers don't have time to answer each and
    every question themselves. It is a low volume channel and in no means
    a support channel for inexperienced users.
    
    LUST cannot really offer much support, though we are interested in learning about 
    issues as this is useful feedback for HPE. These containers are really 
    meant for experienced users who want to experiment with a newer version before 
    it becomes available on LUMI.

    
## Where to get the containers?

The CPE containers are made available in `/appl/local/containers/easybuild-sif-images`.

Note the licensing conditions though. These containers should only be used on LUMI.


## How to enable the containers?

We recommend using our EasyBuild modules to run the HPE CPE containers
as these modules do create a lot of bind mounts to provide all necessary
parts from the system to the container.

All modules provide a number of environment variables to make life easier:

-   Outside (and brought into) the container, `SIF` and `SIFCCPE` point to the container file,
    which is very handy to use with the `singularity` command.
    
-   Inside the container, `INITCCPE` contains the commands to fully initialise
    the CPE in the container. Use as `eval $INITCCPE`.
    
    This is not needed when using `singularity run` or the corresponding wrapper script.

-   Outside (and brought into) the container, `EXPORTCCPE` is a list of environment
    variables set by the `ccpe` modules that we want to bring in the container or
    in a job script, even if we otherwise want to start the job script with a clean
    environment.

-   Outside (and brought into) the container, `SWITCHTOCCPE` is an environment variable
    containing a large block of code that is used at the start of the job script to
    switch to executing the job script in the container.

The module also provides access to four wrapper scripts to start the container.
Note though that those wrapper scripts only function properly when the module
is loaded. They do not take care of the bindings themselves and in that sense
are certainly different from the wrapper scripts provided by Tykky/lumi-container-wrapper.
All these scripts do however purge all modules before going into the container,
as modules from the system PE are not valid in the container, and fully clear Lmod.
Currently, the following scripts are provided:

-   `ccpe-shell` to start a shell in the container. The arguments of `ccpe-shell`
    are simply added to the `singularity shell $SIF`.
    
-   `ccpe-exec` to run a command in the container. The arguments of `ccpe-exec` 
    are simply added to the `singularity exec $SIF` command.
    
-   `ccpe-run` to run the container. The arguments of `ccpe-run`
    are simply added to the `singularity run $SIF` command.
    
-   `ccpe-singularity` will clean up the environment for the singularity, then
    call `singularity` passing all arguments to `singularity`. So with this 
    command, you still need to specify the container also (e.g., using the 
    `SIF` or `SIFCCPE` environment variable), but can specify options for 
    the singularity subcommand also.


## Installing the EasyBuild recipes

To install the container module, chose the appropriate EasyConfig from this page,
and make sure you have a properly set up environment as explained in the 
LUMI documentation in the "Installing software"section, 
["EasyBuild"](https://docs.lumi-supercomputer.eu/software/installing/easybuild/).
In particular, it is important to set a proper location using `EBU_USER_PREFIX`,
as your home directory will quickly fill up if you install in the default 
location. To install the container, use

```
module load LUMI/24.03 partition/container EasyBuild-user
eb <name_of_easyconfig>
```

e.g., 

```bash
module load LUMI/24.03 partition/container
eb ccpe-25.03-B-rocm-6.3-SP5-LUMI.eb
```

Any more recent version of the LUMI stack on the system will also work for the installation.

After that, the module installed by the EasyConfig (in the example,
`ccpe/25.03-B-rocm-6.3-SP5-LUMI`) will be available in all versions of the `LUMI` stack on
the system and in `CrayEnv`. So, e.g.,

```
module load CrayEnv ccpe/25.03-B-rocm-6.3-SP5-LUMI
```

is enough to gain access to the container and all its tools explained on this page.


## How to get a proper environment in the container?

Unfortunately, there seems to be no way to properly (re-)initialise the shell 
or environment in the container directly through `singularity shell` or 
`singularity exec`.

The following strategies can be used:

-   In the container, the environment variable `INITCCPE` contains the necessary
    commands to get a working Lmod environment again, but then with the relevant
    CPE modules for the container. Run as
    
    ```
    eval $INITCCPE
    ```
    
-   Alternatively, sourcing `/etc/bash.bashrc` will also properly set up Lmod.

Cases that do give you a properly initiated shell, are `singularity exec bash -i` 
and `singularity run`. These commands do source `/etc/bash.bashrc` but do not 
read `/etc/profile`. But the latter shouldn't matter too much as that is usually
used to set environment variables, and those that are typically set in that file
and the files it calls, now come from the regular environment on LUMI and are
fine for the container, or are overwritten anyway
by the files sourced by `/etc/bash.bashrc`.


## Launching jobs: A tale of two environments

The problem with running jobs, is that they have to deal with two incompatible
environments:

1.  The environment outside the container that does not know about the HPE Cray
    PE modules of the PE version in the container, and may not know about some other
    modules depending on how `/appl/lumi` is set up (as this may point to a totally
    separate software stack specific for the container but mounted on `/appl/lumi`
    so that it behaves just as the regular stacks on the system).
    
2.  The environment inside the container that does not know about the HPE Cray PE
    modules installed in the system, and may not know about some other 
    modules depending on how `/appl/lumi` is set up.

This is important, because unloading a module in Lmod requires access to the correct
module file, as unloading is done by "executing the module file in reverse": The module
file is executed, but each action that changes the environment, is reversed. Even a
`module purge` will not work correctly without the proper modules available. Environment
variables set by the modules may remain set. This is also why the module provides the
`ccpe-*` wrapper scripts for singularity: These scripts are meant to be executed in 
an environment that is valid outside the container, and clean up that environment before
starting commands in the container so that the container initialisation can start from 
a clean inherited environment.

??? Example "See how broken the job environment can be..."

    *This example is developed running a container for the 24.11 programming environment
    on LUMI in March 2025 with the 24.03 programming environment as the default.*

    The 24.03 environment comes with `cce/17.0.1` while the 24.11 environment comes with
    `cce/18.0.1`. When loading the module, it sets the environment variable 'CRAY_CC_VERSION'
    to the version of the CCE compiler.

    Start up the container:

    ```bash
    ccpe-run
    ```

    Check the version of the module tool:

    ```bash
    module --version
    ```

    which returns version 8.7.37:

    ```
    Modules based on Lua: Version 8.7.37  [branch: release/cpe-24.11] 2024-09-24 16:53 +00:00
        by Robert McLay mclay@tacc.utexas.edu    
    ```
    
    and list the modules:

    ```bash
    module list
    ```

    returns

    ```
    Currently Loaded Modules:
    1) craype-x86-rome                                 6) cce/18.0.1           11) PrgEnv-cray/8.6.0
    2) libfabric/1.15.2.0                              7) craype/2.7.33        12) ModuleLabel/label (S)
    3) craype-network-ofi                              8) cray-dsmml/0.3.0     13) lumi-tools/24.05  (S)
    4) perftools-base/24.11.0                          9) cray-mpich/8.1.31    14) init-lumi/0.2     (S)
    5) xpmem/2.9.6-1.1_20240510205610__g087dc11fc19d  10) cray-libsci/24.11.0

    Where:
    S:  Module is Sticky, requires --force to unload or purge
    ```

    so we start with the Cray programming environment loaded.

    Now use an interactive `srun` session to start a session on the compute node.

    ```bash
    srun -n1 -c1 -t10:00 -psmall -A<my_account> --pty bash
    ```

    Let's check the version of the module tool again:

    ```bash
    module --version
    ```

    now returns version 8.7.32: 
    
    ```
    Modules based on Lua: Version 8.7.32  2023-08-28 12:42 -05:00
        by Robert McLay mclay@tacc.utexas.edu
    ```
    
    as we are no longer in the container but in a regular LUMI environment. 

    Trying

    ```bash
    module list
    ```

    returns

    ```
    Currently Loaded Modules:
    6) craype-x86-rome                                 6) cce/18.0.1           11) PrgEnv-cray/8.6.0
    7) libfabric/1.15.2.0                              7) craype/2.7.33        12) ModuleLabel/label (S)
    8) craype-network-ofi                              8) cray-dsmml/0.3.0     13) lumi-tools/24.05  (S)
    9) perftools-base/24.11.0                          9) cray-mpich/8.1.31    14) init-lumi/0.2     (S)
    10) xpmem/2.9.6-1.1_20240510205610__g087dc11fc19d  10) cray-libsci/24.11.0

    Where:
    S:  Module is Sticky, requires --force to unload or purge
    ```

    so the modules we were using in the container.

    The environment variable `CRAY_CC_VERSION` is also set:

    ```bash
    echo $CRAY_CC_VERSION
    ```

    returns `18.0.1`.

    Now do a

    ```bash
    module purge
    ```

    which shows the perfectly normal output

    ```
    The following modules were not unloaded:
    (Use "module --force purge" to unload all):

    1) ModuleLabel/label   2) lumi-tools/24.05   3) init-lumi/0.2

    The following sticky modules could not be reloaded:

    1) lumi-tools
    ```

    and 

    ```bash
    module list
    ```

    now shows

    ```
    Currently Loaded Modules:
    1) ModuleLabel/label (S)   2) lumi-tools/24.05 (S)   3) init-lumi/0.2 (S)

    Where:
    S:  Module is Sticky, requires --force to unload or purge
    ```

    but 

    ```bash
    echo $CRAY_CC_VERSION
    ```

    still return `18.0.1`, so even though it appears that the `cce/18.0.1` module has been unloaded,
    not all (if any) environment variables set by the module, have been correctly unset. 

    We can now load the `cce` module again:

    ```bash
    module load cce
    ```

    and now

    ```bash
    module list cce
    ```

    returns

    ```
    Currently Loaded Modules Matching: cce
    1) cce/17.0.1
    ```

    so it appears we have the `cce` module from the system. This went well in this case. And in fact,

    ```bash
    module list
    ```

    which returns

    ```
    Currently Loaded Modules:
    1) ModuleLabel/label (S)   4) craype/2.7.31.11     7) craype-network-ofi   10) PrgEnv-cray/8.5.0
    2) lumi-tools/24.05  (S)   5) cray-dsmml/0.3.0     8) cray-mpich/8.1.29    11) cce/17.0.1
    3) init-lumi/0.2     (S)   6) libfabric/1.15.2.0   9) cray-libsci/24.03.0

    Where:
    S:  Module is Sticky, requires --force to unload or purge
    ```

    suggests that some other modules, like `cray-mpich` and `cray-libsci` have also been reloaded.

    ```bash
    echo $CRAY_CC_VERSION
    ```

    returns `17.0.1` as expected, and after

    ```bash
    module purge
    ```

    we now note that

    ```bash
    echo $CRAY_CC_VERSION
    ```

    returns nothing and is reset.

    However, it is clear that we are now in an environment where we cannot use what we prepared in the
    container.
    

## Job script template to run the batch script in the container

To make writing job scripts easier, some common code has been put in an
environment variable that can be executed via the `eval` function of bash.
 
This job script will start with as clean an environment as possible, except when called
from a correctly initialised container with passing of the full environment:
 
<!-- One space indent needed as this goes through a too simple script that will
     replace a # in the first column. -->
   
 ``` bash linenums="1"
 #!/bin/bash
 #
 # This test script should be submitted with sbatch from within a CPE 24.11 container.
 # It shows very strange behaviour as the `module load` of some modules fails to show
 # those in `module list` and also fails to change variables that should be changed.
 #
 #SBATCH -J example-jobscript
 #SBATCH -p standard
 #SBATCH -N 2
 #SBATCH -n 32
 #SBATCH -c 8
 #SBATCH -t 5:00
 #SBATCH -o %x-%j.md
 # And add line for account
 
 ################################################################################
 #
 # Always start with this block.
 # Its function is to restart the execution of the job script in the container
 # so that you can write a regular job script as if you are working in the
 # version of the Cray PE in the container.
 #

 #
 # Ensure that the environment variable SWITCHTOCCPE and with it 
 #
 if [ -z "${SWITCHTOCCPE}" ]
 then
     module load CrayEnv ccpe/25.03-B-rocm-6.3-SP5-LUMI || exit
 fi
 
 #
 # Now switch to the container and clean up environments when needed and possible.
 #
 eval $SWITCHTOCCPE
 
 ################################################################################
 #
 # Here you have the container environment and can simply work as you would 
 # normally do:  Build your environment and start commands. But you'll still 
 # have to be careful with srun as whatever you start with srun will not 
 # automatically run in the container.
 #
 
 # Always reconstruct the environment and don't rely on something inherited from
 # the calling shell as this will be wrong if the job script is not launched from
 # within the container.
 module load LUMI/25.03 partition/C
 module load lumi-CPEtools/1.2-cpeCray-25.03-hpcat-0.9

 # We also need a little trick with srun.
 # Template: ccpe-srun <srun arguments> singularity exec $SIFCCPE <command>
 ccpe-srun singularity exec $SIFCCPE hybrid_check
 ``` 

What this job script does:

-   The body of the job script (lines after `eval $SWITCHTOCCPE`) will always run in the container.

    This is where you would insert your code that you want to run in the container.

-   The environment in the container after `eval $SWITCHTOCCPE`:
  
    -   When launching this batch script from within the container:

        -   When launched without `--export` flag, the body will run in the environment of the calling container.

            It does require that the job is started from a properly initialised container with active Lmod though,
            as that currently sets the environment variable to detect if the container is properly initialised. 

            If you started the calling container with `ccpe-run`, there is no issue though. In other cases, you 
            may have to execute `eval $INITCCPE`. But in general, if you were able to load Cray PE modules before
            calling `sbatch`, you should be OK.

        -   When launched using `sbatch --export=$EXPORTCCPE`, the body will run in a clean container environment,
            but will not need to re-load the container module.

        -   Behaviour with `--export=none`: As the container cannot be located, 
            
            ``` bash
            if [ -z "${SWITCHTOCCPE}" ]
            then
                module load CrayEnv ccpe/25.03-B-rocm-6.3-SP5-LUMI || exit
            fi
            ```

            will first try to load the container module, and if successful, proceed creating a clean environment.

            **Note that you need to adapt that line to the module you are actually using!**

    -   When launching this batch script from a regular system shell:

        -   When launched using `sbatch --export=$EXPORTCCPE`, the body will run in a clean container environment.

        -   When launched without `--export` flag, `eval $SWITCHTOCCPE` will first try to clean the system
            environment (and may fail during that phase if it cannot find the modules that you had loaded
            when calling `sbatch`.)

            If the `ccpe` module was not loaded when calling the job script, the block 
            
            ``` bash
            if [ -z "${SWITCHTOCCPE}" ]
            then
                module load CrayEnv ccpe/25.03-B-rocm-6.3-SP5-LUMI || exit
            fi
            ```

            will try to take care of that. If the module can be loaded, the script will proceed with building
            a clean container environment.
            
            **Note that you need to adapt that line to the module you are actually using!**

        -   Behaviour with `--export=none`: As the container cannot be located, 
            
            ``` bash
            if [ -z "${SWITCHTOCCPE}" ]
            then
                module load CrayEnv ccpe/25.03-B-rocm-6.3-SP5-LUMI || exit
            fi
            ```

            will first try to load the container module, and if successful, proceed creating a clean environment.

            **Note that you need to adapt that line to the module you are actually using!**

    So in all cases you get a clean environment (which is the only logical thing to get) *except*
    if `sbatch` was already called from within the container without `--export` flag.

-   To run the actual command, there we do not use `srun` but the function `ccpe-srun` defined in the 
    container, and we must also ensure that we start the command in the singularity container.

    The reason why we need `ccpe-srun` is that `PATH` and `LD_LIBRARY_PATH` are not passed to the
    container, but overwritten by values set in the initialisation routines of the container. The
    solution is to enforce the values of the calling environment via 
    `SINGULARITYENV_PATH` and `SINGULARITYENV_LD_LIBRARY_PATH`. `ccpe-srun` is just a very small
    bash funtion:

    ``` bash
    function ccpe-srun() {
        SINGULARITYENV_PATH=$PATH SINGULARITYENV_LD_LIBRARY_PATH=$LD_LIBRARY_PATH srun "$@" 
    }
    ```

    so instead of using `cpe-srun` in the above example, one could also have used

    ``` bash
    SINGULARITYENV_PATH=$PATH SINGULARITYENV_LD_LIBRARY_PATH=$LD_LIBRARY_PATH srun \
      singularity exec $SIFCCPE hybrid_check
    ```

    or

    ``` bash
    export SINGULARITYENV_PATH=$PATH 
    export SINGULARITYENV_LD_LIBRARY_PATH=$LD_LIBRARY_PATH 
    srun singularity exec $SIFCCPE hybrid_check
    ```

For technical information about how all this works under the hood (and it may 
be important to understand this to always use the template correctly), check the
[subsection "Starting jobs"](#starting-jobs) in the 
["Technical documentation"](#technical-documentation) section of this page.


## Known restrictions    

-   `PrgEnv-aocc` is not provided by the container. The ROCm version is taken from the
    system and may not be the optimal one for the version of the PE.

-   `salloc` does not work in the container.

    Workaround: Use `salloc` outside the container, then go into the container with 
    `ccpe-run`.
