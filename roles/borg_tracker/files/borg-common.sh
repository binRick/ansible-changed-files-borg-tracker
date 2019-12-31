BORG_ARGS="--lock-wait 10"
env > ~/.env-debug
bd(){
    borg diff $BORG_ARGS $1::$2 $3|tr -s ' ' |sed 's/[[:space:]]/ /g'|egrep -v '^added directory |^added [0-9]'|cut -d' ' -f6 \
        |xargs -I % echo "/%" \
        |grep -v '\['
}
bdcf(){
    borg list $1::$2 --format="{type},{path}{NEWLINE}"|grep  -v ^d|cut -d',' -f2|sed 's/^before\///g'|sed '/^after\//g'|grep -v '^$'
}
recordReport(){
    for x in $(borg list ~/.borg-record-db --format="{name}{NEWLINE}"); do 
        echo "Repo $x"
        QTY="$(bdcf ~/.borg-record-db |wc -l)"
        if [[ "$QTY" -lt 5 ]]; then
            bdcf ~/.borg-record-db $x|xargs -I % echo -e "  /%"
        else
            echo "$QTY files..."
        fi
    done
}
bdd(){
  MODE="$4"
  (
    [[ "$DEBUG_MODE" == "1" ]] && set -x
    set -e
    [[ -d ~/.tmp ]] || mkdir ~/.tmp
    BD=$(mktemp -d -p ~/.tmp)
    cd $BD
    bd $1 $2 $3 > files.txt
    (mkdir $2 && cd $2 && borg extract $1::$2 $( cat ../files.txt |sed 's/^\///g'|tr '\n' ' '))
    (mkdir $3 && cd $3 && borg extract $1::$3 $( cat ../files.txt |sed 's/^\///g'|tr '\n' ' '))
    # >&2 du --max-depth=0 -h $2
    # >&2 du --max-depth=0 -h $3
    # >&2 find $2 -type f
    # >&2 find $3 -type f
    REPO_TIME1=$(borg info $BORG_ARGS $1::$2 |grep 'Time (start):'|cut  -d' ' -f4-10|sed 's/ /_/g'|sed 's/:/-/g')
    REPO_TIME2=$(borg info $BORG_ARGS $1::$3 |grep 'Time (start):'|cut  -d' ' -f4-10|sed 's/ /_/g'|sed 's/:/-/g')
    REPO_FILE_BASE="$(hostname -f)-${REPO_TIME1}-${REPO_TIME2}-changed-files"
    REPO_FILE="${REPO_FILE_BASE}.tar.gz"
    mv $2 before
    mv $3 after
    if [[ "$MODE" == "debug" ]]; then
        pwd
    elif [[ "$MODE" == "record" ]]; then
        [[ "$BORG_RECORD_DB" == "" ]] && export BORG_RECORD_DB=~/.borg-record-db
        [[ -d ~/.borg-record-db ]] || borg init -e repokey $BORG_RECORD_DB 2>/dev/null
        borg prune --keep-within 1d $BORG_RECORD_DB
        borg create $BORG_RECORD_DB::$REPO_FILE_BASE before after
        echo OK
    elif [[ "$MODE" == "tarball" ]]; then
        tar -czf "$REPO_FILE" before after
        echo $(pwd)/$REPO_FILE
    elif [[ "$MODE" == "delete" ]]; then
        set -e
        borg delete $1::$2
        borg delete $1::$3
        echo OK
    fi
  )
}
