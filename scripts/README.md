# Scripts in this directory

-   `backup_containers.sh`: Back-up of the images for EasyBuild to LUMI-O as there
    is too much risk of accidentally erasing a container image.

    It does need a proper rclone configuration to be set first, not by using
    `lumio-conf`, but by manually adding to the rclone key file with the section
    suggested for adding a key to your local rclone configuration.    
    
-   `link_images.sh`: This script is used to create or update a directory for the EasyBuild
    SIF images next to a clone of the LUMI-EasyBuild-containers to be used for
    development work with less risk of damaging the main installation in 
    /appl/local/containers.
    
