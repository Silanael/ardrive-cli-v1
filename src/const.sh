#!/bin/bash
#
# ArDrive Docker image - const.sh
# Silanael 2021-09-19_01
#
# Constants.
#

datadir="/data"
dbdir="$datadir/db"
syncdir="$datadir/sync"
walletdir="$datadir/wallets"

dbfile=".ardrive-cli.db"
testfile=".notmounted"

binfile="/ardrive-cli/node_modules/.bin/ardrive-cli"