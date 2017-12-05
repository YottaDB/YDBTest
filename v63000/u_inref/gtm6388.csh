#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
# This test case shows, via strace/truss, that the number of writes performed by
# MUPIP EXTRACT have been reduced by using buffered writes. This test case also
# doubles as a perfomance test case enabled via gtm_test_gtm6388_perf. The
# performance part of the test should be run manually.
#

# Using V990 the output shows higher write counts
## Load up DB with data
##Run the extracts with strace/truss to count the number of writes (should be 1 in all cases)
##  GO:19
## ZWR:12
## BIN:18
## JNL:24

setenv gtm_test_jnl SETJNL
setenv tst_jnl_str "-journal=enable,on,nobefore"

$gtm_tst/com/dbcreate.csh mumps 1 255 1024 4096 >&! dbcreate.log

# Load data in the DB
echo "Load up DB with data"
$gtm_dist/mumps -run ^%XCMD 'set (^a,^b,^c,^d)=$tr($justify("123456",99)," ","X")'		>>& load.log
if (($?gtm_test_gtm6388_perf) && (! -f load_complete)) then
	if ( ! -e WorldVistAEHRv10FT01.zwr ) then
		$tst_gunzip -d < $gtm_test/big_files/largelibtest/WorldVistAEHRv10FT01.zwr.gz > WorldVistAEHRv10FT01.zwr
	endif
	$gtm_dist/mupip load -format=GO $gtm_test/big_files/dbload/cd.go			>>& load.log
	$gtm_dist/mupip load -format=ZWR WorldVistAEHRv10FT01.zwr				>>& load.log
	touch load_complete
endif

set extract_format_list = ( GO ZWR BIN )
if ($?gtm_chset) then
	# UTF-8 mode does not support GO extracts
	if ("UTF-8" == "$gtm_chset") then
		set extract_format_list = ( ZWR BIN )
	endif
endif
# truss/strace the processes to find out the number of system calls
echo "Run the extracts with strace/truss to count the number of writes (should be 1 in all cases)"
foreach fmt (${extract_format_list})
	rm -f extract.${fmt}
	$truss -o extract.${fmt}.trace $gtm_dist/mupip extract -format=${fmt} \
		extract.${fmt} >>& traced.${fmt}.log
	printf "%4s:" ${fmt}
	# We find out the fd from the open system call (4 in the example below)
	#	11:08:43 open("extract.ZWR", O_RDWR|O_CREAT|O_NOCTTY, 0664) = 4 <0.000017>
	# And then check for number of occurrences of the write system call using fd=4 (example output below)
	#	11:08:43 write(4, "GT.M MUPIP EXTRACT\n05-DEC-2017  "..., 465) = 465 <0.000006>
	#
	# The below awk expression achieves this. It filters out the 4 from the open command first and stores it in fd.
	# This is done by using a field separator of = and filtering out the " 4 <0.000017>" first.
	# And then removing the leading space and then the trailing timestamp (using the sub() commands).
	# On Arch Linux, the open() system call shows up as openat() in the strace output.
	# Hence the use of "open.*extract" below (to allow for open or openat).
	#
	$tst_awk -F"=" '/open.*extract/{fd = $2; sub(/^ /,"",fd); sub(" .*","",fd); fdmatch="write[^a-zA-Z0-9]"fd} $0 ~ fdmatch {if(length(fdmatch))total++} END{print total}' extract.${fmt}.trace
end

$truss -o jnl.trace $MUPIP journal -extract -noverify -detail -forward -fences=none mumps.mjl	>>& jnl_extract.log
printf " JNL:"
$tst_awk -F"=" '/open.*mumps.mjf/{fd = $2; sub(/^ /,"",fd); sub(" .*","",fd); fdmatch="write[^a-zA-Z0-9]"fd} $0 ~ fdmatch {if(length(fdmatch))total++} END{print total}' jnl.trace

if ($?gtm_test_gtm6388_perf) then
	# This is the performance section of the test
	echo "Run a timed extract"
	$gtm_dist/mupip integ -region DEFAULT							>>& integ.log
	foreach fmt (${extract_format_list})
		@ i = 10
		while (0 < $i)
			rm -f extract.${fmt}
			/usr/bin/time -p $gtm_dist/mupip extract -format=${fmt} extract.${fmt}	>>& timed.${fmt}.log
			@ i--
		end
		/bin/echo -n "${gtm_verno} ${fmt}\t"
		cat timed.${fmt}.log | $gtm_dist/mumps -run LOOP^%XCMD \
			--xec=';set:(%l?1"real".e)&($i(r)) tot=$piece(%l," ",2)+$get(tot);' \
				--after=';write ((100*(tot/r))\1)/100,!;'
	end
endif


$gtm_tst/com/dbcheck.csh									>& dbcheck.log
