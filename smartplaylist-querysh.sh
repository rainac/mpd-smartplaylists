#! /bin/bash

cat - | xsltproc $SMPL_HOME/genupdate-sh.xsl - | tee tmp.sh
