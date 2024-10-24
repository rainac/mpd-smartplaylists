#! /bin/bash

export SMPL_HOME=$(readlink -f $(dirname $BASH_SOURCE)/..)
export SMPL_LIB=${SMPL_HOME}
export SMPL_XSL=${SMPL_HOME}
export SMPL_SCRIPTS=${SMPL_HOME}

. ${SMPL_HOME}/tests/funcs.sh

test_simple_query() {
    echo $SMPL_HOME/smartplaylist.sh -m spsh album=abc
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh album=abc | tee tmp.sh)
    echo "mpc search album abc" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}
test_simple_query_def() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh abc | tee tmp.sh)
    echo "mpc search artist abc" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_and_query() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh album=a and album=b | tee tmp.sh)
    echo "mpc search album a album b" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}
test_or_query() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh album=a or album=b | tee tmp.sh)
    echo -e "(\nmpc search album a\nmpc search album b)" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_string_query() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh album=a and album = "'a B c'" | tee tmp.sh)
    echo "mpc search album a album 'a b c'" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh

    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh album=a and album = '"a B c"' | tee tmp.sh)
    echo "mpc search album a album \"a b c\"" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_and3() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh artist=bad and album=god and title=child | tee tmp.sh)
    echo "mpc search  artist bad album god title child" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_or3() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh artist=bad or album=god or title=child | tee tmp.sh)
    echo "(
    mpc search  artist bad
    mpc search  album god
    mpc search  title child)" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_and_or1() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh artist = bad or '(' album=god or title=child ')' and title=t | tee tmp.sh)
    echo "(
    mpc search  artist bad
    mpc search  album god title t
    mpc search  title child title t)" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_and_nested_or_query() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh artist=bad and '(' album=god or album=rise ')' | tee tmp.sh)
    echo "(
    mpc search  artist bad album god
    mpc search  artist bad album rise)" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh

    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh artist=bad and '(' album=god or album=rise ')' and title=miss| tee tmp.sh)
    echo "(
    mpc search  artist bad album god title miss
    mpc search  artist bad album rise title miss)" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh

    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh '(' album=god or album=rise ')' and title=miss| tee tmp.sh)
    echo "(
    mpc search  album god title miss
    mpc search  album rise title miss)" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_and_nested_or_query2() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh artist=bad and '(' album=god or album=rise ')' and '(' title=miss or title=child ')' | tee tmp.sh)
    echo "(
    mpc search  artist bad album god title miss
    mpc search  artist bad album god title child
    mpc search  artist bad album rise title miss
    mpc search  artist bad album rise title child)" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_and_nested_or_query3() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh artist=bad and '(' album=god or artist=good and '(' album=devil or album=rise ')' ')' | tee tmp.sh)
    echo "(
    mpc search  artist bad album god
    mpc search  artist bad artist good album devil
    mpc search  artist bad artist good album rise)" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_and_nested_or_query3a() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh artist=bad and '((((' album=god or artist=good and '((((' album=devil or album=rise '))))' '))))' | tee tmp.sh)
    echo "(
    mpc search  artist bad album god
    mpc search  artist bad artist good album devil
    mpc search  artist bad artist good album rise)" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_and_nested_or_query4() {
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh artist=bad and '(' album=god or good ')' | tee tmp.sh)
    echo "(
    mpc search  artist bad album god
    mpc search  artist bad artist good)" > cmp.sh
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_playlist_def() {
    cat > cmp.sh <<EOF
mpc rm tmp-update-pls
mpc save tmp-update-pls
mpc clear
(
  (
   mpc  search  artist abc
   mpc  search  artist def
  ) | grep -i -v "t11"
  (
   mpc  search  artist ghi
   mpc  search  artist jkl
  ) | grep -i "t22"
) | mpc add
mpc rm tt
mpc save tt

mpc clear
mpc load tmp-update-pls
EOF
    cmd=$($SMPL_HOME/smartplaylist.sh -m spsh tt: '(abc or def>t11) or (ghi or jkl<t22)' | tee tmp.sh)
    cmpMultiLineShellScript tmp.sh cmp.sh
    cat tmp.sh
    syntaxCheck tmp.sh
}

test_cleanup() {
    rm -f tmp.sh cmp.sh
}

. shunit2
