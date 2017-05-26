#!/usr/local/bin/tcsh -f

#create a global directory with two regions -- DEFAULT, AREG

$gtm_tst/com/dbcreate.csh mumps 2

# Set some global variables - to fill some blocks

$GTM << GTM_EOF
do ^createdb
halt
GTM_EOF

# To test dse -crit command

echo "TEST DSE - CRIT COMMAND"

# Test crit without any argument
# default argument, -owner
# check the owner of crit

$DSE << DSE_EOF

crit
crit -owner

DSE_EOF

# Test crit -init
# seize the critical section, check the owner
# switch to DEFAULT
# try reinitialising the critical section for AREG
# switch back to AREG
# check if crit is reinitialised, 
# reinitialise the crit, and check it

$DSE << DSE_EOF

crit -init
crit -seize
crit
find -reg=DEFAULT
crit -init
find -reg=AREG
crit
crit -init
crit

DSE_EOF

# Test crit -release
# seize the critical section, check the owner
# spawn a new DSE process
# Try releasing crit section from this process
# crit owner should still exist, check from the owner process
# release the crit, check it

cat >! dse_ip  << CAT_EOF

crit 
crit -rele
q

CAT_EOF

$DSE << DSE_EOF

crit -seize
crit
spawn "$DSE < dse_ip"
crit
crit -rele
crit

DSE_EOF

# Test crit -init 

$DSE << DSE_EOF

crit -seize
crit
crit -init
crit

DSE_EOF

# Test crit -remove

$DSE << DSE_EOF

crit -seize
crit
crit -rem
crit

DSE_EOF

# Test dse change with freeze qualifier
# freeze, check, unfreeze and check again

$DSE << DSE_EOF >>& crit_freeze.log
change -fileheader -freeze=TRUE
dump -fi
change -fileheader -freeze=FALSE
dump -fi
DSE_EOF

echo -n
grep "Cache freeze" crit_freeze.log
grep "Freeze image count" crit_freeze.log
$gtm_tst/com/dbcheck.csh
