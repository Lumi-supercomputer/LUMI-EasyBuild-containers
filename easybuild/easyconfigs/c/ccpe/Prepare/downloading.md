# Downloading the containers

The only way to get access to the containers is to download the containers
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
