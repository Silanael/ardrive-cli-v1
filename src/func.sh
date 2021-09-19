#!/bin/bash
#
# ArDrive Docker image - func.sh
# Silanael 2021-09-19_01
#
# Some helper-functions.
#

source /const.sh



LaunchCLI () {

    echo "Launching ardrive-cli... (CTRL+C to exit)"
    echo ""

    # Try to run the binary,
    # fallback to yarn start otherwise.
    if [ "$binfile" == "" ] || ! $binfile
    then             
        cd /ardrive-cli
        yarn start
    fi    
}


ResetDB () {
 
    filetoremove="$dbdir/$dbfile"

    if [ -f "$filetoremove" ]
    then

        CriticalMSG "Confirm deletion of $filetoremove [y/N]"
        
        if Prompt_DefaultNO
        then
            if rm "$filetoremove"
            then
                echo "The database has been deleted."
            else
                echo "FAILED TO DELETE DATABASE FILE"
            fi

        else
            echo "Aborted."
            exit 1

        fi

    else
       echo "The database file ($filetoremove) doesn't seem to exist."    

    fi

    echo ""
}


IsFirstRun () {
    if [ ! -f "$dbdir/$dbfile" ]
        then return 0
        else return 1
    fi
}


IsDBMounted () {
    if [ -d "$dbdir" ] && [ ! -f "$dbdir/$testfile" ]
        then return 0
        else return 1
    fi
}


IsSyncMounted () {
    if [ -d "$syncdir" ] && [ ! -f "$syncdir/$testfile" ]
        then return 0
        else return 1
    fi
}


IsWalletsMounted () {
    if [ -d "$walletdir" ] && [ ! -f "$walletdir/$testfile" ]
        then return 0
        else return 1
    fi
}


Prompt_DefaultYES () {

    read a

    if [ "$a" = "n" ] || [ "$a" == "N" ]
        then return 1
        else return 0
    fi
}


Prompt_DefaultNO () {

    read a

    if [ "$a" = "y" ] || [ "$a" == "Y" ]
        then return 0
        else return 1
    fi
}


DisplayWarning () {

    echo ""
    echo -e "\033[40;31;6;1m ############### \033[0m"
    echo -e "\033[40;31;6;1m !!! WARNING !!! \033[0m"
    echo -e "\033[40;31;6;1m ############### \033[0m"
    echo ""
}


WalletLossWarning () {

    echo ""
    echo -e "\033[40;31;1;6m ############################\033[25m !!! WARNING !!! \033[6m############################\033[0m"
    echo -e "\033[40;31;1;6m #\033[25m                                                                       \033[6m#\033[0m"
    echo -e "\033[40;31;1;6m #\033[25m  If the CLI is used to create a wallet, EXTREME CARE should be taken  \033[6m#\033[0m"
    echo -e "\033[40;31;1;6m #\033[25m  to save it into a MOUNTED, PERSISTENT LOCATION - failure to do this  \033[6m#\033[0m"
    echo -e "\033[40;31;1;6m #\033[25m  may result in LOSS OF CONTROL OVER THE ARWEAVE-ADDRESS as well as    \033[6m#\033[0m"
    echo -e "\033[40;31;1;6m #\033[25m  LOSS OF ALL THE CURRENCY IT CONTAINS!                                \033[6m#\033[0m"
    echo -e "\033[40;31;1;6m #\033[25m                                                                       \033[6m#\033[0m"
    echo -e "\033[40;31;1;6m #########################################################################\033[0m"
    echo ""
}


# Arg1: Message to be displayed
CriticalMSG () {
    
    echo -e "\033[40;31;1m$1\033[0m"

}
