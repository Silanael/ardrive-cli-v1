# ardrive-cli-v1 dockerfile (2021-09-14_01)
Dockerfile and support scripts by Silanael, ardrive-cli by the ArDrive team


## Important notice and disclaimer
This Dockerfile has mostly been created for the sake of historic preservation at the advent of more capable and (hopefully) bug-free v2 CLI.
Though it is fully functional, **production use is not recommended**. Using it to store files comes with some risks, so, carefully read this document through before proceeding. ardrive-cli may be buggy and result in monetary loss, nor can I guarantee my work to be free of bugs either. I take no responsibility for damages caused by the use of this image or any of the files associated with it - **use at your own risk**


## What is this thing?
This is a Dockerfile that fetches and builds ardrive-cli v1 with some scripts I wrote that provide some safety checks and ease of use.


## What is ardrive-cli?
'ardrive-cli' is a command-line utility to interact with ArDrive, a permaweb file storage service/protocol working on top of Arweave. It lets users to create ArDrive-drives and sync their content with the local filesystem, working for both file upload and download. An Arweave-wallet with sufficient funds ("AR") is required to upload files. The cli can be used to create the wallet, yet the recommended way is to create it with an external tool, such as [the official Arweave Chrome-extension](https://chrome.google.com/webstore/detail/arweave/iplppiggblloelhoglpmkmbinggcaaoc). 


## What is ArDrive?
ArDrive is a permaweb file storage service that provides a filesystem layer (ArFS) on top of Arweave, allowing easy upload and management of files.
Upon file uploads, an additional fee (a tip) is charged in addition to the Arweave network transaction fees. 
See [ardrive.io](https://www.ardrive.io) for more information.


## What is Arweave?
Arweave is a blockchain(blockweave)-based immutable data storage system with the goal of preserving information in very long term, countering censorship and other forms of data loss. In contrast to other cryptocurrency-based file storage systems, it stores the data in the actual blockweave. Storing data requires spending Arweave's native cryptocurrency, "AR", which is distributed to the miners in a way that incentivises preserving the data in the long run.
See [arweave.org](https://www.arweave.org) for more information.


# Requirements
- Docker or a compatible container runtime


# How this container works
The container uses the following mount locations:
- /data/db        where .ardrive-cli.db is created at (holds wallet and state)
- /data/sync      to act as a sync directory for uploads and downloads.
- /data/wallets   to allow the CLI to access and save wallet files

It is sufficient to mount an empty directory to /data - the missing directories will be created upon container start.

## First run
To initialize arweave-cli, you will need to provide the following things:
### An Arweave-wallet - do one of the following
- Provide an existing one by placing it into your local workdir/data/wallets -directory and providing `/data/wallets/yourwallet.json` when asked for **Wallet Path**.
- Create one with a CLI and provide `/data/wallets` when asked for **ArDrive Wallet Backup Folder Path** 

**WARNING! If the CLI is used to create a wallet, EXTREME CARE must be taken to save it to mounted persistent storage - saving it into the container filesystem instead of a volume or a bind-mount may lead to LOSING THE WALLET FILE once the container stops, resulting in loss of control of the newly-created Arweave-address along with ALL FUNDS IN IT!**
> A safer alternative is to create a wallet externally (see 'What is arweave-cli').

### A sync directory
- Provide `/data/sync` when asked for **ArDrive Sync Folder Path**

### Create a drive if you haven't got one already
- Public drives are **forever accessible to everyone**
- Private drives are encrypted, the key derived from your wallet address combined with the username and password. Refer to ArDrive-documentation for further info.

### When ardrive-cli has been initialized
- You can now start adding files to your newly-created drive by placing them into the host sync folder (`workdir/data/sync` by default).
- ardrive-cli will run in a loop, eventually picking up the new files and asking you for a confirmation for upload, along with displaying the upload cost.

### After the first run
After ardrive-cli has been initialized, the wallet file should be moved away as it is then saved to the internal database (located in /data/db) in encrypted form. **Wallet .json -files are NOT encrypted** so they should be kept safe.

/data/db and /data/sync should always be mounted on permanent storage in order to upload files, and have the state of the container persist.

Run `docker run -it --rm silanael/ardrive-cli-v1 help` or `./run.sh --help` for more information.


## Known issues
- The v1 CLI doesn't use bundled transactions, so during times of network congestion, it is possible to have one of the transactions (data or metadata) to go through while the other one gets dropped. This leads into orphaned data and metadata, wasting money (AR) for broken uploads. This is the primary reason I don't recommend the v1-client for any serious use.
- The last I checked, ardrive-cli would accept files larger than 2GB, yet throw an exception and post only metadata transaction.
- The CLI throws an exception when given a wallet path that doesn't exist, yet doesn't exit properly.

## How to run
NOTE: In order to run as a non-root user, Docker-privileges may be needed to be set up.

### With the included scripts

#### Build
- `./build.sh`
##### If you have a wallet .json
- `cp wallet.json data/wallets/`
#### Run
- `./run.sh`
#### Run with custom directories and features
See `./run.sh --help` for information

### With Docker

#### Build
- `docker build -t silanael/ardrive-cli-v1:latest .`
#### Prepare
- `mkdir data`
#### If you have a wallet file
- `mkdir data/wallets`
- `cp wallet.json data/wallets/`
#### Run
- `docker run -it -v $(pwd)/data:/data silanael/ardrive-cli-v1:latest`
#### Info on additional features
- `docker run -it --rm silanael/ardrive-cli-v1:latest help`
#### Command structure
- `docker run -it [--rm] -v [DATADIR]:/data <image> [FUNCTION]`
- `docker run -it [--rm] -v [DBDIR]:/data/db -v [SYNCDIR]:/data/sync -v [WALLETDIR]:/data/wallets <image>`
- `docker run -it [--rm] -v <image> [help/info]`
- `docker run -it [--rm] -v [DATADIR]:/data <image> [cli/nocheck/shell/resetdb]`

### Post-run
- It is recommended to move your wallet.json -files away from data/wallets. Store them in a safe location where they won't be lost or compromised.
