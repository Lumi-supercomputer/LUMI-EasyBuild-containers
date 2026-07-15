# Preparing the CPE containers for users

## Downloading the containers

the only way to get access to the containers is to download the containers
from the [HPE support site](https://support.hpe.com/). You will need to sign in or 
[create an account](https://auth.hpe.com/hpe/cf/registration) first.

You can then use the search feature (magnifying glass) to search for "HPE CPE Software Container",
restricting your search to "Drivers and Software". At the time of writing, the most recent version
available was a [container for CPE 24.11](https://support.hpe.com/connect/s/softwaredetails?collectionId=MTX-74c48d9c3d0e460f&tab=releaseNotes)
(but no guarantee that this link remains valid, so therefore also the link).

To the left of the page that opens now, you will actually see a list of older versions also.

**Please read the licensing conditions very carefully!** You are not allowed to distribute the software
(so within a project it is best that every user downloads the software and agrees with the 
license).

You can then use the "Obtain Software" button to get access to the downloadable files.
Select the file, or all three files, and click the "curl Copy" button. This will 
give you a file (downloadUrls.txt) with the `curl` commands that you can use on the 
LUMI login nodes to download the files. The links are only valid for 24 hours and should
not be passed to others.

For 25.09, this procedure has changed again and it is no longer possible to download a complete 
container. Instead a template for a docker recipe has been given that will download all necessary
packages. One issue here is the limited validity of the token that should be used to download
the packages, so you may not even be able to download them all in time.


## 24.11

-   Downloaded file: `HPE_CPE_Container_24.11.5.tar.gz`

    Contains:

    -   `HPE_CPE_Container_24.11.5/cpe_2411.tgz`: Compressed tar file for docker
    -   `HPE_CPE_Container_24.11.5/README.md`
    -   `HPE_CPE_Container_24.11.5/ccpe-config`

-   Untar:

    ```
    tar -xf HPE_CPE_Container_24.11.5.tar.gz
    ```

-   Convert to a singularity image:

    ```
    gunzip HPE_CPE_Container_24.11.5/cpe_2411.tgz
    singularity build cpe-24.11-orig.sif docker-archive://HPE_CPE_Container_24.11.5/cpe_2411.tar
    ```

    Note that this can take half an hour with very little input inbetween.

-   Now we add the basis for Slurm support and a license check to the container:

    -   Create a singularity definition file `cpe-24.11.def`

        ```
        Bootstrap: localimage

        From: cpe-24.11-orig.sif

        %files

            /etc/group
            /etc/passwd

        %post

        cat > /.singularity.d/env/00-license.sh << EOF
        if [ ! -f /etc/slurm/slurm.conf ] || ! /usr/bin/grep -q 'ClusterName=lumi\$' /etc/slurm/slurm.conf
        then 
            echo -e 'This container was prepared by the LUMI User Support Team and can only legally' \
                    '\nbe used on LUMI by LUMI users with a personal active account. Using this' \
                    '\ncontainer on other systems than LUMI or by other than registered active users,' \
                    '\nis considered a breach of the "LUMI General Terms of Use", point 4.\n' \
                    '\nBy using the container you agree to the license' \
                    '\nhttps://downloads.hpe.com/pub/softlib2/software1/doc/p1796552785/v113125/eula-en.html.\n' \
                    '\nIf you see this message on LUMI, then most likely your bindings are not OK.' \
                    '\nPlease also bind mount /etc/slurm/slurm.conf in the container.'
            
            # Break off the initialisation of the container.
            exit
        fi
        EOF

        chmod a+rx /.singularity.d/env/00-license.sh
        ```

    -   Do the build process with singularity:

        ```
        ml PRoot
        export SINGULARITY_TMPDIR=/tmp
        export SINGULARITY_CACHEDIR=/tmp
        singularity build cpe-24.11.sif cpe-24.11.def
        ```

-   The container is now ready to be copied to `/appl/local/containers/easybuild-sif-images`.


## 25.03 (SP5 version)

-   Downloaded file: `HPE_CPE_SLES15_SP5_X86_64_Container_25.3.105.tar.gz`

    Contains:

    -   `HPE_CPE_SLES15_SP5_X86_64_Container_25.3.105/cpe-sles15-sp5-x86-64-25.03.tgz`: Compressed tar file for docker
    -   `HPE_CPE_SLES15_SP5_X86_64_Container_25.3.105/README`
    -   `HPE_CPE_SLES15_SP5_X86_64_Container_25.3.105/ccpe-config`
    -   `HPE_CPE_SLES15_SP5_X86_64_Container_25.3.105/pkgconfig/slurm.pc`
    -   `HPE_CPE_SLES15_SP5_X86_64_Container_25.3.105/bin/cleanup_bcast.sh`

-   Untar:

    ```
    tar -xf HPE_CPE_SLES15_SP5_X86_64_Container_25.3.105.tar.gz
    ```


-   Convert to a singularity image:

    ```
    gunzip HPE_CPE_SLES15_SP5_X86_64_Container_25.3.105/cpe-sles15-sp5-x86-64-25.03.tgz
    singularity build cpe-25.03-SP5-orig.sif docker-archive://HPE_CPE_SLES15_SP5_X86_64_Container_25.3.105/cpe-sles15-sp5-x86-64-25.03.tar
    ```

    Note that this can take half an hour with very little output inbetween.

-   Now we add the basis for Slurm support and a license check to the container:

    -   Create a singularity definition file `cpe-25.03-SP5.def`

        ```
        Bootstrap: localimage

        From: cpe-25.03-SP5-orig.sif

        %files

            /etc/group
            /etc/passwd

        %post

        cat > /.singularity.d/env/00-license.sh << EOF
        if [ ! -f /etc/slurm/slurm.conf ] || ! /usr/bin/grep -q 'ClusterName=lumi\$' /etc/slurm/slurm.conf
        then 
            echo -e 'This container was prepared by the LUMI User Support Team and can only legally' \
                    '\nbe used on LUMI by LUMI users with a personal active account. Using this' \
                    '\ncontainer on other systems than LUMI or by other than registered active users,' \
                    '\nis considered a breach of the "LUMI General Terms of Use", point 4.\n' \
                    '\nBy using the container you agree to the license' \
                    '\nhttps://downloads.hpe.com/pub/softlib2/software1/doc/p1796552785/v113125/eula-en.html.\n' \
                    '\nIf you see this message on LUMI, then most likely your bindings are not OK.' \
                    '\nPlease also bind mount /etc/slurm/slurm.conf in the container.'
            
            # Break off the initialisation of the container.
            exit
        fi
        EOF

        chmod a+rx /.singularity.d/env/00-license.sh
        ```

    -   Do the build process with singularity:

        ```
        ml LUMI PRoot
        export SINGULARITY_TMPDIR=/tmp
        export SINGULARITY_CACHEDIR=/tmp
        singularity build cpe-25.03-SP5.sif cpe-25.03-SP5.def
        ```

-   Preparing ROCm:

    -   Build the '-C'-version of the container with ROCm built in.

    -   Create a tar-file `rocm-6.3.4.tar` in `/opt`: 

        ```
        tar -cf $WORKDIR/rocm-6.3.4.tar rocm-6.3.4
        ```

    -   Outside the container:
  
        ```
        umask 002
        cd $WORKDIR
        mkdir tmp && cd tmp
        tar -xf ../rocm-6.3.4.tar
        mksquashfs rocm-6.3.4 ../rocm-6.3.4.squashfs -processors 16
        ```

## 25.09 (SP6 version)

-   We start from a container prepared by Alfio Lazarro.

    The correct one turned out to be `cpe_sles15_sp6_x86_64_runko.sif` as
    `ccpe_sles15_sp6_x86_64.sif` did not contain all modulefiles.

-   Now we add the basis for Slurm support and a license check to the container:

    -   Create a singularity definition file `cpe-25.09-SP6.def`

        ```
        Bootstrap: localimage

        From: cpe-25.09-SP6-orig.sif

        %files

            /etc/group
            /etc/passwd

        %post

        cat > /.singularity.d/env/00-license.sh << EOF
        if [ ! -f /etc/slurm/slurm.conf ] || ! /usr/bin/grep -q 'ClusterName=lumi\$' /etc/slurm/slurm.conf
        then 
            echo -e 'This container was prepared by the LUMI User Support Team and can only legally' \
                    '\nbe used on LUMI by LUMI users with a personal active account. Using this' \
                    '\ncontainer on other systems than LUMI or by other than registered active users,' \
                    '\nis considered a breach of the "LUMI General Terms of Use", point 4.\n' \
                    '\nBy using the container you agree to the license' \
                    '\nhttps://downloads.hpe.com/pub/softlib2/software1/doc/p1796552785/v113125/eula-en.html.\n' \
                    '\nIf you see this message on LUMI, then most likely your bindings are not OK.' \
                    '\nPlease also bind mount /etc/slurm/slurm.conf in the container.'
            
            # Break off the initialisation of the container.
            exit
        fi
        EOF

        chmod a+rx /.singularity.d/env/00-license.sh
        ```

    -   Do the build process with singularity:

        ```
        ml LUMI PRoot
        export SINGULARITY_TMPDIR=/tmp
        export SINGULARITY_CACHEDIR=/tmp
        singularity build cpe-25.09-SP6.sif cpe-25.09-SP6.def
        ```

-   If you want to build a container using EasyBuild with ROCm to extract the ROCm version
    afterwards, we first need to prepare a basic software stack as otherwise the commands
    to initialise the container will fail. This should be done on uan06, with umask set
    to 0002.

    -   Run

        ``` bash
        mkdir -p /appl/lumi/ccpe/appl/25.09-6.4
        cd /appl/lumi/ccpe/appl/25.09-6.4
        git clone https://github.com/Lumi-supercomputer/LUMI-SoftwareStack.git
        git clone https://github.com/Lumi-supercomputer/LUMI-EasyBuild-contrib.git
        # And if the necessary branches are already prepared...
        cd LUMI-SoftwareStack && git checkout -b stack/25.09-6.4 && cd -
        cd LUMI-EasyBuild-contrib && git checkout -b stack/25.09-6.4 && cd -
        ```

    -   We do have a chicken-and-egg problem now though. Our container EasyConfigs do a number
        of tests that will fail if the `prepare_LUMI.sh` script is not run, but that script
        will fail to create the correct links if it is run outside the container. 

        So there is currently no other solution than to build the container with sanity checks
        disabled in the EasyConfig, start the container and run the script there.

        So in the container:

        ``` bash
        umask 0002
        cd /appl/lumi/LUMI-SoftwareStack/scripts
        ./prepare_LUMI.sh
        ```

-   Preparing ROCm:

    -   Build the '-C'-version of the container with ROCm built in.

    -   Create a tar-file `rocm-6.4.4.tar` in `/opt`: 

        ```
        tar -cf $WORKDIR/rocm-6.4.4.tar rocm-6.4.4
        ```

    -   Outside the container:
  
        ```
        umask 002
        cd $WORKDIR
        mkdir tmp && cd tmp
        tar -xf ../rocm-6.4.4.tar
        mksquashfs rocm-6.4.4 ../rocm-6.4.4.squashfs -processors 16
        ```

## 26.03

We have chosen to put a lot of software in the container already, even though it likely makes it
non-portable across system updates. But like this, one can start developing with the container
with minimal bindings, making it easier and less error-prone to use.

-   We started from a container prepared by Alfio Lazzaro: cpe_26.03.01_sles15_sp7_x86_64.sif

-   Rather than using bindings, we copied a number of files from LUMI into the container:

    -   Missing LUA files/directories for lua-posix: `/usr/lib64/lua/5.3/posix`, `/usr/share/lua/5.3/posix`.

        Several other ways were tried, but we could not find a repo from which we could download
        lua-posix or luarocks (to install), and first installing rocks from sources was a bit too much.

    -   Munge: Used by Slurm and possibly other packages: `/usr/lib64/libmunge.so.2.0.0`.
        Optionally, we could also copy `/usr/bin/munge`, the corresponding command.
  
        And also link `libmunge.so.2` to this file.

    -   `libdrm`: Not entirely sure if we really need this as this is part of the Linux graphics stack.

    -   `liblustre`: Seems to be independent from the Lustre version?

        We need `/usr/lib64/liblustreapi.so.1.0.0` and `/usr/lib64/liblnetconfig.so.4.0.0` and then some
        symlinks.

    -   DSMML: This may not be needed anymore, but in that case we would need to change the configuration
        of the programming environment and not simply take that configuration from LUMI.

        -   Copy the `/usr/lib64/liblustreapi.so.1.0.0` directory and the 
            `/opt/cray/pe/lmod/modulefiles/core/cray-dsmml/0.3.1.lua` file.

        -   Create the link for the default version and also create links for shared library generic
            versions rather than copies of the file.

-   Things that we copy from the host system to reduce binding complexity, but that will require
    a rebuild after a system update:

    -   libfabric from the host system: `/opt/cray/libfabric`, `/usr/lib64/libcxi.so.1` 
        and `/opt/cray/modulefiles/libfabric`

        The `libfabric` module adds libfabric to `LD_LIBRARY_PATH` and should always be loaded
        when using MPI, so it is not needt to add the library directory to the default search
        path for library by creating a suitable configuration file in `/etc/ld.so.conf.d`.
  
    -   XPMEM: Library versions should match the kernel module which is why a rebuild may be needed.

        -   Module: Result of `module --loc --redirect show xpmem`: /opt/cray/modulefiles/xpmem/2.11.5-1.3_g73ade43320bc

        -   PKG file: Result of `pkg-config --variable=pcfiledir cray-xpmem`: `/usr/lib64/pkgconfig`, so need the file
            `/usr/lib64/pkgconfig/cray-xpmem.pc`

        -   The libraries themselves: `/usr/lib64/libxpmem.a` and `/usr/lib64/libxpmem.so.0.0.0` and create 
            symbolic links `libxpmem.so` and `libxpmem.so.0` to it.

            It looks like this library is usually linked as `libxpmem.so.0` so we could also just copy that file.,

        -   Add the directory with the xpmem libraries to the default search path by creating a suitable configuration
            file in `/etc/ld.so.conf.d`.

    -   Cray PALS: There is only one version of it on LUMI which suggests that it also depends on the OS.

        -  According to the script from Alfio:

           -   Module: From `module --loc --redirect show cray-pals`: `/opt/cray/pe/lmod/modulefiles/core/cray-pals/1.2.12.lua`
     
           -   Installation directory: From `dirname `module --redirect show cray-pals | grep PATH | awk -F'"' 'NR==1 { printf($4) }'``:
               `/opt/cray/pe/pals/1.2.12`.

           -   Add `/usr/lib64/libjansson.so.4`.

        -   But it looks like it is done differently on LUMI as there is no `cray-pals` module loaded  in the login environment and as there
            is also a cray-pals installation in `/opt/cray/pals` that appears to be newer. The libraries of that
            Cray PALS installation are also in the default system search path. So we follow this approach instead.

            -   Need `/opt/cray/pals/1.6` and possibly `/opt/cray/pals/lmod` (though the module is 
                currently not even in the search path on LUMI), and then a symbolic link `default`.

            -   And need to add a suitable configuration file in `/etc/ld.so.conf.d`.

    -   The container that the HPE CoE provided, had a more complete SUSE installation than containers we got earlier,
        but we still needed to install some development packages that our software stack builds upon for `libopenssl` 
        and `libcurl`:

        ``` bash
        zypper ref

        zypper --non-interactive --no-gpg-checks --no-refresh install --no-recommends --allow-downgrade --oldpackage libopenssl-1_1-devel
        zypper --non-interactive --no-gpg-checks --no-refresh install --no-recommends --allow-downgrade --oldpackage libcurl-devel
        ```

-   The above steps result in the following definition file (`cpe-26.03.01-SP7-LUMI-26.01.def`):

    ```
    Bootstrap: localimage

    From: cpe_26.03.01_sles15_sp7_x86_64.sif

    %files

    # User/group needed for Slurm
    /etc/group
    /etc/passwd

    # Create mount points to make building easier

    #
    # Phase 1 - Software that can persist across an OS update
    #

    # Complete the LUA installation
    /usr/lib64/lua/5.3/posix
    /usr/share/lua/5.3/posix

    # libmunge
    /usr/lib64/libmunge.so.2.0.0

    # libdrm
    /usr/lib64/libdrm.so.2.4.0
    /usr/lib64/libdrm_amdgpu.so.1.0.0
    /usr/share/libdrm

    # liblustre
    /usr/lib64/liblustreapi.so.1.0.0
    /usr/lib64/liblnetconfig.so.4.0.0

    # dsmml
    /opt/cray/pe/dsmml/0.3.1
    /opt/cray/pe/lmod/modulefiles/core/cray-dsmml/0.3.1.lua

    #
    # Phase 2 - Software that depends on other software outside the container
    #

    # libfabric and CXI provider
    /opt/cray/libfabric
    /usr/lib64/libcxi.so.1
    /opt/cray/modulefiles/libfabric

    # XPMEM
    # module --loc --redirect show xpmem
    /opt/cray/modulefiles/xpmem/2.11.5-1.3_g73ade43320bc
    # Location from pkg-config --variable=pcfiledir cray-xpmem
    /usr/lib64/pkgconfig/cray-xpmem.pc
    /usr/lib64/libxpmem.a
    /usr/lib64/libxpmem.so.0.0.0

    # Cray PALS
    /opt/cray/pals/1.6
    /opt/cray/pals/lmod
    /usr/lib64/libjansson.so.4 # Missing library in the container.

    ###################################################################################################

    %post

    #
    # Copy protection of the container
    #

    # Warning not to move the container to a different system.
    cat > /.singularity.d/env/00-license.sh << EOF
    if [ ! -f /etc/slurm/slurm.conf ] || ! /usr/bin/grep -q -e 'ClusterName=lumi\$' -e 'ClusterName=snowflake\$' /etc/slurm/slurm.conf
    then
        echo -e 'This container was prepared by the LUMI User Support Team and can only legally' \
                '\nbe used on LUMI by LUMI users with a personal active account. Using this' \
                '\ncontainer on other systems than LUMI or by other than registered active users,' \
                '\nis considered a breach of the "LUMI General Terms of Use", point 4.\n' \
                '\nBy using the container you agree to the license' \
                '\nhttps://downloads.hpe.com/pub/softlib2/software1/doc/p1796552785/v113125/eula-en.html.\n' \
                '\nIf you see this message on LUMI, then most likely your bindings are not OK.' \
                '\nPlease also bind mount /etc/slurm/slurm.conf in the container.'

        # Break off the initialisation of the container.
        exit
    fi
    EOF

    chmod a+rx /.singularity.d/env/00-license.sh

    #
    # Phase 1 - Software that can persist across an OS update
    #

    # Finish libmunge
    cd /usr/lib64
    ln -s libmunge.so.2.0.0 libmunge.so.2
    cd -

    # Finish libdrm
    cd /usr/lib64
    ln -s libdrm.so.2.4.0 libdrm.so.2
    ln -s libdrm.so.2     libdrm.so
    ln -s libdrm_amdgpu.so.1.0.0 libdrm_amdgpu.so.1
    ln -s libdrm_amdgpu.so.1     libdrm_amdgpu.so
    cd -

    # Finish liblustre
    cd /usr/lib64
    ln -s liblustreapi.so.1.0.0 liblustreapi.so.1
    ln -s liblustreapi.so.1.0.0 liblustreapi.so
    ln -s liblnetconfig.so.4.0.0 liblnetconfig.so.4
    cd -

    # Finish dsmml
    cd /opt/cray/pe/dsmml
    ln -s 0.3.1 default
    cd -
    cd  /opt/cray/pe/dsmml/0.3.1/dsmml/lib
    rm -f libdsmml.so.0 libdsmml.so
    ln -s libdsmml.so.0.0.0 libdsmml.so.0
    ln -s libdsmml.so.0.0.0 libdsmml.so
    cd -

    #
    # Phase 2 - Software that depends on other software outside the container
    #

    # Finish XPMEM
    cd /usr/lib64
    ln -s libxpmem.so.0.0.0 libxpmem.so
    ln -s libxpmem.so.0.0.0 libxpmem.so.0
    cd -
    # Make sure the libraries are in the default search path
    echo "/opt/cray/xpmem/default/lib64" >/etc/ld.so.conf.d/cray-xpmem.conf
    chmod 644 /etc/ld.so.conf.d/cray-xpmem.conf

    # Finish PALS
    cd /opt/cray/pals
    ln -s 1.6 default
    cd -
    cd /opt/cray/pals/1.6/lib
    /bin/rm -f libpals.so libpals.so.0
    ln -s liblibpals.so.0.0.0 libpals.so.0 
    ln -s liblibpals.so.0.0.0 libpals.so
    cd -
    cd /opt/cray/pals/1.6/bin
    /bin/rm -f aprun mpirun
    ln -s mpiexec aprun
    ln -s mpiexec mpirun
    cd -
    # Make sure the libraries are in the default search path
    echo "/opt/cray/pals/1.6/lib" >/etc/ld.so.conf.d/cray-pals.conf
    chmod 644 /etc/ld.so.conf.d/cray-pals.conf

    # Rebuild the cache for ld.so as we have added several conf files in /etc/ld.so.conf.d.
    /sbin/ldconfig

    #
    # Installing some packages on LUMI that are not yet in the container but that we build upon.
    #

    # Refresh caches
    zypper ref

    # Install the packages
    zypper --non-interactive --no-gpg-checks --no-refresh install --no-recommends --allow-downgrade --oldpackage libopenssl-devel
    zypper --non-interactive --no-gpg-checks --no-refresh install --no-recommends --allow-downgrade --oldpackage libcurl-devel
    zypper --non-interactive --no-gpg-checks --no-refresh install --no-recommends --allow-downgrade --oldpackage zip unzip

    #
    # Adding mount points so that future builds can even happen with advised mounts present
    #

    # Slurm mount point is needed as /etc/slurm has to be mounted if %post is used
    mkdir -p /etc/slurm

    # Mount points for the regular file system mounts are useful in case the user builds
    # upon this container with a bind module loaded

    mkdir -p /pfs
    mkdir -p /users
    mkdir -p /projappl
    mkdir -p /project
    mkdir -p /scratch
    mkdir -p /flash
    # To mount points for /appl subdirs to be able to mount an alternative software stack.
    mkdir -p /appl/local
    mkdir -p /appl/lumi

    # System mounts needed to run with full functionality
    mkdir -p /var/spool       # Or just /var/spool/slurmd?
    mkdir -p /var/run/munbe
    mkdir -p /run/cxi

    # Slurm commands
    touch /usr/bin/sacct
    touch /usr/bin/salloc
    touch /usr/bin/sattach
    touch /usr/bin/sbatch
    touch /usr/bin/sbcast
    touch /usr/bin/scontrol
    touch /usr/bin/sinfo
    touch /usr/bin/squeue
    touch /usr/bin/srun
    mkdir -p /usr/lib64/slurm
    mkdir -p /usr/include/slurm
    ```

