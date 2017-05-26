#!/usr/local/bin/tcsh -f

###############################################################################################
# This script is used as a part of spanning_nodes/sn_jnl1 test to write a random              #
# one-character global and do a dbcheck.                                                      #
###############################################################################################

# This is needed to prevent REC2BIG with maximum record size of 0
@ l = 1 
if ($1 != "")
	@ l = $1
endif

# Write a simple update with a random global
$gtm_exe/mumps -direct << EOF
set l=$l
set i=\$random(26)
if l>0 set j=\$random(10)
else  set j=""
write "Saving ^"_\$char(97+i)_"="_j,!
set @("^"_\$char(97+i))=j
EOF

# Do a database check
$gtm_tst/com/dbcheck.csh	# dbcreate.csh is called from the main script
echo
