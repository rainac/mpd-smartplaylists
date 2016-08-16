#! /bin/zsh

MPD_HOST=${MPD_HOST:-192.168.0.1}

MPD_ROOT=${MPD_ROOT:-/opt/music}

MPD_BASE=$MPD_HOST:$MPD_ROOT

DST_HOST=${DST_HOST:-localhost}    #
DST_ROOT=${DST_ROOT:-music}        # i.e. /home/user/music for user

optstr=":vhDajJzZp:d:m:W:"

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
        (c)
            command=$OPTARG
        ;;
        (m)
            MPD_HOST=${OPTARG%%:*}
            MPD_ROOT=${OPTARG#*:}
        ;;
        (W)
            flags=$OPTARG
        ;;
        (*)
        ;;
    esac
done

cat - > tmp.list

cat > host-script.sh <<EOF
#set -x
CURWD=\$PWD
cd $MPD_ROOT
IFS=$'\0'
for k in \$(cat \$CURWD/tmp.list); do
#  echo "File is k='\${k}'"
  cmd=\$(echo "$command" | sed -e "s^{}^\${k}^")
#  echo "Command is X\${cmd}X"
  bash -c "\$cmd"
done
EOF

if [[ -n "$debug" ]]; then cat host-script.sh; fi

if [[ -n "$MPD_HOST" ]]; then
    scp -q tmp.list host-script.sh $MPD_HOST:
    ssh $MPD_HOST "\$SHELL host-script.sh"
else
    $SHELL host-script.sh
fi


if [[ -z "$debug" ]]; then
    if [[ -n "$MPD_HOST" ]]; then
        ssh $MPD_HOST "rm -f host-script.sh"
    fi
    rm -f host-script.sh
fi
