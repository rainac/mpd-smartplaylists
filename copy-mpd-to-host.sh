#! /bin/zsh

MPD_HOST=${MPD_HOST:-192.168.0.1}

#MPD_ROOT=$(./get-mpd-root.sh)
MPD_ROOT=${MPD_ROOT:-/opt/music}

MPD_BASE=$MPD_HOST:$MPD_ROOT

DST=${DST:-localhost:music}    # i.e. /home/user/music for user

cat - > tmp.list

echo "set -x" | tee tmp.script
data=$(cat tmp.list)
for i in ${(f)data}; do
    name=$(echo "$i" | sed -e 's/ /\\ /g' | sed -e 's/(/\\(/g' | sed -e 's/)/\\)/g' | sed -e "s/\"/\\\\\"/g" | sed -e "s/'/\\\\'/g")
    basename_clean=$(basename "$name")
    basename=$(basename "$i")
    echo scp "\"$MPD_BASE/$name\"" tmp-file | tee -a tmp.script
    echo scp tmp-file "\"${DST}/$basename_clean\"" | tee -a tmp.script
done
