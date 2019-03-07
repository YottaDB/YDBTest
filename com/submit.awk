#################################################################
#								#
# Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
BEGIN {
	print "#####################################"
	print "umask 002"
	print "set stat = 0"
	print "set short_host = $HOST:r:r:r:r"
	print "if ($?test_no_background) echo The rough results:"
	print "if ($?test_no_background) echo If there are other errors after the end of the test, these results might be wrong."
	gtm_tst_out = ENVIRON["gtm_tst_out"]
      }
$1 !~ /#/ {testname = $2 "_" $1
 print "unsetenv test_replic"
 print "unsetenv test_gtm_gtcm_one"
 print "setenv tst "  $2
 print "setenv testname " testname
 print "setenv tst_general_dir $tst_dir/" gtm_tst_out "/" testname
 print "setenv tst_working_dir $tst_dir/" gtm_tst_out "/" testname "/tmp"
 print "if ($?test_distributed) then"
 print "	set controlfile = ${test_distributed}.picked"
 print "	set whopicked = `$test_distributed_srvr \"$gtm_tst/com/distributed_test_pick.csh picktest $testname $controlfile $short_host $gtm_tst\"`"
 print "	if (\"$short_host\" != \"$whopicked\") then"
 print "		$gtm_tst/com/write_logs.csh NOTRUN_${test_distributed:t}_${whopicked}"
 print "		set teststat = $status"
 print "		goto end_"testname
 print "	endif"
 print "endif"
 print "setenv tst_num " tst_num++
# The below will be able to check only primary test output directory.
# check_space.csh relies on cleanup.csh for various locations (replic, multi-host etc) but cleanup.csh wouldn't be created at this point in time
# It's a preventive measure to exit from continuing further if primary output area is full (say /testarea1)
 print "$gtm_tst/com/check_space.csh submit >&! ${TMP_FILE_PREFIX}_call_check_space.out"
 print "if ($status) then"
 print "   echo `date` TEST-E-SPACE, will not run anymore tests due to lack of space in primary testarea"
 print "   exit 50"
 print "endif"
 # -p enables that two directories are created at the same time, test and test/tmp
 if ("HOST_HP-UX_IA64" == osmachtype)
 {
	 print "$mkdir $tst_general_dir"
	 print "$mkdir $tst_working_dir"
 } else  print "\\mkdir -p $tst_working_dir"
 print "\\chmod g+w $tst_working_dir"
 print "cd $tst_working_dir"
 replic=0
 gtcm=0
 unnice=0
 # Using 'nice' on z/OS requires onerous setup on the mainframe side of the z/OS world, skip it.
 if ("OS/390" == ENVIRON["HOSTOS"]) unnice=1
 for (i=3; i<=NF; i++)
   { option=process($i,"correct")
     printf "setenv "
     printf process(option,"option_name") " "
     print option
     if (option ~ /^REPL/)	replic=1	#plain vanilla replication
     if (option ~ /^MULTISITE/)	replic=2	#multisite replication
     if (option ~ /^GT[^C]?CM/)	gtcm=1
     if (option ~ /^UNNI/)	unnice=1
    }

 if (replic)
  { print "setenv test_replic 1"
    if (2 == replic) print "setenv test_replic MULTISITE"
  }
 if (gtcm)
     print "setenv test_gtm_gtcm_one"

 if (!unnice) printf "nice +" ENVIRON["gtm_test_nice_level"]
 if (ENVIRON["tst_stdout"]==1)
    printf " $tst_tcsh $gtm_tst/com/submit_test.csh |& tee $tst_general_dir/$tst.log"
 else
    printf " $tst_tcsh $gtm_tst/com/submit_test.csh >& $tst_general_dir/$tst.log"
 if (ENVIRON["test_want_concurrency"]=="yes") printf " &"
 printf "\n"
 print "set teststat = $status"
 print "# It is possible the test got kill -9ed (by gtm_test_watchdog.csh due to a TIMEDOUT alert)."
 print "# In that case, the exit status would be 128 + 9 (kill -9) = 137. Handle that specially."
 print "if ((137 == $teststat) && $?test_distributed) then"
 print "	set donefile = ${test_distributed}.done"
 print "	# Note down in the file that this test is done"
 print "	$test_distributed_srvr \"$gtm_tst/com/distributed_test_pick.csh donetest $testname $short_host FAILED $donefile $gtm_tst\""
 print "endif"
 print "end_"testname":"
 print "if ($teststat != 0 ) set stat = $teststat"
 print "if ($?test_no_background) then"
 print "  set res=PASSED"
 print "  if ($teststat != 0 ) set res=FAILED"
 print "  echo `date` $res $tst"
 print "endif"
 print "cd $tst_dir/" gtm_tst_out
}
