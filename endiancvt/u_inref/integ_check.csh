#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#!/usr/local/bin/tcsh -f

####
## this tool runs an integ check for each of the databases passed (as arguments)
## USAGE: integ_check.csh <list of databasefiles>
## e.g : integ_check.csh a.dat mumps.dat
####

# Setup collation if required
if (-e coll_env.csh) then
	source coll_env.csh 1
endif

set ts = `date +%H_%M_%S`
foreach file ($argv)
	set output = "integ_check_${file}_${ts}_$$.out"
        $MUPIP integ $file >&! $output
        if($status) then
                echo "TEST-E-INTEG. Integ check failed for $file. Check $output"
        else
                echo "TEST-I-INTEG check of $file passed"
        endif
end
