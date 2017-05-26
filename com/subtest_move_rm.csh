# this is a separate file because of the *, and the way GT.CM is handled
if ("rm" == $1) then
	# do the directory check first because a normal rm is faster for xargs
	$gtm_tst/com/chkPWDnoHome.csh
	if ($status == 6) then
		echo "TEST-E-RM Not removing files. $PWD is a home directory"
		exit 6
	endif
	\ls | xargs \rm -rf >& /dev/null
else if ("mv" == $1) then
	\mkdir ../$2;
	ls | xargs -i mv {} ../$2/
# the -f is needed to avoid errors from symbolic links owned by other users e.g., in Profile test
# unfortunately -f is not supported on HP-UX so we suppress the output
	if ("HP-UX" == "$HOSTOS") then
		\chmod -R g+w ../$2 >& /dev/null
	else
		\chmod -Rf g+w ../$2 
	endif
endif
