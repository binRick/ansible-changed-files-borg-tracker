#!/bin/bash
set -e
OUT_FILE=$1


cat $OUT_FILE |tr -s ' '|grep '^removed [0-9]' \
    |cut -d' ' -f2,3,4 \
    > .REMOVED.txt
cat $OUT_FILE |tr -s ' '|grep '^removed directory ' \
    |cut -d' ' -f1,3 \
    > .REMOVED_DIRECTORY.txt
cat $OUT_FILE |tr -s ' '|grep '^added directory ' \
    |cut -d' ' -f1,3 \
    > .ADDED_DIRECTORY.txt
cat $OUT_FILE |tr -s ' '|grep '^added [0-9]' \
    |cut -d' ' -f2,3,4 \
    > .ADDED.txt
cat $OUT_FILE|grep -v '^[a-z]'|tr -s ' ' \
    |sed 's/^[[:space:]]//g'|cut -d' ' -f1,2,3,4,5 \
    > .CHANGED.txt

consume_dirs(){
    while read -r line; do
        DIR="$(echo $line|cut -d' ' -f2)"
        jo dir=$DIR
    done < $1
}
changed_files(){
    while read -r line; do
        SIZE1="$(echo $line|cut -d' ' -f1)"
        UNIT1="$(echo $line|cut -d' ' -f2)"
        SIZE2="$(echo $line|cut -d' ' -f3)"
        UNIT2="$(echo $line|cut -d' ' -f4)"
        FILE="$(echo $line|cut -d' ' -f5)"
        jo size1="$SIZE1" unit1="$UNIT1" size2="$SIZE2" unit2="$UNIT2" file="/$FILE"
    done < $1
}
consume_files(){
    while read -r line; do
        SIZE="$(echo $line|cut -d' ' -f1)"
        UNIT="$(echo $line|cut -d' ' -f2)"
        FILE="$(echo $line|cut -d' ' -f3)"
        jo size=$SIZE unit=$UNIT file=/$FILE
    done < $1
}

consume_files .ADDED.txt > .ADDED.json
consume_dirs .ADDED_DIRECTORY.txt > .ADDED_DIRECTORY.json
consume_dirs .REMOVED_DIRECTORY.txt > .REMOVED_DIRECTORY.json
consume_dirs .REMOVED.txt > .REMOVED.json
changed_files .CHANGED.txt > .CHANGED.json



qty(){
    wc -l $1|cut -d' ' -f1
}

 jo -p \
    files_added_qty=$(qty .ADDED.txt) dirs_added_qty=$(qty .ADDED_DIRECTORY.txt) \
    files_removed_qty=$(qty .REMOVED.txt) dirs_removed_qty=$(qty .REMOVED_DIRECTORY.txt) \
    files_changed_qty=$(qty .CHANGED.txt) \
    dirs_added=$(jo -a $(cat .ADDED_DIRECTORY.txt |cut -d' ' -f3|xargs -I % echo "/%")) \
    dirs_removed=$(jo -a $(cat .REMOVED_DIRECTORY.txt |cut -d' ' -f3|xargs -I % echo "/%")) \
    files_added=$(jo -a $(cat .ADDED.txt |cut -d' ' -f3|xargs -I % echo "/%")) \
    files_removed=$(jo -a $(cat .REMOVED.txt |cut -d' ' -f3|xargs -I % echo "/%")) \
    files_changed=$(jo -a $(cat .CHANGED.txt |cut -d' ' -f5|xargs -I % echo "/%"))

#    REMOVED_FILES=$(jo -a b=$(cat .REMOVED.txt |cut -d' ' -f3|xargs -I % echo "/%"|tr '\n' ' '))


if [[ "1" == "0" ]]; then
    files_added=$(qty .ADDED.txt) dirs_added=$(qty .ADDED_DIRECTORY.txt) \
    files_added_file=.ADDED.txt dirs_added_file=.REMOVED.txt \
    files_removed_file=.ADDED_DIRECTORY.txt dirs_removed_file=.REMOVED_DIRECTORY.txt \
    files_changed_file=.CHANGED.txt \
    files="$(jo -a .ADDED.txt .REMOVED.txt .REMOVED_DIRECTORY.txt .ADDED_DIRECTORY.txt .CHANGED.txt)" \
    \
    files_changed_b64="$(cat .CHANGED.txt | base64 -w0)" \
    files_removed_b64="$(cat .REMOVED.txt | base64 -w0)" \
    files_added_b64="$(cat .ADDED.txt | base64 -w0)" \
    dirs_removed_b64="$(cat .REMOVED_DIRECTORY.txt | base64 -w0)" \
    dirs_added_b64="$(cat .ADDED_DIRECTORY.txt | base64 -w0)" \
    \
    _files_changed_b64="$(cat .CHANGED.json | base64 -w0)" \
    _files_removed_b64="$(cat .REMOVED.json | base64 -w0)" \
    _files_added_b64="$(cat .ADDED.json | base64 -w0)" \
    _dirs_removed_b64="$(cat .REMOVED_DIRECTORY.json | base64 -w0)" \
    _dirs_added_b64="$(cat .ADDED_DIRECTORY.json | base64 -w0)"

fi
