#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Prepare the gld with decently sized global buffer and allocation settings for the benchmark
# We need to set a higher key and record size to avoid GVSUBOFLOW/REC2BIG errors respectively.
cat > gld.cmd << CAT_EOF
change -segment DEFAULT -file=mumps.dat
change -segment DEFAULT -allocation=50000
change -segment DEFAULT -global_buffer_count=10000
change -segment DEFAULT -lock_space=262144
change -segment DEFAULT -exten=100000
change -segment DEFAULT -mutex_slots=32768
change -region DEFAULT -record_size=1024
change -region DEFAULT -key_size=1000
CAT_EOF

# Unset any overriding YDB env vars as we want to use GT.M env vars for testing
# as this is going to test with GT.M and YottaDB builds.
unsetenv ydb_dist ydb_routines ydb_gbldir
setenv gtmgbldir mumps.gld

setenv ydb_mutex_benchmark "threeen1gE"

set maxcnt = 1

cat > avg.awk << CAT_EOF
BEGIN   {sum = 0; num = 0;}
	{sum += \$1; num ++;}
END     {printf "%f\n", sum/num;}
CAT_EOF

set nonomatch
rm -f *.gde.out *.dbcreate.out *.mupipset.out *.o threeen1gE.out
unset nonomatch

# Test with GT.M V7.1-002, YottaDB r2.02, YottaDB r2.04 and GT.M V7.1-010
set verpathlist = "/usr/local/lib/fis-gtm/V7.1-002_x86_64 /usr/library/R20{2,4}/pro /usr/local/lib/fis-gtm/V7.1-010_x86_64 "

set inputmax = "1E7"

foreach proccnt (1 2 4 8 16 32 64 128 256 512 1024 2048)
	set input = "$inputmax $proccnt"
	foreach verpath ($verpathlist)
		set gtmver = $verpath:t
		if ($gtmver == "pro") then
			set gtmver = $verpath:h:t
		endif
		setenv gtm_dist $verpath
		setenv gtmroutines ".(. $gtm_dist)"
		if (-e $gtm_dist/libgtmutil.so) then
			setenv gtmroutines "$gtmroutines $gtm_dist/libgtmutil.so"
		endif
		setenv gtmroutines "$gtmroutines $gtm_dist"
		rm -f $gtmgbldir >& /dev/null
		$gtm_dist/mumps -run GDE @gld.cmd >& $gtmver.gde.out
		rm -f mumps.dat >& /dev/null
		$gtm_dist/mupip create >& $gtmver.dbcreate.out
		# echo "# ---------------------------------------------"
		# echo "# Running threeen1gE.m $maxcnt times with input [$input] with [$gtm_dist]"
		# echo "# ---------------------------------------------"
		@ cnt = 0
		set infile = "input.txt"
		echo "$input" > $infile
		set outfile = "$gtmver.threeen1.$proccnt.out"
		rm -f $outfile >& /dev/null
		while ($cnt < $maxcnt)
			rm -f threeen1gE*.mj* *.o >& /dev/null
			$gtm_dist/mumps -run threeen1gE < $infile >>& $outfile
			dse dump -file -all >& dse_d_f_a_${gtmver}_${proccnt}_threeen1gE
			@ cnt = $cnt + 1
		end
		set outfile = $gtmver.threeen1.$proccnt.out
		sed 's/,//g;' $outfile | awk '{print $8}' | sort | awk -f avg.awk | awk '{printf "%8.3f\n", $NF}' | awk '{printf "Jobs = %s : Time taken by %s = %s seconds\n", '$proccnt', "'$gtmver'", $1}'
	end
end
