#! /bin/bash

set -e

configFile=$1

SMPL_HOME=${SMPL_HOME:-.}
p2xConfig=$SMPL_HOME/p2x.conf

input=tmp.input
cat - > $input

p2x --output-mode y -p $p2xConfig $input | tr '[:upper:]' '[:lower:]' | tee tmp.xml > /dev/null

xsltproc $SMPL_HOME/create-smartplaylist.xsl tmp.xml > tmp2.xml 2> err1.txt
xsltproc $SMPL_HOME/create-smartplaylist2.xsl tmp2.xml | tee tmp3.xml 2> err2.txt
