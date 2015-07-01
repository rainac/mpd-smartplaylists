#! /bin/bash
# suffixes:
#
#  spxml - XML format
#  sp    - Text format
#  spsh  - Bash (mpc command line) format
#  spfl  - File list as returned by MPD searches
#  spfls  - File list as returned by MPD searches, separated by a special mark
#  spfl0  - File list as returned by MPD searches, 0 separated

# useful commands:
#  - transfer playlist to device
#
#  $ mode=scp-handy ./smartplaylist.sh dream theater
#  everyone needs to edit copy-mpd-to-handy.sh for now
#
#  - transfer file list to device

# set -x 

sourceDir=$(dirname $(readlink -f $BASH_SOURCE))

DST=handy:/mnt/sdcard2/music

optstring=":hvDd:m:"
option=""

make_silent_flag=-s

while getopts $optstring option; do
    case $option in
        (\?)
        echo "admproc: error: illegal option -$OPTARG specified" >&2
        exit 1
        ;;
        (\:)
        echo "admproc: error: argument expected after -$OPTARG option" >&2
        exit 1
        ;;
        (h)
            show_help=1
        ;;
        (v)
            show_version=1
        ;;
        (d)
            DST=$OPTARG
        ;;
        (D)
            set -x
            DEBUG=1
            export debug_flag=-D
            make_silent_flag=""
        ;;
        (m)
            mode=$OPTARG
        ;;
        (*)
            echo "invalid option $OPTION"
        ;;
    esac
done

if [[ -n "$show_help" ]]; then
    echo "smartplaylist.sh"
    echo "Usage: ./smartplaylist.sh {Option} Query"
    echo "Options:"
    echo "  -m <mode>                  set operation mode"
    echo "     spxml                    produce XML form of smartplaylist (input is TXT)"
    echo "     spsh                     Bash shell code to execute given query"
    echo "     spfl                     file list of MPD query"
    echo "     scp                      send files in MPD result list to device with scp (use option -d)"
    echo "     tar                      send files in MPD result file to device with tar + ssh"
    echo "     rsync                    send files in MPD result file to device with rsync + ssh"
    echo "  -d <device>                set target device"
    echo ""
    echo "Query:"
    echo "  name                       search for artists which contain <name>"
    echo "  artist=name                the same"
    echo "  title=name                 search for song titles which contain <name>"
    echo "  query and other            search for artists which contain <query> and <other>"
    echo "  query or other             search for artists which contain <query> or <other>"
    echo ""
    echo "Examples:"
    echo "1)"
    echo "  $ ./smartplaylist.sh coscu and title=bailar"
    echo "Execute query and print result list to stdout"
    echo ""
    echo "2)"
    echo "  $ ./smartplaylist.sh -m tar -d mobile:Music coscu and title=bailar"
    echo "Send query results to directory 'Music' on host 'mobile'"
    echo ""
    echo "3)"
    echo "  $ ./smartplaylist.sh -m spsh coscu and title=bailar"
    echo "  mpc search  artist coscu title bailar"
    echo "Return bash shell code for the query with mpc"
    exit
fi

if [[ -n "$show_version" ]]; then
    echo "smartplaylist 0.1"
    exit
fi

export SMPL_HOME=$sourceDir
export PATH=$PATH:$SMPL_HOME

export DST

TMP=${TMP:-/tmp}

tmpdir=$TMP/smpl-$$

mkdir -p $tmpdir

cp Makefile $tmpdir

mode=${mode:-spfl}

shift $(($OPTIND - 1))

if [[ -z "$1" ]]; then
    cat - > $tmpdir/tmp.data
else
    echo "$@" > $tmpdir/tmp.data
fi

intype=$(./sniff-input-type.sh $tmpdir/tmp.data)

cp $tmpdir/tmp.data $tmpdir/tmp.$intype

device=$DST make $make_silent_flag -C $tmpdir tmp.$mode

if [[ -f $tmpdir/tmp.$mode ]]; then
    cat $tmpdir/tmp.$mode
fi

rm -rf $tmpdir
