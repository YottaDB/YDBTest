# test $ZMODE (INTERACTIVE vs OTHER (i.e. jobbed))
$GTM <<EOF
d ^D001829
h
EOF
sleep 2
# first chance:
if !(-e  D001829.mjo) sleep 10
#second chance:
if !(-z  D001829.mjo) sleep 10
cat D001829.mjo
