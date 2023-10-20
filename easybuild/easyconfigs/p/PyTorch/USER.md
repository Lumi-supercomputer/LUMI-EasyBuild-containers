# PyTorch container user instructions

The PyTorch container is developed by AMD specifically for LUMI and contains the
necessary parts to run PyTorch on LUMI, including the plugin needed for RCCL when
doing distributed AI, and a suitable version of ROCm for the version of PyTorch.

The EasyBuild installation with the EasyConfigs mentioned below will do two things:

1.  It will copy the container to your own file space. We realise containers can be
    big, but it ensures that you have complete control over when a container is
    removed again.
    
    We will remove a container from the system when it is not sufficiently functional
    again, but the container may still work for you. E.g., after an upgrade of the 
    network drivers, the RCCL plugin for the LUMI Slingshot interconnect may be broken,
    but if you run on only one node PyTorch may still work for you.

2.  A module file. When loading the module, a number of environment variables will
    be set to help you use the module and to make it easy to swap the module with a
    different version in your job scripts.
    
    -   `SIF` and `SIFPYTORCH` both contain the name and full path of the singularity
        container file.
        
    -   `SINGULARITY_BINDPATH` will mount all necessary directories from the system,
        including everything that is needed to acces the project, scratch and flash
        file systems.
        
ADD SOMETHING ABOUT THE CONDA ENVIRONMENT IN THE CONTAINER.

The container (when used with `SINGULARITY_BINDPATH` of the module) also provides
the wrapper script `/runscripts/python-conda` to start the Python command from the
conda environment in the container.

Example:

```
salloc -N1 -pstandard-g -t 30:00
srun -N1 -n1 --gpus 8 singularity exec $SIF /runscripts/python-conda \
    -c 'import torch; print("I have this many devices:", torch.cuda.device_count())'
```

After loading the module, the docker definition file used when building the container
is available in the `$EBROOTPYTORCHMINCONTAINER/share/docker-defs` subdirectory.
