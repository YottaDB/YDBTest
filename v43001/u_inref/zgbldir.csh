#C9612-000150 
echo "Entering ZGBLDIR subtest"
#
# not using dbcreate.csh because of complicated GLD setup.
setenv gtmgbldir mumps.gld
$GTM <<xyz
s \$zgbldir="ddd.gld"
s \$zgbldir=abc
s \$zgbldir=""
w \$zgbldir
xyz
#
unsetenv gtmgbldir 
$GTM <<xyz
w \$zgbldir
s \$zgbldir="ddd.gld"
s \$zgbldir=""
w \$zgbldir
xyz

setenv gtmgbldir "a.gld"
$GDE <<xyz
add -name a* -region=areg
add -name A* -region=areg
add -region areg -dyn=aseg
add -segment aseg -file=a.dat
xyz
if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif

$MUPIP create
#
setenv gtmgbldir "b.gld"
$GDE <<xyz
add -name b* -region=breg
add -name B* -region=breg
add -region breg -dyn=bseg
add -segment bseg -file=b.dat
xyz
\rm mumps.dat
if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_test/$tst_src/com/create_key_file.csh >& create_key_file_dbload.out
endif
$MUPIP create
#
$GTM <<xyz
d ^zgbltest
xyz
$gtm_tst/com/dbcheck.csh 
echo "Leaving ZGBLDIR subtest"
