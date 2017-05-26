#! /usr/local/bin/tcsh -f

# Test the dse -evaluate command

echo "TEST DSE - EVALUATE COMMAND"

#create a global directory with two regions -- DEFAULT, REGX

$gtm_tst/com/dbcreate.csh mumps 2

# Set some global variables - to fill some blocks

$GTM << GTM_EOF
do ^createdb
halt
GTM_EOF

$DSE << DSE_EOF

evaluate -number=10
evaluate -number=ab
evaluate -number=AB
evaluate -number=Ab
evaluate -number=10 -hexadecimal
evaluate -hexadecimal -number=10 
evaluate -decimal -number=10 
evaluate -number="10" -hexadecimal
evaluate -number="10" -decimal
evaluate -number=AB -hexadecimal
evaluate -number=171 -decimal
evaluate
evaluate -hexadecimal
evaluate -decimal
evaluate -number=AX
evaluate -number=AX -hexadecimal
evaluate -hexadecimal -number=AX
evaluate -number=X
evaluate -number=X -hexadecimal
evaluate -hexadecimal -number=X
evaluate -number=XY
evaluate -number=XY -hexadecimal
evaluate -hexadecimal -number=XY
evaluate -number=X -decimal
evaluate -decimal -number=X
evaluate -number=XY -decimal
evaluate -decimal -number=XY
evaluate -dec -num=2147483646
evaluate -dec -num=2147483647
evaluate -hex -num=7FFFFFFF
DSE_EOF
#evaluate -dec -num=2147483649
#evaluate -hex -num=9FFFFFFF

# Verify if the above operations have done any damage to the database
$gtm_tst/com/dbcheck.csh
