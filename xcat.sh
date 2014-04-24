#/bin/bash

qlmanage=`which qlmanage`

if [[ "x" = "x$qlmanage" ]]; then
    echo "qlmanage binary is not found."
    exit 1
fi

temp=/tmp/xcat/
size=500

function usage () {

    echo >&2 "Usage:"
    echo >&2 "    $0 <file>"
    echo >&2 "Options:"
    echo >&2 "    -t  temporary directory (default: $temp)"
    echo >&2 "    -s  size of the output (default: $size)"
}

args=`getopt t:s:h $*`
set -- $args

for i; do
    case $i in
        -t)   temp=$2; shift;;
        -s)   size=$2; shift;;
        --)   shift; break;;
        -h)   usage; exit 2;;
        [?]) usage; exit 2;;
    esac
done

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

mkdir -p $temp

for file in $*; do
    [ "--" = $file ] && continue

    if [ -r $file ]; then
        nfile=`cd \`dirname $file\`; pwd`/`basename $file`

        qlmanage -x -t $nfile -s $size -o $temp > /dev/null
        thumb=$temp/`basename $nfile`.png

        printf '\033]1337;File=name='`echo -n "$thumb" | base64`';'
        wc -c $thumb | awk '{printf "size=%d",$1}'
        printf ";inline=1"
        printf ":"
        base64 < $thumb
        printf '\a\n'

        rm -f $thumb
    else
        echo 'File '$file' does not exist.'
    fi
done
