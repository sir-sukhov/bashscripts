#!/bin/bash
#
# MIT License
#
# Copyright (c) 2020 sir-sukhov
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#
inpath=$1
bytes_in_part="10m"

set -e

function log() {
        echo "$(date +"[%Y-%m-%d %H:%M:%S%z UTC]") $1"
}

function encrypt_file() {
        log "Encrypting file $inpath to $inpath.enc"
        [ -f $inpath.enc ] && log "$inpath.enc already exists, exiting for safety" && exit 1
        [ -z $PSSWRD ] && echo -n "Please provide encryption password: " && read -s PSSWRD && echo
        cat $inpath | openssl enc -aes-256-cbc -md md5 -k $PSSWRD > $inpath.enc
}

function decrypt_file() {
        log "Decrypting .enc file from $inpath"
        encfile=$(find $inpath -type f -name '*.enc')
        [ ! -f $ecnfile ] && log "Can't find .enc file, exiting" && exit 1 || log "Decrypting $encfile"
        [ -z $PSSWRD ] && echo -n "Please provide decryption password: " && read -s PSSWRD && echo
        cat $encfile | openssl enc -d -aes-256-cbc -md md5 -k $PSSWRD > ${encfile%.enc}
}

function split_file() {
        log "Creating directory with parts ${inpath}_split"
        [ -d ${inpath}_split ] && log "Directory already exists, exit for safety" && exit 1
        mkdir ${inpath}_split
        log "Splitting file $inpath.enc to ${inpath}_split"
        split -b $bytes_in_part $inpath.enc ${inpath}_split/$(basename $inpath).
}

function join_files() {
        log "Joining files from $inpath, checking things"
        [ ! $(ls -1 $inpath | wc -l) -gt 1 ] && log "Expected more than 1 file in dir, exiting" && exit 1
        [ ! $(ls -1 $inpath | rev | cut -d'.' -f2- | rev | uniq | wc -l) -eq 1 ] && log "Name inconsistency found, exiting" && exit 1
        for f in $(find $inpath -type f | sort)
        do
                cat $f >> ${f%.*}.enc
        done
        log "Joined file should now be at ${f%.*}.enc"
}

if [ ! -z $inpath ] && [ -f $inpath ]
then
        log "Regular file is provided as input path"
        encrypt_file
        split_file
        log "Removing encrypted file"
        rm -rf $inpath.enc
elif [ ! -z $inpath ] && [ -d $inpath ]
then
        log "Directory is provided as input path"
        join_files
        decrypt_file
else
        log "Please provide file to split or dir to join as a parameter" && exit 1
fi
