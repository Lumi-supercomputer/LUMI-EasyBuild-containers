# Technical information about the AMD PyTorch containers.

## How to check what's in the container?

-   The Python, PyTorch and ROCm versions are included in the version of the module.

-   To find the version of Python packages,

    ```
    singularity exec $SIF bash -c '$WITH_CONDA ; pip list'
    ```
    
    after loading the module. This can even be done on the login nodes.
    It will return information about all Python packages.

-   Deepspeed: 

    -   Leaves a script 'deepspeed' in `/opt/miniconda3/envs/pytorch/bin`
    
    -   Leaves packages in `/opt/miniconda3/envs/pytorch/lib/python3.10/site-packages/deepspeed`
    
    -   Finding the version:
    
        ```
        singularity exec $SIF bash -c '$WITH_CONDA ; pip list | grep deepspeed'
        ```
    
        or the clumsy way without `pip`: 
    
        ```
        singularity exec $SIF bash -c \
          'grep "version=" /opt/miniconda3/envs/pytorch/lib/python3.10/site-packages/deepspeed/git_version_info_installed.py'
        ```
        
        (Test can be done after loading the module on a login node.)

-   [flash-attention](https://github.com/Dao-AILab/flash-attention)
    and its fork, [the ROCm port](https://github.com/ROCm/flash-attention)
    
    -   Leaves a `flash_attn` and corresponding `flash_attn-<version>.dit-info` subdirectory 
        in `/opt/miniconda3/envs/pytorch/lib/python3.10/site-packages`.

    -   To find the version:
    
        ```
        singularity exec $SIF bash -c '$WITH_CONDA ; pip list | grep flash-attn'
        ```
    
        or the clumsy way without `pip:
    
        ```
        singularity exec $SIF bash -c \
          'grep "__version__" /opt/miniconda3/envs/pytorch/lib/python3.10/site-packages/flash_attn/__init__.py'
        ```
        
        (Test can be done after loading the module on a login node.)
    
    To run a benchmark:

    ```
    srun -N 1 -n 1 \
      --cpu-bind=mask_cpu:0xfe000000000000,0xfe00000000000000,0xfe0000,0xfe000000,0xfe,0xfe00,0xfe00000000,0xfe0000000000 \
      --gpus 8 \
      singularity exec $SIF /runscripts/conda-python-simple \
      -u /opt/wheels/flash_attn-benchmarks/benchmark_flash_attention.py
    ```

-   xformers:

    -   Leaves a `xformers` and corresponding `xformers-<version>.disti-info` subdirectory    
        in `/opt/miniconda3/envs/pytorch/lib/python3.10/site-packages`.
    
    -   To find the version:
    
        ```
        singularity exec $SIF bash -c '$WITH_CONDA ; pip list | grep xformers'
        ```
    
        or the clumsy way without `pip`:
    
        ```
        singularity exec $SIF bash -c \
          'grep "__version__" /opt/miniconda3/envs/pytorch/lib/python3.10/site-packages/xformers/version.py'
        ```
        
        (Test can be done after loading the module on a login node.)
        
    -   Checking the features of `xformers`: 
    
        ```
        singularity exec $SIF bash -c '$WITH_CONDA ; python -m xformers.info'
        ```
        
## EasyBuild

Incomplete!

### Changes made for the 20250404 PyTorch container

Some of those changes were likely overdue!

-   All variables to initilise the conda environment correctly are already set in the 
    container, so the module does no longer do so.
    
-   There is a libjansson.so in the container, so the module does no longer bind 
    `/usr/lib64/libjansson.so.4`. This may turn out to be an issue though as the 
    libjansson.so in the container is an older version than the one on LUMI, so we
    may need to overwrite it with a bind mount.
    
    NOTE: This probably doesn't matter as the library that links to it is recompiled
    and in the container?
    
-   In late July 2025 the `list-packages` script used by CSC was also added to the
    container, even though it is basically just a `pip list` and could even be implemented
    using the `pip` wrapper script.

-   TODO: Check with Samuel if we still need to bind cxi as there is a libfabric in 
    the container that links to a different libcxi.




