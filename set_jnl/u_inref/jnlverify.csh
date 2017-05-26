#!/usr/local/bin/tcsh -f
ls -l >& jnlverify_pre_ls.outx
$lsof  >& jnlverify_pre_lsof.outx
foreach file (*.mjl*)
#	\rm -f mumps.extr
#	$MUPIP journal -verify -extract=mumps.extr -forward  $file 
	echo "------------------------------------------------------------------------------------"
	echo "Verifying journal file : $file"
	echo ""
	$MUPIP journal -verify -forward  $file 
	if ($status) then
		echo "$file verification failed"
		ls -l >& jnlverify_post_ls.outx
		$lsof  >& jnlverify_post_lsof.outx
		exit 1
	endif
end
