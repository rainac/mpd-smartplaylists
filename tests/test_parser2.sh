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

test_cleanup() {
    rm -f tmp.sh
}

. shunit2
