#! /bin/bash

res=0
cat - > in.xml;
while ! xsltproc $SMPL_HOME/smartplaylist-has-paren.xsl in.xml >& /dev/null; do
    xsltproc -o in-tmp.xml $SMPL_HOME/smartplaylist-distrib-or.xsl in.xml
    cp in-tmp.xml in.xml
done

xsltproc $SMPL_HOME/genupdate-sh.xsl in.xml
exit $res
