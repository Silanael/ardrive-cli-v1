#!/bin/bash
#
# ArDrive Docker image - run.sh
# Silanael 2021-09-14_01
#

# Settings
imagename="silanael/ardrive-cli-v1:latest"
datadir="$(pwd)/data"
function="cli"

# Container path consts
container_syncdir="/data/sync"
container_dbdir="/data/db"
container_walletdir="/data/wallets"

# Runtime
rmflag=""






# Update paths
OnDataDirSet () {

    dbdir="$datadir/db"
    walletdir="$datadir/wallets"
    syncdir="$datadir/sync"
}




# Self-explanatory
Prompt_DefaultYES () {
    read a
    if [ "${a,,}" = "n" ]
        then return 1
        else return 0
    fi
}



# Arg1: directory path
# Arg2: a descriptive name
CreateDirIfNeeded () {

    dir="$1"
    name="$2"

    if [ ! -d "$dir" ]
    then 
        echo "$name $dir does not exist - create it? [Y/n]"

        if Prompt_DefaultYES
        then
            if ! mkdir -p "$dir"
            then
               echo "ERROR CREATING $dir !"
               echo "Aborting."
               exit 1
            fi
        fi

    fi


}



# Ensure that the required directories exist
CheckPaths () {

    CreateDirIfNeeded "$dbdir" "Database directory"
    CreateDirIfNeeded "$syncdir" "Sync directory"
    CreateDirIfNeeded "$walletdir" "Wallet directory"
}




# Command-line stuff
ParseArgs () {


    # No arguments given
    if [ "$1" == "" ]
    then
        echo "Use \"./run.sh --help\" for usage info."
        echo ""
	
    # Run through all the args
    else
        while [[ $# -gt 0 ]]
        do

            cmd="${1,,}"
            val="$2"

	    case $cmd in

               -d|--datadir)
                  datadir="$val"
                  OnDataDirSet
                  shift; shift
                  ;;

	       -w|--walletdir)
                  walletdir="$val"
	          shift; shift
                  ;;

               -b|--dbdir)
                  dbdir="$val"
                  shift; shift
                  ;;

               -s|--syncdir)
                  syncdir="$val"
                  shift; shift
                  ;;

               -c|--reset)
                  function="resetdb"
                  shift
                  ;; 

               -q|--nochecks)
                  function="nochecks"
                  shift
                  ;; 

               -r|--rm)
                  rmflag="--rm "
                  shift
                  ;; 

               -e|--shell)
                  function="shell"
                  shift
                  ;; 

               -i|--info)
                  function="info"
                  shift
                  ;; 

               *)
                  echo "Usage: ./run.sh [OPTION]"
                  echo ""
                  echo "  -d, --datadir   DIR    Override the base data directory.         (default is ./data)"
                  echo "  -w, --walletdir DIR    Override the wallet directory.            (default is ./data/wallets)"
                  echo "  -s, --syncdir   DIR    Override the sync data directory.         (default is ./data/sync)"
                  echo "  -b, --dbdir     DIR    Override the database directory.          (default is ./data/db)"
                  echo "  -q, --nochecks         Run ardrive-cli directly without safety checks / scripts"
                  echo "  -c, --reset            Delete the database for a fresh start."
                  echo "  -r, --rm               Run the container with --rm so it gets removed after exiting."
                  echo "  -e, --shell            Run a shell inside the container."
                  echo "  -i, --info             Display the container's internal documentation."
	          echo ""
                  echo "If you have an Arweave-wallet, place it into the walletdir (./data/wallets by default)."
                  echo ""
                  echo "The container can be started with \"./run.sh\""
                  echo "or with the command \"docker run -it -v \$(pwd)/data:/data $imagename\"."
                  echo ""
                  echo "It might be necessary to run the container as root (when using Docker)."
                  echo ""
	          #function="help"
                  exit
	          shift
                  ;;

            esac

        done

    fi

}







##################
### EXEC START ###
##################


OnDataDirSet
ParseArgs "$@"
CheckPaths


# Ensure the user knows what directory bindings are used
echo "SYNC DIRECTORY    Container: $container_syncdir		Local: $syncdir"
echo "WALLET DIRECTORY  Container: $container_walletdir	Local: $walletdir"
echo "DB DIRECTORY      Container: $container_dbdir		Local: $dbdir"
echo ""


# Run the container
echo "Running the container ($imagename)..."
echo ""
docker run ${rmflag}-it -v "$dbdir":"$container_dbdir" -v "$walletdir":"$container_walletdir" -v "$syncdir":"$container_syncdir" $imagename $function

