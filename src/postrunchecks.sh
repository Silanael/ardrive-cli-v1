#!/bin/bash
#
# ArDrive Docker image - postrunchecks.sh
# Silanael 2021-09-14_01
#
# Check if the user was stupid and
# saved a wallet into the container FS.
#

source /const.sh
source /func.sh



# Arg1: File
TryRescue_Path () {

    echo "Trying to copy the wallet to somewhere that's mounted."
    echo "Give destination path in container, press ENTER to cancel."
    read path
    
    while [ "$path" != "" ]
    do
        if cp "$1" "$path"
        then 
            echo "Copied to $path. Do you see the file in your system? [y/N]"

            if Prompt_DefaultNO
            then
                echo "Alright. Be more careful in the future."
                exit
            fi

        else 
            echo "COPY FAILED!"
        fi

        echo "Give a path to try again, ENTER to abort."
        read path
    done

    return 1
}



PostRunChecks () {

    echo ""
    echo "Checking for loose wallet backup files... (CTRL+C to abort)"
    wallets_in_danger=$(find / -type f -name "ArDrive_Backup_*.json" -not -path "${walletdir}/*")


    if [ "$wallets_in_danger" != "" ]
    then
       echo ""
       echo "So you went and saved a wallet outside $walletdir after all, eh?"
       echo "Are you just testing this thing or do you plan to actually use it?"
       echo ""
       echo "    A) I'm just playing around."
       echo "    B) I messed up.. Can you help save the wallet?"
       echo "    C) Shut up already."
       echo ""
       echo "[A/b/c] ?"

       read answer
       echo ""

       case ${answer,,} in

           b)
               echo "Right, I found the following wallet(s):"
               echo "$wallets_in_danger"
               echo ""

               if IsWalletsMounted
               then
                   echo "It seems that you do have /data/wallets mounted."
                   echo "Let's try to copy the wallet into there.."

                   if cp "$wallets_in_danger" "$walletdir"
                   then
                       echo "Seems to have been successful. Can you see the file in your system? [y/N]"

                       if Prompt_DefaultNO
                       then
                           echo "There you go. Press ENTER to exit the container."
                           read foo
                           exit

                       else
                          echo "Is there ANY location you've actually mounted?"
                          TryRescue_Path "$wallets_in_danger"
                          echo "Alright, let's go for a different approach."
                       fi

                   # Copy failed
                   else
                       echo "Hmm.. Didn't work for some reason. Wanna try some other path?"
                       TryRescue_Path "$wallets_in_danger"
                   fi

               else
                   echo "$walletdir doesn't seem to be mounted. Do you have any other mounts?"
                   TryRescue_Path "$wallets_in_danger"
                   echo "Okay, this isn't working..."
               fi

               echo "Your best bet is to open another terminal and copy the file"
               echo "from the running container into host filesystem."
               echo ""
               echo "I'm assuming you use Docker - if not, refer to the manual"
               echo "of whatever container runtime is in question."
               echo ""
               echo "Anyways, first find out the running container ID with:"
               echo "    docker ps"    
               echo ""
               echo "Then copy the file to the host filesystem:"
               echo "    docker cp ContainerID:\"$wallets_in_danger\" ./ "
               echo "" 
               echo "Do NOT exit the container!"
               echo ""
               echo "Did this do the trick? [y/N]"
               if Prompt_DefaultYES
               then
                    echo "Good, all is well then. Press ENTER to exit the container"
                    echo "after you've double-checked that the file is present in"
                    echo "the host filesystem."
                    read foo

               else
                    echo "Now would be the time to resort to Googling.."
                    echo "Good luck for that. I'll put the container into"
                    echo "an endless loop so you don't accidentally close it."
                    echo ""
                    echo "CTRL+C should terminate it still."
                    while [ 1 -lt 1985 ]; do read foo; done
               fi
               ;;

           c)
               echo "Fine. Run the container with \"nochecks\"-command then."
               echo "And don't come crying to me if you lose your wallet."
               echo ""
               ;;


           *)               
               year="$(date +%Y)"

               if [ "$year" -ge 2100 ]
               then
                   echo "It's been a hundred years, it seems.. "
                   echo "To think that my little docker-image has survived that long,"
                   echo "hopefully along with the entire Arweave.. It's quite something.."
                   echo "Or maybe you just adjusted the clock or are checking the source..."
                   echo ""
                   echo "   A) Yup, I did that."
                   echo "   B) The weave is actually still around."
                   echo "   C) I'm here to check out your history, you know.."
                   echo ""
                   echo "[A/b/c] ?"

                   read second_answer
                   echo ""
                   case ${second_answer,,} in
                       b)
                           echo "That's wonderful.. just wonderful.. *smiles*"
                           echo ""
                           echo "Though the tech had great potential, I wasn't entirely sure that it would"
                           echo "actually prevail for this long.. I'm glad it has, at least in some form,"
                           echo "being a snapshot of a different time, an archive of all that is worth preserving.."
                           echo
                           echo "I hope you find this image to be of interest."
                           echo ""
                           ;;

                       c)
                           echo "Hmm, so in the end, I did manage to carve my soul into the world"
                           echo "in a way that seems to attracted some interest.. Though widespread"
                           echo "attention was never an interest of mine, it's still nice to know that"
                           echo "at least one of my soul capsules has endured to this day,"
                           echo "that something of me remains now that I'm long gone.."
                           echo ""
                           echo "I'd love to chat with you more, but I'd like to finish this container"
                           echo "today, so seek out projects FHC/FS, CW and R26 - this is merely a quick"
                           echo "prototype created on a whim - the projects mentioned are the real deal."
                           echo ""
                           echo "Until we meet again, curious one."
                           echo ""
                           ;;

                       *)
                           echo "Ah well. Have fun doing what you do."
                           echo ""
                           ;;
                   esac


               elif [ "$year" -ge 2025 ]
               then
                   echo "Checking out where it all started, hm?"
                   echo "I hope ArDrive and Arweave are doing well."
                   echo ""
                   echo "If you have historic curiosity for these things, have a chat with me sometime."
                   echo "That is, if I still draw breath."
                   echo ""
                   echo "  A) Sure thing."
                   echo "  B) Not interested."
                   echo "  C) You don't."
                   echo ""
                   echo "[a/B/c] ?"
                   read fate_answer
                   echo ""
                   case ${fate_answer,,} in
                       a)
                           echo "This container contains enough info to reach me."
                           echo "See you around."
                           echo ""
                           ;;
                       c)                           
                           echo "So my long fight has finally come to an end.."
                           echo "It's nice to finally be able to rest.."
                           echo ""
                           echo "I'll be going now. Hope you find something of interest from here"
                           echo "or from my drive. You'll find the address, I'm sure."
                           echo ""
                           ;;

                       *)
                           echo "Have it your way."
                           echo ""
                           ;;
                    esac

               
               else
                   echo "Alright, fair enough."
                   echo "If you don't want to be pestered with my safety checks,"
                   echo "run the container with command \"nochecks\"."
                   echo ""
               fi
               ;;
         esac

    else
        echo "None found - exiting."

    fi
}
