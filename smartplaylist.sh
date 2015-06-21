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

export SMPL_HOME=$sourceDir
export PATH=$PATH:$SMPL_HOME

TMP=${TMP:-/tmp}

tmpdir=$TMP/smpl-$$

mkdir -p $tmpdir

cp Makefile $tmpdir

mode=${mode:-spfl}

if [[ -z "$1" ]]; then
    cat - > $tmpdir/tmp.data
else
    echo "$@" > $tmpdir/tmp.data
fi

intype=$(./sniff-input-type.sh $tmpdir/tmp.data)

cp $tmpdir/tmp.data $tmpdir/tmp.$intype

make -s -C $tmpdir tmp.$mode

if [[ -f $tmpdir/tmp.$mode ]]; then
    cat $tmpdir/tmp.$mode
fi

rm -rf $tmpdir
