#! /bin/bash

res=0
cat - > in.xml

while ! xsltproc $SMPL_HOME/smartplaylist-has-paren.xsl in.xml >& /dev/null; do
    xsltproc -o in-tmp.xml $SMPL_HOME/smartplaylist-distrib-or.xsl in.xml
    cp in-tmp.xml in.xml
done

cat in.xml
rm -f in.xml in-tmp.xml

exit $res
