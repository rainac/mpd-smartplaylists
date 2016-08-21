#! /bin/bash

SMPL_HOME=${SMPL_HOME:-$(dirname $BASH_SOURCE)/..}

test_simple_filter_query() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "album=abc>ttt" | tee tmp.sh)
    echo "mpc search album abc|grep -i -v \"ttt\"" | diff -B -w - tmp.sh
    assertEquals "0" "$?"
}

test_simple_filter_query2() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "album=abc<ttt" | tee tmp.sh)
    echo "mpc search album abc|grep -i \"ttt\"" | diff -B -w - tmp.sh
    assertEquals "0" "$?"
}

test_simple_filter_query3() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "album=abc filter ttt" | tee tmp.sh)
    echo "mpc search album abc|grep -i -v \"ttt\"" | diff -B -w - tmp.sh
    assertEquals "0" "$?"
}

test_simple_filter_query3a() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "album=abc filter_out ttt" | tee tmp.sh)
    echo "mpc search album abc|grep -i -v \"ttt\"" | diff -B -w - tmp.sh
    assertEquals "0" "$?"
}

test_simple_filter_query4() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "album=abc filter_in ttt" | tee tmp.sh)
    echo "mpc search album abc|grep -i \"ttt\"" | diff -B -w - tmp.sh
    assertEquals "0" "$?"
}

test_simple_filter_quer5() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "abc>ttt" | tee tmp.sh)
    echo "mpc search artist abc|grep -i -v \"ttt\"" | diff -B -w - tmp.sh
    assertEquals "0" "$?"
}

test_simple_filter_query6() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "abc<ttt" | tee tmp.sh)
    echo "mpc search artist abc|grep -i \"ttt\"" | diff -B -w - tmp.sh
    assertEquals "0" "$?"
}

test_filter_prec_and() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "abc and def<ttt" | tee tmp.sh)
    echo "mpc search artist abc artist def|grep -i \"ttt\"" | diff -B -w - tmp.sh
    assertEquals "0" "$?"
}

test_filter_prec_or() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "abc or def<ttt" | tee tmp.sh)
    echo -e "(\n\
           mpc search artist abc \n\
           mpc search artist def)|grep -i \"ttt\"" | diff -B -w - tmp.sh
    assertEquals "0" "$?"
}

test_filter_prec_paren() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "(abc>t11) or (def<t22)" | tee tmp.sh)
    echo -e "(\n\
           mpc search artist abc|grep -i -v \"t11\" \n\
           mpc search artist def|grep -i \"t22\")" | diff -B -w - tmp.sh
    assertEquals "0" "$?"
}

test_filter_prec_and_or() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "(abc and def>t11) or (ghi and jkl<t22)" | tee tmp.sh)
    echo -e "(\n\
           mpc search artist abc artist def|grep -i -v \"t11\" \n\
           mpc search artist ghi artist jkl|grep -i \"t22\")" | diff -B -w - tmp.sh
    assertEquals "0" "$?"
}

_test_filter_prec_and_or_error1() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "(abc and def>t11) and (ghi and jkl<t22)" | tee tmp.sh)
    echo -e "(\n\
           mpc search artist abc|grep -i -v \"t11\" \n\
           mpc search artist def|grep -i \"t22\")" | diff -B -w - tmp.sh
    assertEquals "0" "$?"
}

_test_filter_prec_and_or_error2() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "(abc or def>t11) and (ghi or jkl<t22)" | tee tmp.sh)
    echo -e "(\n\
           mpc search artist abc|grep -i -v \"t11\" \n\
           mpc search artist def|grep -i \"t22\")" | diff -B -w - tmp.sh
    assertEquals "0" "$?"
}

test_filter_prec_and_or_poss() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh "(abc or def>t11) or (ghi or jkl<t22)" | tee tmp.sh)
    echo -e "((\n\
           mpc search artist abc\n\
           mpc search artist def)|grep -i -v \"t11\"( \n\
           mpc search artist ghi\n\
           mpc search artist jkl)|grep -i \"t22\")" | diff -B -w - tmp.sh
    assertEquals "0" "$?"
}

test_cleanup() {
    rm -f tmp.sh
}

. shunit2
