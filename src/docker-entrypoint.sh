#!/bin/bash
#
# ArDrive Docker image - docker-entrypoint.sh
# Silanael 2021-09-19_01
#
# The execution of the container starts here.
# Various parameters can be supplied as the run command.
#

source /const.sh
source /func.sh
source /postrunchecks.sh

arg="$1"


# Greet
echo "ArDrive CLI docker image"
echo "Silanael 2021-09-19_01"
echo ""
echo "Run \"docker -it --rm <image> help\" for info."
echo ""


# Parse arguments
case $arg in

    resetdb)

        ResetDB

        echo "Launch the CLI? [y/N]"

        if ! Prompt_DefaultNO
        then
            exit 0
        fi

        # Fallthrough intentional
        ;&


    cli)

        # See that all important mounts are present, exit otherwise
        if ! /validate.sh
        then
            exit 1
        fi
        
        # In func.sh
        LaunchCLI

        # Safety checks to see if the user did something stupid
        # like saving a wallet into the wrong location.
        PostRunChecks

	;;



    nochecks|leet)

        LaunchCLI
	;;



    shell)
        /bin/bash
        ;;



    info)
        cat /info.txt
        ;;


    
    *)
        cat /image-usage.txt
        ;;

esac
