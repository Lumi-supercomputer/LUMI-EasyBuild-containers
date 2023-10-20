# LUMI-EasyBuild-containers

Temporary way of working until all TODOs below are implemented:

```
module load LUMI/22.12 partition/G
module load EasyBuild-user
EASYBUILD_SOURCEPATH=$EASYBUILD_SOURCEPATH:<directory with .sif files>
eb PyTorch-2.0.1-rocm-5.5.1-python-3.10-singularity.eb
```

The partition doesn't really matter as long as the same one is used when
running as we do not need specific compiler settings, but since the AMD
containers are for the GPUs it is only logical to install them in
partition/G.

Running then goes like:

```
module load LUMI/22.12 partition/G
module load PyTorch-2.0.1-rocm-5.5.1-python-3.10-singularity.eb
salloc -N1 -pstandard-g -t 30:00
srun -N1 -n1 --gpus 8 singularity exec $SIF /runscripts/python-conda \
    -c 'import torch; print("I have this many devices:", torch.cuda.device_count())'
```


## TODO for this to function

-   Write a routine that produces the path to the SIF files.
    
    -   Motivation: We want to be able to test completely independently from 
        /appl/local/containers to test out new concepts.
        
-   Write a routine that can be used in the modulefiles to set SIF to 
    either the one in the installation directory, of if that one is missing,
    the one in the container repository.
    
-   Adapt the EasyBuild-user module to search for containers in the container
    repository (which is adding a directory to the SOURCEPATH).
    
-   Additional hidden partition "container" to install the container modules,
    and always load that directory. This is because we assume that containers
    are independent of any particular LUMI toolchain and should even be available
    in CrayEnv.

-   Adapt the CrayEnv module and partition module to make the containers available.

