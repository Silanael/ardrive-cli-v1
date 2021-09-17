# ArDrive CLI v1 docker image 
# 2021-09-17_01          
#
#     
#     THIS IS A PRESERVATION IMAGE!
#     Though it is fully functional, production use is NOT recommended!
#     Use the upcoming v2 CLI instead.
#
#                                                                 
#     ArDrive CLI                    by  ArDrive Team  (ardrive.io)       
#     Dockerfile + support scripts   by  Silanael      (silanael.com)     
#
#     
#
# *** WARNING ***
#
#     - Wallets created with the CLI can be lost if they're saved
#       into the container instead of into volumes/bind mounts!
#
#     - This version of the CLI doesn't use bundles, so it is possible for
#       one transaction (data or metadata) to go through while the other one
#       gets dropped by the network, resulting in orphaned data.
#
#     - Permaweb is a powerful thing. Once you put something into it,
#       it's there for good. Consider VERY carefully what to upload.
#
#
# *** OTHER ISSUES ***
#
#     - The last time I checked, ardrive-cli threw an exception for
#       files larger than 2GB while still creating a metadata transaction.
#       Don't try your luck. v2 is right around the corner.
#
#     - ardrive-cli throws an exception if it's given a wallet path
#       that doesn't exist, yet it doesn't properly quit after this.
#
#
#  *** FOR THE FUTURE ***
#
#      This Dockerfile pulls the latest commit from the ardrive-cli repo,
#      which is the v1 CLI at the writing of this. When v2 is released,
#      this thing probably breaks - it should be fixable by pointing
#      the git clone-command to the v1-branch (that does not yet exist)
#      in case I forget to / don't feel like fixing it.              
#
#



#################
# Builder image #
#################

FROM node:latest AS builder
LABEL description="ArDrive CLI builder image (can be removed)"

RUN apt-get update && apt-get upgrade

# Dependencies are already present in the base image - should they not be, uncomment the following line:
#RUN apt-get install -y make gcc python3 git

# Cloning only the latest commit - to get the full repository, remove "-- depth 1"
RUN git clone --depth 1 https://github.com/ardriveapp/ardrive-cli.git

WORKDIR /ardrive-cli
RUN yarn






#####################
# Application image #
#####################

FROM node:slim

LABEL description="ArDrive CLI v1 + support scripts"                     \
      author="Silanael"                                                  \
      com.silanael.usage="docker run -it -v datadir:/data <image>"       \
      com.silanael.info="docker run -it --rm <image> [help/info]"        \
      com.silanael.url="silanael.com"                                    \
      com.silanael.e-mail="sila@silanael.com"                            \
      com.silanael.arweave="zPZe0p1Or5Kc0d7YhpT5kBC-JUPcDzUPJeMz2FdFiy4" \
      com.silanael.createdwith="nano"                                    \
      com.silanael.sys="Potato-01 MK3"                                   \                                
      com.silanael.version="2021-09-17_01"


# Update the packages
RUN apt-get update && apt-get upgrade && apt autoremove -y && apt-get clean


# Copy the built app and other files needed by the image
# (docker-entrypoint.sh + info.txt)
COPY --from=builder /ardrive-cli ./ardrive-cli
COPY ./src/* /


# Create directory structure and set up dummy files that are
# used to detect whether the important paths have been mounted.
# /wallets only needs to be present for the first run,
# /data/db and /data/sync should always be mounted.
RUN mkdir /data;                                                 \
    mkdir /data/db;       touch /data/db/.notmounted;            \
    mkdir /data/sync;     touch /data/sync/.notmounted;          \
    mkdir /data/wallets;  touch /data/wallets/.notmounted;       \    
    ln -s /data/db /db;                                          \
    ln -s /data/wallets /wallets;                                \
    ln -s /data/sync /sync;                                      \
    ln -s /data/db/.ardrive-cli.db /ardrive-cli/.ardrive-cli.db; 
    # ^ This effectively relocates .ardrive-cli.db


WORKDIR /ardrive-cli
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["cli"]
