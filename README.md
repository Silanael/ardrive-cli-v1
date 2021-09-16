# ArDrive CLI v1 Dockerfile
- Dockerfile, shell scripts and documentation by [Silanael](http://www.silanael.com)
- [ardrive-cli](https://github.com/ardriveapp/ardrive-cli) by the [ArDrive team](https://ardrive.io)


## Pre-built images at
- [DockerHub](https://hub.docker.com/repository/docker/silanael/ardrive-cli-v1) (x86-64, ARMv7 / RPI2)
- [ArDrive](https://app.ardrive.io/#/drives/a44482fd-592e-45fa-a08a-e526c31b87f1?name=Silanael) - [x86-64](https://app.ardrive.io/#/file/24d2bc79-60e2-42e8-aaec-c74d2d4b4813/view) [ARMv7](https://app.ardrive.io/#/file/d59e8f78-f589-4be5-b5dc-984420b8bc27/view)
- [Arweave - x86-64](https://arweave.net/J3DuBTV9GtTIeWSz28oJoaHt33LTgCCMQ1pBpyNYyso) (tar.gz, TXID: J3DuBTV9GtTIeWSz28oJoaHt33LTgCCMQ1pBpyNYyso)
- [Arweave - ARMv7](https://arweave.net/aOrafXYWf1DBZ-Quf_NzHJlvN4yTStSykkvlvOXC7nw) (tar.gz, TXID: aOrafXYWf1DBZ-Quf_NzHJlvN4yTStSykkvlvOXC7nw)

## An important notice and disclaimer
This Dockerfile has mostly been created for the sake of historic preservation at the advent of more capable and (hopefully) bug-free **v2 CLI**.
Though it is fully functional, **production use is not recommended**. Using it to store files comes with some risks, so, carefully read through this document before proceeding. ardrive-cli may be buggy and result in monetary loss, nor can I guarantee my work to be free of bugs either. I take no responsibility for damages caused by the use of this image or any of the files associated with it - **use at your own risk**


## What is this thing?
This is a **Dockerfile** that fetches and builds **ardrive-cli v1** with some scripts I wrote for safety checks and ease of use.


## What is ardrive-cli?
**ardrive-cli** is a command-line utility to interact with **ArDrive**, a permaweb file storage service/protocol working on top of **Arweave**. It allows the user to create **ArDrive-drives** and sync their content with the local filesystem, working for both file upload and download. An **Arweave-wallet** with sufficient funds ("**AR**") is required to upload files. **arweave-cli** can be used to create the wallet, yet the recommended way is to create it with an external tool such as the [Chrome-extension](https://chrome.google.com/webstore/detail/arweave/iplppiggblloelhoglpmkmbinggcaaoc) - creating it inside the container may lead into loss of the wallet and the funds associated with it. **WARNING: UPLOADED FILES CANNOT BE DELETED FROM THE PERMAWEB!**


## What is ArDrive?
**ArDrive** is a permaweb file storage service that provides a filesystem layer (**ArFS**) on top of **Arweave**, allowing easy upload and management of files.
Upon uploading a file, a small fee (a tip) is charged in addition to the Arweave network transaction fees. Aside the CLI, the files can be managed with a [web interface](https://github.com/ardriveapp/ardrive-web) at [app.ardrive.io](https://app.ardrive.io). A [desktop client](https://github.com/ardriveapp/ardrive-desktop) exists as well.
See [ardrive.io](https://www.ardrive.io) for more information.


## What is Arweave?
**Arweave** is an immutable data storage system with the goal of long-term data preservation in a way that counters censorship and data loss that is the result of centralization. It does this by storing data inside the blocks of the **blockweave** (Arweave's equivalent of a blockchain) as opposed to storing it separately, this property allowing it to preserve the data for as long as miners and archivists remain incentivized to do so.

Storing data requires spending Arweave's native cryptocurrency, "**AR**", some of which is distributed to the miners over time as a form of accumulating interest.
See [arweave.org](https://www.arweave.org) for more information.



## Requirements
- Docker or a compatible container runtime



## Known issues
- The **v1 CLI** doesn't use bundled transactions, so during times of network congestion, it is possible to have one of the transactions (data or metadata) to go through while the other one gets dropped. This may leads into **orphaned data and metadata**, and **possibly even monetary loss** (AR). This is the primary reason I don't recommend the **v1 cli** for any serious use. If this happens, consult the [ArDrive team](https://ardrive.io).
- The last I checked, **ardrive-cli** would accept files larger than 2GB, yet throw an exception and post only metadata transaction.
- **ardrive-cli** throws an exception when given a wallet path that doesn't exist, yet doesn't exit properly.



## How this container works
The container uses the following mount locations:
- `/data/db`        where .ardrive-cli.db is created at, containing wallet and state data.
- `/data/sync`      to act as a sync directory for uploads and downloads.
- `/data/wallets`   to allow the CLI to read and save wallet files.

It is sufficient to mount an empty directory to `/data` - the directory structure will be created upon container start.

## First run
To initialize **arweave-cli**, you will need to provide the following things:

## A Login Name and an ArDrive Login Password
At the time of writing this, **ArDrive** does not have user accounts - the **Login Name** provided is used to
find your drives and for creating a drive encryption key for private drives in conjuction with the wallet private key and **ArDrive Login Password*.
**ardrive-cli** also uses the login info for local profile management.
- Use your existing **Login Name** and **ArDrive Login Password** if possible.
- Make sure to remember the login info - **ARDRIVE CANNOT RECOVER OR CHANGE YOUR PASSWORD!**
- The password will be queried after a wallet has been created/provided.

### An Arweave-wallet - do one of the following
- Use an existing wallet by placing the **wallet file** into your local `<workdir>/data/wallets` directory and providing `/data/wallets/<walletfile.json>` when asked for **Wallet Path** (ie. `/data/wallets/mywallet.json`)
- Create a wallet with **ardrive-cli** and provide `/data/wallets` when asked for **ArDrive Wallet Backup Folder Path** 

**WARNING! If the CLI is used to create a wallet, EXTREME CARE must be taken to save it to mounted persistent storage - saving it into the container filesystem instead of a volume or a bind-mount may lead to LOSING THE WALLET FILE once the container stops, resulting in loss of control of the newly-created Arweave-address along with ALL FUNDS IN IT!**
- A safer alternative is to create a wallet with an external tool (see **What is arweave-cli**).

### A sync directory
- Provide `/data/sync` when asked for **ArDrive Sync Folder Path**

### Create a drive if you haven't got one already
- Public drives are **forever accessible to everyone**
- Private drives are encrypted with a key derived from your **wallet**, **Login Name* and **ArDrive Login Password**.
  See [ArDrive's wiki](https://ardrive.atlassian.net/wiki/spaces/help/overview) for technical details.

### When ardrive-cli has been initialized
- You can now start adding files to your newly-created drive by placing them into the host sync folder (`<workdir>/data/sync` by default).
  **Consider VERY carefully what to upload - IT IS NOT POSSIBLE TO DELETE FILES FROM THE PERMAWEB!**
- **ardrive-cli** will run in a loop, eventually picking up the new files and asking you for a confirmation for upload along with displaying an upload cost.

### After the first run
After **ardrive-cli** has been initialized, the **wallet file** (.json) should be moved away as it is then saved to the internal database (located in `/data/db/.ardrive-cli.db`) in encrypted form. **Wallet files are NOT encrypted** so they should be kept safe.

`/data/db` and `/data/sync` should always be mounted on permanent storage in order to upload files and have the state of the container persist.

Run `docker run -it --rm silanael/ardrive-cli-v1 help` or `./run.sh --help` for more information.



## How to run
NOTE: In order to run as a non-root user, **Docker-privileges** may be needed to be set up.

### With the included scripts

#### Build
- `./build.sh`

#### If you have a wallet file
- `mkdir -p data/wallets`
- `cp <wallet.json> data/wallets/`
 
#### Run
- `./run.sh`
 
#### Run with custom directories and features
See `./run.sh --help` for information.



### With Docker

#### Build
- `docker build -t silanael/ardrive-cli-v1:latest .`
 
#### Prepare
- `mkdir data`
 
#### If you have a wallet file
- `mkdir data/wallets`
- `cp <wallet.json> data/wallets/`
 
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
- It is recommended to move your **wallet files** away from `data/wallets`. **Store them in a safe location where they won't be lost or compromised**.



## Wallet emergency recovery procedure
If one, against all my warnings, went and created the wallet in the container filesystem, there are a few ways to salvage the situation.
These instructions are for **Docker** - if another container runtime is used, refer to its documentation for extracting files from a container.
The commands may require a **sudo**-prefix (ie. `sudo docker ps`) or being ran as root. **If in doubt, seek aid from someone who knows what they're doing**

### If the container is running
1) Open another terminal / command-prompt
2) Find the **CONTAINER ID** of the **ardrive-cli-v1 container**: `docker ps`

### If the container is stopped
Find the **CONTAINER ID** of the stopped **ardrive-cli-v1 container**: `docker ps -a`
- Note that this only works if the container was NOT ran with the "--rm" -flag.

### Copy the wallet.file from the container to the local filesystem
Run `docker cp ID:PATH/ArDrive_Backup_NAME.json .` with the following substitutions:
- Substitute **ID** with the **CONTAINER ID** obtained in previous step
- Substitute **PATH** with what you used as **Ardrive Wallet Backup Folder Path** (if you used **current path** / pressed ENTER,
   substitute **PATH** with `/ardrive-cli`)
- Substitute **NAME** with the **Login Name** you used.
An example command:
- `docker cp be3f7474a1d3:/ardrive-cli/ArDrive_Backup_Silanael.json .`
A successful copy operation gives no message.
Verify that the **wallet file** (.json) is present in your **local filesystem**.

### To locate the wallet file in the container
- `sudo docker exec ID find / -type f -name "ArDrive_Backup_*.json"`

### If all this fails
It might be possible to extract the wallet data from the **.ardrive-cli.db** database file (contact [ArDrive team](https://ardrive.io)).
If no database file can be recovered, the odds are that the wallet is lost for good.
Tough luck. I did warn you.
