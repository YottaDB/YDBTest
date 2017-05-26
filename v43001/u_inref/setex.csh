#! /usr/local/bin/tcsh

$GTM << EOF
w "begin of SET \$EXTRACT testing...",!
s foo=1,bar=2,baz=3,\$e(foo,bar,baz)=4 w foo,!   ;should output 14
s foo=1,bar=2,baz=3,\$e(foo,bar,0)=4 w foo,!     ;foo remains 1
s foo=1,bar=2,baz=3,\$e(foo,bar,1)=4 w foo,!     ;foo remains 1
s foo=1,bar=2,baz=3,\$e(foo,bar,3)=4 w foo,!     ;foo becomes 14
s foo=1,bar=2,baz=3,\$e(foo,bar,1+2)=4 w foo,!   ;foo becomes 14
w "...end of SET \$EXTRACT",!
h
EOF
