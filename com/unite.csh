#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
if ( $#argv == 0 ) then
   echo "USAGE:"
   echo "execute this file as "
   echo "unite.csh <name of test>  <sub_test_list>"
   echo "you must be in the directory which has the file submitted_tests (which includes the options for each test run) and the directories of test output"
   echo "inref.csh will be executed for each test run to get individual reference files and will be brought together."
   echo "the sub_test output files must be in their own directories, i.e. <testname>/<sub_test>/<sub_test>.log"
   echo "If sub_test_list is not specified only outstream.log will be processed"
   echo ""
   echo "So run the test with keep (-k) option and also use a different gtm version or image for remote host (if test has replication) so the reference file will have ##SOURCE_PATH## and ##REMOTE_SOURCE_PATH## correct."
   echo ""
   echo "Run all options of the test which might give a different output (with a single command), so the directory structure will be appropriate"
   echo ""
   echo "If the directory structure is not like described, run inref.csh on each to take care of the paths and then rename the reference files so each has testname_x in its name (so it will be matched with its options from submitted_tests)."
   echo "Prepare submitted_tests file which contains the proper options for each run of the test. Then use awk ( -f com/process.awk -f com/unite.awk submitted_tests <the reference files to be brought together>)"
   echo ""
   exit
endif

# Set "gtm_test_com_individual" (an env var required by this script) to the path of the unite.csh script
# that was used in this current invocation.
setenv gtm_test_com_individual $0:h

source $gtm_test_com_individual/set_specific.csh
set x=1
setenv test_list ""
foreach argu ($argv)
	if ( $x > 1) setenv test_list "$test_list $argu"
	@ x = $x + 1
end
#if ("$test_list" == "")
set test_list = "$test_list outstream"
echo "First correcting each test run using inref.csh"
foreach base ($test_list)
   unset found
   set ref_files = ""
   set test_name = `grep " $1 " submitted_tests|$tst_awk '{print $2"_"$1}'`
   if ("$test_name" == "") then
       echo "ERROR: Could not find test"
       exit 1
   endif
   echo ""
   foreach i ($test_name)
      if ( "outstream" == "$base" ) then
		set outfile = $base
		setenv subtest tmp	# This is not a subtest
	else
		set outfile = $base/$base
		setenv subtest $base	# this is a subtest
	endif
   if (-e $i/${outfile}.log) then
      # The file is there
      set found
      set ref = $i"/"$outfile
      set ref_files = "$ref_files ${ref}.txt"
      cd $i
      echo "Correcting log file for $base in $i..."
      $gtm_test_com_individual/inref.csh $outfile
      if ((! -f $base/${base}.txt)&&(! -f ${base}.txt)) then
	echo "UNITE-E-INREF ${ref}.txt not created!"
      endif
      cd ..
     else
      echo "$i/${outfile}.log not found"
     endif
   end
   echo ""
   if (! $?found) then
      echo "ERROR: $base NOT FOUND"
      echo ""
   else
       echo "Now bringing together $ref_files"

       set a_file_is_there=0
       foreach file ($ref_files)
	if (-f $file) set a_file_is_there=1
       end
       if !($a_file_is_there) then
	echo "UNITE-E-FILENOTFOUND None of the files ($ref_files) are found. Cannot unite."
	echo "Exiting"
	exit 1
       endif
       $tst_awk -f $gtm_test_com_individual/unite.awk -f $gtm_test_com_individual/process.awk submitted_tests $ref_files >! `basename $base`.txt
       echo "`basename $base`.txt is the united file"
       echo "--> Check for unmasked variables (like timestamp, pids, prior version paths etc), check for proper SUSPEND/ALLOW flags if applicable"
       echo "--> Then copy the file or merge it with the existing reference file"
   endif
end
