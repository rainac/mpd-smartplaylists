#! /bin/bash

cat - | xsltproc $SMPL_HOME/smartplaylist-distrib-or.xsl - | tee tmp3.xml | xsltproc $SMPL_HOME/genupdate-sh.xsl - | tee tmp.sh
