#! /bin/bash

configFile=$1

SMPL_HOME=${SMPL_HOME:-.}
p2xConfig=$SMPL_HOME/p2xjs.conf

input=tmp.input
cat - > $input

p2xjs -c $p2xConfig $input | tee tmp.xml > /dev/null

xsltproc $SMPL_HOME/create-smartplaylist.xsl tmp.xml | tee tmp2.xml

