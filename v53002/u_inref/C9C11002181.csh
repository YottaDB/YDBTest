#!/usr/local/bin/tcsh
#
# C9C11-002181 Errors should never leave GT.M in direct mode unless $ZT contains BREAK
#
unsetenv gtm_etrap # this test is testing $ZTRAP
foreach tnum (1 2 3 4 5)
	set expectpath = `which expect`
	if ($status != 0) then
		set expectpath = ""
	endif
	echo "---------------------------------------------------------------------------------------------------"
	echo "          Testing mumps -run c002181 ${tnum} through a PIPE DEVICE"
	echo "---------------------------------------------------------------------------------------------------"
	echo ""
	$gtm_dist/mumps -run c002181 ${tnum}
	echo ""
	echo "---------------------------------------------------------------------------------------------------"
	echo "          Testing mumps -run test${tnum}^c002181"
	echo "---------------------------------------------------------------------------------------------------"
	echo ""
	$gtm_dist/mumps -run test${tnum}^c002181
	echo ""
	echo "---------------------------------------------------------------------------------------------------"
	echo "          Testing do test${tnum}^c002181"
	echo "---------------------------------------------------------------------------------------------------"
	echo ""
	$GTM << GTM_EOF
		do test${tnum}^c002181
		write "\$zlevel at end = ",\$zlevel,!
		zwrite \$zstatus
GTM_EOF
	echo ""
end

# test6 begin. test6 needs special handling. test6^c002181 invokes c002181f.m. See comment at top of c002181f.m for details)

@ tnum = 6
# test6 : c002181f : Case (a)
echo "---------------------------------------------------------------------------------------------------"
echo "          Test that test${tnum}^c002181 writes to the database when it exists"
echo "---------------------------------------------------------------------------------------------------"
echo ""
$gtm_tst/com/dbcreate.csh mumps
$gtm_dist/mumps -run test${tnum}^c002181
$gtm_tst/com/dbcheck.csh
echo ""

# test6 : c002181f : Case (b)
echo "---------------------------------------------------------------------------------------------------"
echo "          Test that test${tnum}^c002181 writes to file when database does not exist"
echo "---------------------------------------------------------------------------------------------------"
echo ""
mv mumps.gld other.gld	 # rename .gld file to make database invisible
$gtm_dist/mumps -run test${tnum}^c002181
cat EP13.ERR	# should have been created
echo ""

# test6 : c002181f : Case (c)
echo "---------------------------------------------------------------------------------------------------"
echo "          Testing test${tnum}^c002181 writes to the principal device when database does not exist and file is not creatable"
echo "---------------------------------------------------------------------------------------------------"
echo ""
mv EP13.ERR EP13_b.ERR
chmod -w .	# Do not allow files to be created
$gtm_dist/mumps -run test${tnum}^c002181
chmod +w .	# Re-enable permissions on the directory
echo ""

# test6 end
