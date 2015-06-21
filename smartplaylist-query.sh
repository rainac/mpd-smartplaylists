#! /bin/bash

echo "$@" | ./smartplaylist-querysh.sh | tee tmp.sh > /dev/null
bash tmp.sh

