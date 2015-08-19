#! /bin/bash

SMPL_HOME=${SMPL_HOME:-$(dirname $BASH_SOURCE)/..}

test_simple_query() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh album=abc | tee tmp.sh)
    echo "mpc search album abc" | diff -B -w - tmp.sh
    assertEquals "0" "$?"
}
test_simple_query_def() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh abc | tee tmp.sh)
    echo "mpc search artist abc" | diff -B -w - tmp.sh
    assertEquals "0" "$?"
}

test_and_query() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh album=a and album=b | tee tmp.sh)
    echo "mpc search album a album b" | diff -B -w - tmp.sh
    assertEquals "0" "$?"
}
test_or_query() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh album=a or album=b | tee tmp.sh)
    echo -e "mpc search album a\nmpc search album b" | diff -B -w - tmp.sh
    assertEquals "0" "$?"
}

test_string_query() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh album=a and album = "a B c" | tee tmp.sh)
    echo "mpc search album a album 'a b c'" | diff -B -w - tmp.sh
    assertEquals "0" "$?"

    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh album=a and album = 'a B c' | tee tmp.sh)
    echo "mpc search album a album 'a b c'" | diff -B -w - tmp.sh
    assertEquals "0" "$?"
}

test_and_nested_or_query() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh artist=bad and '(' album=god or album=rise ')' | tee tmp.sh)
    echo "mpc search  artist bad album god
    mpc search  artist bad album rise" | diff -B -w - tmp.sh
    assertEquals "0" "$?"

    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh artist=bad and '(' album=god or album=rise ')' and title=miss| tee tmp.sh)
    echo "mpc search  artist bad album god title miss
    mpc search  artist bad album rise title miss" | diff -B -w - tmp.sh
    assertEquals "0" "$?"

    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh '(' album=god or album=rise ')' and title=miss| tee tmp.sh)
    echo "mpc search  album god title miss
    mpc search  album rise title miss" | diff -B -w - tmp.sh
    assertEquals "0" "$?"
}

test_and_nested_or_query2() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh artist=bad and '(' album=god or album=rise ')' and '(' title=miss or title=child ')' | tee tmp.sh)
    echo "mpc search  artist bad album god title miss
    mpc search  artist bad album rise title miss" | diff -B -w - tmp.sh
    assertEquals "0" "$?"
}

test_and_nested_or_query3() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh artist=bad and '(' album=god or artist=good and '(' album=devil or album=rise ')' ')' | tee tmp.sh)
    echo "mpc search  artist bad album god
    mpc search  artist bad album rise" | diff -B -w - tmp.sh
    assertEquals "0" "$?"

}

. shunit2
