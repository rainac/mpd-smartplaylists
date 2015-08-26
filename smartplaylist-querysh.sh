#! /bin/bash

res=0

cat - | smartplaylist-distrib-or-over-and.sh | xsltproc $SMPL_HOME/genupdate-sh.xsl -

exit $res
