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
dir=$1
parts_count=$2
transport_dir=$3
file_list=${dir}.filelist

function log() {
        echo "$(date +"[%Y-%m-%d %H:%M:%S%z UTC]") $1"
}

function archive() {
        local part_num=$1
        local first=$2
        local part_size=$3
        local last=$(( first + part_size - 1 ))
        local archive=${dir}_part${part_num}_of_${parts_count}.zip
        log "Creating part $part_num of $parts_count from $first to file $last inclusive"
        tail -n+$first $file_list | head -n $part_size | zip -j --quiet --temp-path $transport_dir -@ $transport_dir/${archive}
}

log "Creating ${file_list}" && ls -U1 $dir | awk -v dir="$dir" '{print dir"/"$0}' > ${file_list}
files_count=$(wc -l ${file_list} | grep -oEe "[0-9]+ " | tr -d " ")
log "Splitting $files_count files into $parts_count parts_count"
part_size=$(( files_count / parts_count))
fat_part_size=$(( part_size + 1 ))
fat_parts_count=$(( files_count % parts_count))
if [[ $fat_parts_count -eq 0 ]]
then
        log "All parts will have size of $part_size"
else
        log "First $fat_parts_count part(s) will have size of $fat_part_size, the rest will have size of $part_size"
fi
i=1
offset=1
while [[ $i -le $parts_count ]]
do
        if [[ $i -gt $fat_parts_count ]]
        then
                this_part_size=$part_size
        else
                this_part_size=$fat_part_size
        fi
        archive $i $offset $this_part_size
        offset=$(( offset + this_part_size ))
        (( i++ ))
done
