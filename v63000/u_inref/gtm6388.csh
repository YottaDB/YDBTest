#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
	$tst_awk -F"=" '/open..extract/{$2=+$2;fdmatch="write[^a-zA-Z0-9]"$2} $0 ~ fdmatch {if(length(fdmatch))total++} END{print total}' \
		extract.${fmt}.trace
end

$truss -o jnl.trace $MUPIP journal -extract -noverify -detail -forward -fences=none mumps.mjl	>>& jnl_extract.log
printf " JNL:"
$tst_awk -F"=" '/open.*mumps.mjf/{$2=+$2;fdmatch="write[^a-zA-Z0-9]"$2} $0 ~ fdmatch {if(length(fdmatch))total++} END{print total}' jnl.trace

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
