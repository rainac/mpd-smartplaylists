#! /bin/bash

export SMPL_HOME=$(readlink -f $(dirname $BASH_SOURCE)/..)
export SMPL_LIB=${SMPL_HOME}
export SMPL_XSL=${SMPL_HOME}
export SMPL_SCRIPTS=${SMPL_HOME}

. ${SMPL_HOME}/tests/funcs.sh

test_simple_filter_query() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "album=abc>ttt" | tee tmp.sh)
    echo "mpc search album abc|grep -i -v \"ttt\"" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_simple_filter_query2() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "album=abc<ttt" | tee tmp.sh)
    echo "mpc search album abc|grep -i \"ttt\"" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_simple_filter_query3() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "album=abc filter ttt" | tee tmp.sh)
    echo "mpc search album abc|grep -i -v \"ttt\"" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_simple_filter_query3a() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "album=abc filter_out ttt" | tee tmp.sh)
    echo "mpc search album abc|grep -i -v \"ttt\"" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_simple_filter_query4() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "album=abc filter_in ttt" | tee tmp.sh)
    echo "mpc search album abc|grep -i \"ttt\"" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_simple_filter_quer5() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "abc>ttt" | tee tmp.sh)
    echo "mpc search artist abc|grep -i -v \"ttt\"" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_simple_filter_query6() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "abc<ttt" | tee tmp.sh)
    echo "mpc search artist abc|grep -i \"ttt\"" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_filter_prec_and() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "abc and def<ttt" | tee tmp.sh)
    echo "mpc search artist abc artist def|grep -i \"ttt\"" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_filter_prec_or() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "abc or def<ttt" | tee tmp.sh)
    echo -e "(\n\
           mpc search artist abc \n\
           mpc search artist def)|grep -i \"ttt\"" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_filter_prec_paren() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "(abc>t11) or (def<t22)" | tee tmp.sh)
    echo -e "(\n\
           mpc search artist abc|grep -i -v \"t11\" \n\
           mpc search artist def|grep -i \"t22\")" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_filter_prec_and_or() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "(abc and def>t11) or (ghi and jkl<t22)" | tee tmp.sh)
    echo -e "(\n\
           mpc search artist abc artist def|grep -i -v \"t11\" \n\
           mpc search artist ghi artist jkl|grep -i \"t22\")" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_filter_prec_and_or_error1() {
    $SMPL_HOME/smartplaylist.sh -m spsh "(abc and def>t11) and (ghi and jkl<t22)" 2> error.txt
    res=$?
    assertNotEquals "This expression should raise an error" "0" "$res"
    grep -i "filter.*and.*not.*allowed" error.txt
    assertEquals "There should be an error message" "0" "$?"
}

test_filter_prec_and_or_error2() {
    $SMPL_HOME/smartplaylist.sh -m spsh "(abc or def>t11) and (ghi or jkl<t22)" 2> error.txt
    res=$?
    assertNotEquals "This expression should raise an error" "0" "$res"
    grep -i "filter.*and.*not.*allowed" error.txt
    assertEquals "There should be an error message" "0" "$?"
}

test_filter_prec_and_or_poss() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "(abc or def>t11) or (ghi or jkl<t22)" | tee tmp.sh)
    echo -e "((\n\
           mpc search artist abc\n\
           mpc search artist def)|grep -i -v \"t11\"( \n\
           mpc search artist ghi\n\
           mpc search artist jkl)|grep -i \"t22\")" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_filter_and_filtered() {
    $SMPL_HOME/smartplaylist.sh -m spsh "abc and album=test < filt" > tmp.sh
    res=$?
    assertEquals "This expression pass OK" "0" "$res"
    echo -e "mpc search artist abc album test |grep -i \"filt\"" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_filter_and_in_paren_filtered() {
    $SMPL_HOME/smartplaylist.sh -m spsh "(abc and album=test) < filt" > tmp.sh
    res=$?
    assertEquals "This expression pass OK" "0" "$res"
    echo -e "mpc search artist abc album test |grep -i \"filt\"" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_filter_and_one_op_in_paren_filtered() {
    $SMPL_HOME/smartplaylist.sh -m spsh "abc and (album=test) < filt" > tmp.sh
    res=$?
    assertEquals "This expression pass OK" "0" "$res"
    echo -e "mpc search artist abc album test |grep -i \"filt\"" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_cleanup() {
    rm -f tmp.sh cmp.sh error.txt
}

. shunit2
