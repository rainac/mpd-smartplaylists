#! /bin/zsh

res=0
nl=${1:-1} # number in playlist


dir=$(dirname "$(mpc -f '%file%' playlist | head -n "$nl" | tail -n 1)")

cat > rcfile <<EOF
source ~/.local.env
cd "\$MPD_ROOT/$dir"
$SHELL -i
EOF

scp -q rcfile $MPD_HOST:
ssh -t $MPD_HOST source rcfile

ssh $MPD_HOST rm -f rcfile
rm -f rcfile

exit res
