#! /bin/bash

configFile=${1:-$HOME/.config/smartplaylists}

./smartplaylist.sh -m spsh < $configFile | tee tmp.sh

bash tmp.sh

rm tmp.sh
