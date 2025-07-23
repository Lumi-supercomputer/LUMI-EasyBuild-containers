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
