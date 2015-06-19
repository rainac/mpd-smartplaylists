#! /bin/zsh

configFile=$1

p2xConfig=p2xjs.conf

input=tmp.input
echo "$@" > $input

p2xjs -c $p2xConfig $input | tee tmp.xml > /dev/null

xsltproc create-smartplaylist.xsl tmp.xml | tee tmp2.xml > /dev/null

xsltproc genupdate-sh.xsl tmp2.xml | tee tmp.sh > /dev/null

bash tmp.sh
