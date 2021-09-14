#!/bin/sh
#
# ArDrive Docker image - build.sh
# Silanael 2021-09-14_02
#

imagename="ardrive-cli-v1:latest"


echo "Building $imagename..."
echo ""

if docker build -t $imagename .
then

    echo ""
    echo "*******************"
    echo "* BUILD COMPLETED *"
    echo "*******************"
    echo ""

    echo "Pruning images to remove the builder-image:"
    echo ""
    docker image prune
    echo ""

    ./run.sh --help

else

    echo "!!! BUILD FAILED !!!"
    echo 

fi
