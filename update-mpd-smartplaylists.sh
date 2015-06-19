#! /bin/zsh

configFile=${1:-$HOME/.config/mpd-smartplaylists.txt}

p2xConfig=$(cat > tmp.p2xconfig <<EOF
{
 rules: [
  { re: '\\\\(', isParen: 1, closingList: [{re: '\\\\)'}] },
  { re: '\\n', name: 'nl',  mode: 'binary',  prec: 10 },
  { re: ':',   name: 'colon',  mode: 'binary',  prec: 15 },
  { re: ',',   name: 'comma',  mode: 'binary',  prec: 20 },
  { re: '\\\\|',   name: 'or',  mode: 'binary',  prec: 22 },
  { re: '&',   name: 'and',  mode: 'binary',  prec: 25 },
  { re: '=',   name: 'eq',  mode: 'binary',  prec: 27 },
  { re: '[a-zA-Z-][a-zA-Z0-9-]*',  name: 'id' },
  { re: '"[^"\\n]*"',  name: 'string' },
 ],
 treewriter: { type: 0 }
}
EOF
)
cat tmp.p2xconfig

p2xjs -c tmp.p2xconfig $configFile | tee tmp.xml

xsltproc create-smartplaylist.xsl tmp.xml | tee tmp2.xml

xsltproc genupdate-sh.xsl tmp2.xml | tee tmp.sh

bash tmp.sh
