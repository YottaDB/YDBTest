#!/usr/local/bin/tcsh -f
# V4 version, will not be maintained, short global names
echo "Checking database on `pwd`"
if (!($?gtm_test_dbfill)) setenv gtm_test_dbfill "IMPTP"
if ($gtm_test_dbfill == "IMPTP" || $gtm_test_dbfill == "IMPZTP") then
	$GTM << \xyz
	w "do v4checkdb",!  do ^v4checkdb
	h
\xyz
else if ($gtm_test_dbfill == "IMPRTP") then
	$GTM << \xyz
	W "Application level Verification Starts...",!
	set maxdim=+$ztrnlnm("gtm_test_maxdim")  
	if maxdim=0 set maxdim=25    
	f kk=1:1:maxdim if $get(^ndx(kk))=1 do in1^npfill("ver",1,kk)         
	W "Application level Verification Ends",!
	h
\xyz
else if ($gtm_test_dbfill == "SLOWFILL") then
	$GTM << \xyz
	do verify^slowfill
	h
\xyz
else if ($gtm_test_dbfill == "FIXTP") then
	$GTM << \xyz
	do ^chfixtp
	h
\xyz
endif
