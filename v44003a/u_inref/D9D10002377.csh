#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2003, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
# D9D10-002377 The CLI parameter values are not reliable when read from CLI prompts
#
# the original problem was the parameter read from the File prompt was not
# being null-terminated at the proper position. this caused MUPIP UPGRADE to
# fail with an "ftok error".
#
# to test this, we create
#

$gtm_tst/com/dbcreate.csh .

mv mumps.dat mumps.tbls
set filename="mumps.tbls"

@ num = 1
while ($num < 64)
        set new_filename = "$filename:ra.$filename:e"
        mv $filename ${new_filename}
        set filename = "$new_filename"
        echo "$filename" >! mupip.input
        echo "y" >>! mupip.input
        echo "y" >>! mupip.input
        echo "--> Doing mupip upgrade on $filename --"
        $gtm_exe/mupip upgrade < mupip.input >&! mupip.tmp.out
	# we expect only "already upgraded" error here. Sometimes we get MUSTANDALONE issue
	# the condition below is to catch those cases and see who clings on to the database.
	if ( `$grep "MUST" mupip.tmp.out|wc -l` ) then
		echo "TEST-E-unexpected upgrade error"
		$ps >>& pslist.outx
		$gtm_tst/com/ipcs -a >>& ipcslist.outx
		$gtm_exe/ftok $filename
		echo "Note: This failures might be related to the TR C9G06-002797."
		echo "Please check the resolution note <C9G06_002797_ftokcollision>"
	endif
	cat mupip.tmp.out
	@ num = $num + 1
end
\rm mupip.tmp.out
ls -1 *.tbls

mv *.tbls mumps.dat

$gtm_tst/com/dbcheck.csh
