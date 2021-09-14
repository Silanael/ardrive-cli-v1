#!/bin/bash
#
# ArDrive CLI Docker image - validate.sh
# Silanael 2021-09-13_01
#
# See that we're good to go mount-wise,
# create the directory structure if need be
# and warn the user of the risk of wallet loss.
#

source /const.sh
source /func.sh


# arg1:    list - lists the wallets found
# returns: number of wallets found
# 
GetWalletsAmount () {

    arg="${1,,}"

    if [ -d "$walletdir" ]
    then 

         wallets=$(find "$walletdir" -name "*.json")

         # Wallets found
         if [ "$wallets" ]
         then 
             if [ "$arg" = "list" ]
             then
                 echo "WALLETS FOUND:"
                 echo "$wallets"
                 echo ""
             fi
             return $(echo "$wallets" | wc -l)

         # No wallets present in walletdir
         else
             return 0

         fi


    # Wallet dir doesn't exist for some reason
    else
         return 0

    fi     
}


AreWalletsPresent () {

    GetWalletsAmount
    if [ $? -gt 0 ]
        then return 0;
        else return 1;
    fi
}




CreateDirStructure () {

    # Check if DB- or syncdir are absent, indicating that /data was mounted
    # to an empty directory.
    if [ ! -d "$dbdir" ] || [ ! -d "$syncdir" ] || [ ! -d "$walletdir" ]
    then

	echo  "/data seems to be mounted properly, yet it lacks the directory structure."
        echo  "Create the missing directories? [Y/n]"

        if Prompt_DefaultYES
        then

            echo ""

            if [ ! -d "$dbdir" ]
            then
                 if mkdir "$dbdir"; then echo "CREATED $dbdir"; else echo "FAILED TO CREATE $dbdir !"; exit 1; fi
	    fi

            if [ ! -d "$syncdir" ]
            then
                 if mkdir "$syncdir"; then echo "CREATED $syncdir"; else echo "FAILED TO CREATE $syncdir !"; exit 1; fi
	    fi

            if [ ! -d "$walletdir" ]
            then
                 if mkdir "$walletdir"; then echo "CREATED $walletdir"; else echo "FAILED TO CREATE $walletdir !"; exit 1; fi
	    fi

        fi

        echo ""

    fi


}



CheckMounts () {

    GetWalletsAmount

    wallets_amount="$?"
    mounts_ok=true

    # Database directory
    if   [ ! -d "$dbdir" ];           then dbmounted="NOT PRESENT"; mounts_ok=false
    elif ! IsDBMounted;               then dbmounted="NOT MOUNTED"; mounts_ok=false
    elif [ -f "$dbdir/$dbfile"   ];   then dbmounted="OK - DATABASE PRESENT"
    else                                   dbmounted="OK" # <X>
    fi

    # Sync directory
    if   [ ! -d "$syncdir" ];         then syncmounted="NOT PRESENT"; mounts_ok=false
    elif ! IsSyncMounted;             then syncmounted="NOT MOUNTED"; mounts_ok=false
    else                                   syncmounted="OK"
    fi

    # Wallet directory - optional, but recommended.
    if   [ ! -d "$walletdir" ];       then walletsmounted="NOT PRESENT" 
    elif ! IsWalletsMounted;          then walletsmounted="NOT MOUNTED"
    elif AreWalletsPresent;           then walletsmounted="OK - $wallets_amount WALLETFILE(S)"
    else                                   walletsmounted="OK - NO WALLET-FILES"
    fi

    # Display status
    echo "$syncdir:	$syncmounted"
    echo "$dbdir:	$dbmounted"
    echo "$walletdir:	$walletsmounted" 
    echo ""
    GetWalletsAmount list

    if [ "$mounts_ok" = false ]
        then return 1
    fi
    
    return 0  
}


CheckWallets () {

    # This is the first run, but there are no wallet files.
    if IsFirstRun && ! AreWalletsPresent
    then
        echo "No Arweave-wallets found in the $walletdir -directory."
        echo "ardrive-cli needs an Arweave-wallet to interact with the permaweb."
        echo  ""
        echo "The CLI can be used to create a wallet, but the recommended safest approach"
        echo "is creating it with some external tool such as the official browser extension."
        echo ""
        echo "If you do this, place your wallet file to the data/wallets directory on the host"
        echo "and run the container again. The wallet file only needs to be there"
        echo "during the first run, after which it'll be stored in a database (at /data/db)."        
        echo ""

        if ! IsWalletsMounted
        then
            echo "$walletdir doesn't seem to be mounted, so I'm not going to risk that"
            echo "you create a wallet and lose it. If you want to test/play around,"
            echo "start the container with the command 'nochecks'."
            return 1
        fi

        echo "Launch the CLI anyways? [y/N]"

        if ! Prompt_DefaultNO
            then exit 1
        fi
        
        # Warn the user for one last time.
        WalletLossWarning

        CriticalMSG "Are you ABSOLUTELY SURE you want to proceed? [y/N]"

        if ! Prompt_DefaultNO
            then exit 1
        fi

        echo ""
        echo "Alright then. If you DO create a wallet, Make sure to enter $walletdir"
        echo "as Wallet Backup Path when asked (or another volume/bindmount you're using)."
        echo ""


    # This is not the first run, yet wallet files are still present in the system.
    elif ! IsFirstRun && AreWalletsPresent
    then

         CriticalMSG "WARNING: Wallet files should not be stored in $walletdir after ardrive-cli has been set up."
         CriticalMSG "They are NOT encrypted, keep them somewhere safe!"
         echo ""        

    fi

}







##############
# EXEC BEGIN #
##############


# Create directory structure if an empty /data was mounted.
CreateDirStructure


# Verify that all mounts are present + display info
if ! CheckMounts
then

    # Mounts not good - display usage information
    cat /mount_info.txt
    exit 1
fi


# Check if any wallets are present for the first run
if ! CheckWallets
then
    exit 1
fi


# Provide directory info for initializing ardrive-cli
if IsFirstRun
then
    echo "PROVIDE THE FOLLOWING PATHS WHEN ASKED:"
    echo ""
    echo "    Wallet Path:                          $walletdir/existing_wallet.json"
    echo "    ArDrive Wallet Backup Folder Path:    $walletdir (upon wallet creation)"
    echo "    ArDrive Sync Folder Path:             $syncdir"
    echo ""
fi


# All checks green, tell the caller that we're good to proceed.
exit 0
