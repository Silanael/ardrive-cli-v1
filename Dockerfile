# ArDrive CLI v1 docker image 
# 2021-09-20_01          
#
#                                                                 
#     ArDrive CLI                    by  ArDrive Team  (ardrive.io)       
#     Dockerfile + support scripts   by  Silanael      (silanael.com)     
#
#
#
# *** VARIATIONS ***
#
#     Dockerfile        - Release version with safety/helper scripts.
#     Dockerfile-raw    - Raw release version for those familiar with Docker and ardrive-cli.
#     Dockerfile-git    - Development version from https://github.com/ardriveapp/ardrive-cli
#
#     - The release images are optimized for size and speed and are based on node-alpine.     
#     - The development image is single-stage and based on node:latest (Debian)
#       created with future compatibility in mind.
#
#
#
# *** WARNING ***
#
#     - THIS IS A PRESERVATION IMAGE!
#       Though it is fully functional, production use is NOT recommended!
#       Use the upcoming v2 CLI instead.
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




#################
# Builder image #
#################

FROM node:current-alpine AS builder
LABEL description="ArDrive CLI builder image (can be removed)"


# Update the packages and install the build dependencies
RUN apk update && apk upgrade &&            \
    apk add make gcc g++ musl-dev python3


# Install ardrive-cli
WORKDIR /ardrive-cli
RUN yarn add ardrive-cli
RUN yarn cache clean --all







#####################
# Application image #
#####################

FROM node:current-alpine

LABEL description="ArDrive CLI v1 + support scripts"                        \
      author="Silanael"                                                     \
      com.silanael.usage="docker run -it -v datadir:/data <image>"          \
      com.silanael.info="docker run -it --rm <image> [help/info]"           \
      com.silanael.url="silanael.com"                                       \
      com.silanael.e-mail="sila@silanael.com"                               \
      com.silanael.arweave="zPZe0p1Or5Kc0d7YhpT5kBC-JUPcDzUPJeMz2FdFiy4"    \
      com.silanael.createdwith="nano, VS Code"                              \
      com.silanael.sys="Potato-01 MK3"                                      \
      com.silanael.runcommand1="/ardrive-cli/node_modules/.bin/ardrive-cli" \
      com.silanael.runcommand2="yarn run ardrive-cli"                       \      
      com.silanael.version="2021-09-20_01"



# Update the packages and install the final dependencies
RUN apk update && apk upgrade && \
    apk add bash


# Copy the built app and other files needed by the image
# (docker-entrypoint.sh + info.txt)
COPY --from=builder /ardrive-cli ./ardrive-cli
COPY ./src/* /
COPY ./README.md /


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
