#!/usr/local/bin/tcsh -f
#After everything is finished, clean up the temporary files
foreach file (${TMP_FILE_PREFIX}*)
	#if user wants to keep output, copy the tmp files to test output directory 
	if ($?tst_keep_output) if (-f $file) \cp $file $tst_dir/$gtm_tst_out/
	\rm -f $file >& /dev/null
end
#@@@rm -f /tmp/__${USER}_test_suite_$$_outfile  >&/dev/null

if ($?tst_no_output) then
	\rm -r $tst_dir/$gtm_tst_out/
else
	if (-w $tst_dir/$gtm_tst_out/) then
		if ("$gtm_tst_out" != "") then
		\chmod g+w $tst_dir/$gtm_tst_out/
		endif
	endif
endif
exit $1
