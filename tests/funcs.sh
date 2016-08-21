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
