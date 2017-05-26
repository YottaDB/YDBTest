#! /usr/local/bin/tcsh -f
set echo
set verbose
cd baktmp
while !( -e endloop.txt)
	echo "checking temp files"
	date
	ls -al
	ls -l BREG*
	if !( $status ) then
		chmod a-w BREG*
		ls -l *
		date
		cd -
$GTM << gtm_eof
s ^permissionchanged=1
halt
gtm_eof

		cd baktmp
		ls -l *
		date
		$psuser | $grep mupip
		ls -l *
		date
		#To debug can sleep 30 and then ls to ensure that we can see the size increasing
		# for at least the temp files corresponding to region AREG
		cd -
		unset echo
		unset verbose
		exit
	else
		echo "TEST-I-TEMPFILES, not exist at this point"
	endif
end
echo "TEST-E-TEMPFILES not found. Was not able to change permissions as desired"
cd -
unset echo
unset verbose
