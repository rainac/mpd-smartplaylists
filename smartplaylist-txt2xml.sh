#! /bin/bash

configFile=$1

SMPL_HOME=${SMPL_HOME:-.}
p2xConfig=$SMPL_HOME/p2x.conf

input=tmp.input
cat - > $input

p2x --output-mode y -p $p2xConfig $input | tr '[:upper:]' '[:lower:]' | tee tmp.xml > /dev/null

xsltproc $SMPL_HOME/create-smartplaylist.xsl tmp.xml | tee tmp2.xml

