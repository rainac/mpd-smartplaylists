#! /bin/zsh

MPD_HOST=${MPD_HOST:-192.168.0.1}

if [[ -z "$MPD_ROOT" ]]; then
    MPD_ROOT=/opt/music
    echo warning, MPD_ROOT is not set, defaulting to $MPD_ROOT
fi
# MPD_ROOT=${MPD_ROOT:-/opt/music}

MPD_BASE=$MPD_HOST:$MPD_ROOT

DST_HOST=${DST_HOST:-localhost}    #
DST_ROOT=${DST_ROOT:-music}        # i.e. /home/user/music for user

optstr=":vhDajJzZp:d:m:"

while getopts "$optstr" option; do
    case $option in
        (h)
            show_help=1
        ;;
        (D)
            set -x
            debug=1
        ;;
        (v)
            show_version=1
        ;;
        (z)
            COMPFLAG=z
        ;;
        (Z)
            COMPFLAG=Z
        ;;
        (j)
            COMPFLAG=j
        ;;
        (J)
            COMPFLAG=J
        ;;
        (a)
            COMPFLAG=a
        ;;
        (p)
            DST_TAR_OPTS=--strip-components="${OPTARG}"
        ;;
        (d)
            DST_HOST=${OPTARG%%:*}
            DST_ROOT=${OPTARG#*:}
        ;;
        (m)
            MPD_HOST=${OPTARG%%:*}
            MPD_ROOT=${OPTARG#*:}
        ;;
        (*)
        ;;
    esac
done

cat - > tmp.list

cat > host-script.sh <<EOF
CURDIR=\$PWD
cd $MPD_ROOT
tar -c$COMPFLAG -T \$CURDIR/tmp.list
EOF

if [[ -n "$debug" ]]; then cat host-script.sh; fi

cat > dev-script.sh <<EOF
cd $DST_ROOT
tar $DST_TAR_OPTS -xv$COMPFLAG
EOF

if [[ -n "$debug" ]]; then cat dev-script.sh; fi

scp -q tmp.list host-script.sh $MPD_HOST:
scp -q dev-script.sh $DST_HOST:

ssh $MPD_HOST "sh host-script.sh" | ssh $DST_HOST "sh dev-script.sh"

if [[ -z "$debug" ]]; then
    ssh $MPD_HOST "rm -f host-script.sh tmp.list"
    ssh $DST_HOST "rm -f dev-script.sh"
fi
