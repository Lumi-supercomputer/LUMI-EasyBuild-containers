# PyTorch container user instructions

**BETA VERSION, problems are possible and they may not be solved quickly.**

The rocm container is developed by AMD specifically for LUMI and contains the
necessary parts explore ROCm. The use is rather limited at the moment as there
is no easy way to build upon an existing container on LUMI. However, from
a shell in the container you can access both the newer ROCm version in the container
and Cray PE which is hosted outside of the container, and read and write from all
your regular directories.

**It is entirely normal that some features in some of the containers will not work.
Each ROCm driver supports only particular versions of packages. E.g., the ROCm 
driver from ROCm 5.2.3 is only guaranteed to support ROCm versions up to and including 5.4
and hence problems can be expected with ROCm 5.5 and newer. There is nothing LUMI
support can do about it. Only one driver version can be active on the system,
and installing a newer version depends on other software on the system also and
is not as trivial as it would be on a PC.**

The EasyBuild installation with the EasyConfigs mentioned below will do two things:

1.  It will copy the container to your own file space. We realise containers can be
    big, but it ensures that you have complete control over when a container is
    removed again.
    
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



## Installation

To install the container with EasyBuild, follow the instructions in the
[EasyBuild section of the LUMI documentation, section "Software"](https://docs.lumi-supercomputer.eu/software/installing/easybuild/),
and use the dummy partition `container`, e.g.:

```
module load LUMI partition/container EasyBuild-user
eb rocm-5.6.1-singularity-20231108.eb
```

To use the container after installation, the `EasyBuild-user` module is not needed nor
is the `container` partition. The module will be available in all versions of the LUMI stack
and in [the `CrayEnv` stack](https://docs.lumi-supercomputer.eu/runjobs/lumi_env/softwarestacks/#crayenv)
(provided the environment variable `EBU_USER_PREFIX` points to the right location).
