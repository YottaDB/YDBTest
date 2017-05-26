#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#create a global directory with two regions -- DEFAULT, REGX

$gtm_tst/com/dbcreate.csh mumps 2

# Set some global variables - to fill some blocks

$GTM << GTM_EOF
do ^createdb
halt
GTM_EOF

# Test the dse -all command

echo "TEST DSE - ALL COMMAND"

# To test ALL -CRITINIT
# seize the crit section in region AREG, check it
# switch to the region DEFAULT
# seize the crit section for this region also
# initialise critical sections of all regions
# check in both the regions

if (0 == $?test_replic) then
$DSE << DSE_EOF

critical -seize
crit
find -reg=DEFAULT
crit -seize
crit
all -critinit
crit
find -reg=AREG
crit

DSE_EOF
endif

# To test ALL -FREEZE
# freeze all the regions from AREG region, check this
# change the region to DEFAULT, unfreeze all the regions here
# check this from both the regions

$DSE << DSE_EOF >>& freeze.log

all -freeze
dump -fi
find -reg=DEFAULT
dump -fi
all -nofreeze
dump -fi
find -reg=AREG
dump -fi

DSE_EOF

echo -n
$grep "Freeze image count" freeze.log
$grep "Cache freeze" freeze.log

# To test ALL -OVERRIDE
# freeze all the regions from AREG region, check this
# spawn a new DSE process and try unfreezing it without 'override'ing it
# unfreeze all the regions by 'override'ing
# check this

cat >! dse_ip << CAT_EOF

dump -fi
all -nofreeze
dump -fi
all -override -nofreeze
dump -fi
q

CAT_EOF

$DSE << DSE_EOF >>& override.log

all -freeze
dump -fi
spawn "$DSE < dse_ip"
dump -fi

DSE_EOF

echo -n
$grep "Freeze image count" override.log
$grep "Cache freeze" override.log

# To test ALL -OVERRIDE FREEZE
# freeze all the regions in DSE
# spawn another process and try unfreezing it without 'override'ing
# now associate the freeze with the spawned DSE by ALL -OVERRIDE FREEZE
# this should allow unfreezing without 'override'ing it

cat >! dse_ip << CAT_EOF

dump -fi
all -nofreeze
dump -fi
all -override -freeze
all -nofreeze
dump -fi
q

CAT_EOF

$DSE << DSE_EOF >>& override1.log

all -freeze
spawn "$DSE < dse_ip"
dump -fi

DSE_EOF

echo -n
$grep -E "Freeze image count|Cache freeze"  override1.log

# To test ALL -REFERENCE
# Change the reference count in both the regions
# reset the reference count from the region DEFAULT, dump it and check

$DSE << DSE_EOF >>& refer.log

change -fi -ref=20
dump -fi
find -reg=DEFAULT
change -fi -ref=30
dump -fi
all -ref
dump -fi
find -reg=AREG
dump -fi

DSE_EOF

echo -n
$grep "Reference count" refer.log

# To test ALL -RENEW
# freeze all the regions, seize the critical section and
#   change the freeze count
# all -renew should bring all of them back to default

if (0 == $?test_replic) then
$DSE << DSE_EOF >>& renew.log

all -freeze
crit -seize
change -fi -ref=32
dump -fi
all -renew
y
dump -fi

DSE_EOF
echo -n
$grep -E "In critical section|Cache freeze|Freeze image count|Reference count" renew.log

# To test ALL -SEIZE
# seize all the regions, check it
# then, initialise critical sections for all the regions

$DSE << DSE_EOF >>& seize.log

all -seize
dump -fi
find -reg=DEFAULT
dump -fi
all -crit
dump -fi

DSE_EOF

echo -n
$grep "In critical section" seize.log
endif

# To test ALL -RELEASE

$DSE << DSE_EOF

all -seize
crit
all -rel
crit

DSE_EOF

# To test ALL -RELEASE
# try releasing the critical sections from a spawned process
# check for the owner
# release crit from the owner process

cat >! dse_ip << CAT_EOF

crit
all -release
crit
q

CAT_EOF

$DSE << DSE_EOF >>& release.log

all -seize
crit
spawn "$DSE < dse_ip"
all -rel
crit

DSE_EOF

echo -n
$grep "In critical section" release.log

# Verify if the above operations have done any damage to the database
$gtm_tst/com/dbcheck.csh

echo "# GTM-7199 : Provide a DSE way to clear the CORRUPT FLAG in all regions with a single command."
$gtm_tst/com/dbcreate.csh mumps 5
$gtm_exe/mumps -run createdb

if (1 == $?test_replic) then
	# Ensure the journal files are open before setting the corrupted flags. If the journal files are not open before the
	# file_corrupt flag is set, then the source server causes DBFLCORRP. We don't want that so we ensure the journal files are
	# open by making sure at least one update is sent from source to server.
	setenv start_time `cat start_time`
	$sec_shell '$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log RCVR_'${start_time}'.log.updproc -message "New History Content" -duration 120'
endif

echo "# Checking database file corrupt status"
$gtm_exe/mumps -run %XCMD 'do checkcorruptall^clearcorrupt'

echo "# Corrupting database for AREG,BREG and CREG"
$DSE << DSE_EOF
CHANGE -FILEHEADER -CORRUPT_FILE=TRUE
find -region=BREG
CHANGE -FILEHEADER -CORRUPT_FILE=TRUE
find -region=CREG
CHANGE -FILEHEADER -CORRUPT_FILE=TRUE
DSE_EOF

echo "# Checking database file corrupt status"
$gtm_exe/mumps -run %XCMD 'do checkcorruptall^clearcorrupt'

echo "# Clearing corrupt flag for all regions using clearcorrupt"
$DSE ALL -CLEARCORRUPT

echo "# Checking database file corrupt status"
$gtm_exe/mumps -run %XCMD 'do checkcorruptall^clearcorrupt'

# Verify if the above operations have done any damage to the database
$gtm_tst/com/dbcheck.csh
