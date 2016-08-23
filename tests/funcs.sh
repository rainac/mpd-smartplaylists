#! /bin/bash

syntaxCheck() {
    inf=$1
    sed -e "s/mpc/true/" $inf > tmpc.sh
    cat > tmpd.sh < tmpc.sh <<EOF
true
EOF
    bash tmpd.sh
    assertEquals "0" "$?"
}

cmpMultiLineShellScript() {
    inf=$1
    cmpf=$2

    awk '{ ORS=""; print $0 }' $inf > tmp1.sh
    awk '{ ORS=""; print $0 }' $cmpf > tmp2.sh

    diff -B -w tmp1.sh tmp2.sh

    assertEquals "0" "$?"

    rm -rf  tmp1.sh tmp2.sh

}
