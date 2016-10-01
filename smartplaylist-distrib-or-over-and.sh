#! /bin/bash

res=0
cat - > in.xml

maxiter=100
iter=0

while ! xsltproc $SMPL_HOME/smartplaylist-has-paren.xsl in.xml >& /dev/null; do
    xsltproc -o in-tmp.xml $SMPL_HOME/smartplaylist-distrib-or.xsl in.xml
    res=$?
    if [[ "$res" != "0" ]]; then
        echo "error: XSLT processing failed" >&2
        break
    fi
    cp in-tmp.xml in.xml
    iter=$(( $iter + 1 ))
    if [[ $iter -gt $maxiter ]]; then
        echo "$(basename $0): error: maximum number of iterations reached" >&2
        res=1
        break
    fi
done

if [[ "$res" = 0 ]]; then
    cat in.xml
fi
rm -f in.xml in-tmp.xml

exit $res
