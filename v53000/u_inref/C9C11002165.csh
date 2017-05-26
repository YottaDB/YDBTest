#!/usr/local/bin/tcsh -f
#
# C9C11-002165 Test case for creating object file with truncation

@ size0=0
@ size1=0

# copy m code to test area
cp $gtm_tst/$tst/inref/c002165_0.m c002165_0.m
cp $gtm_tst/$tst/inref/c002165_1.m c002165_1.m
cp c002165_0.m c002165.m

# Use relative path for the compiles.  If there happens to be a file named c002165.m 
# in the $gtm_tst/$tst/inref directory, it will be used instead.
$gtm_dist/mumps ./c002165.m
if ( -e c002165.o ) then
	@ size0=`ls -l c002165.o |& $tst_awk '{print $5}'`
	echo "Object file size for c002165_0.m: "$size0
	cp c002165.o c002165_0.o
endif

# Replace c002165.m with the shorter c002165_1.m
cp c002165_1.m c002165.m

# The recompile is only done if the modification time of the object file is older than 
# that of the M code.  The resolution of the modification time (time_t) is in seconds,
# so we have to wait at least one second before setting the time on c002165.m.  Otherwise, 
# the recompile might not happen.
sleep 1
touch c002165.m
$gtm_dist/mumps ./c002165.m
if ( -e c002165.o ) then
	@ size1=`ls -l c002165.o |& $tst_awk '{print $5}'`
	echo "Object file size for c002165_1.m: "$size1
	cp c002165.o c002165_1.o
endif

if ( $size1 >= $size0 ) then
	echo "FAILURE - object file size didn't decrease for smaller source file"
else
	echo "SUCCESS - object file size decreased for smaller source file"
endif

