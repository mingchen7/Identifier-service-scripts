#!/bin/bash

#SBATCH -p debug
#SBATCH -t 00:30:00
#SBATCH -n 15
#SBATCH -A Evaluating-Identifie
#SBATCH -J test-checksum
#SBATCH -o test-checksum.o%j

# load python module and install agavepy
#module load python
#source virtualenvwrapper.sh
#mkvirtualenv agave
#pip install agavepy bpython
#workon agave

# install aspera connect tools
#chmod 755 ./bin/install.sh
#chmod 755 ./bin/aspera.sh
#./bin/install.sh

export PATH=$PATH:"$HOME/.aspera/connect/bin"

# get UUID and SRA number
UUID="4181808582778351130-242ac1110-0001-012"
SRA_NUM="SRR292241"
STORE_PATH="./SRR/"

# Downloading file
./bin/aspera.sh ${SRA_NUM} ${STORE_PATH}

# Running checksum and update metadata
if [ $? -eq 0 ]; then
	SRA_FILE="${STORE_PATH}${SRA_NUM}.sra"
else
	exit 1
fi


if [ ! -f "${SRA_FILE}" ]; then
        echo 'SRA file not found! Please confirm the path.'
        exit 1
fi

md5=($(md5sum ${SRA_FILE}))
lastChecksumUpdated=$(date '+%Y-%m-%d %X')

# post the checksum to webhook
curl -k --data "UUID=${UUID}&checksum=${md5}&lastChecksumUpdated=${lastChecksumUpdated}" http://requestb.in/1hop29g1

rm -rf SRR
exit 0
