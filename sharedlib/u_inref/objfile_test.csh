#!/usr/local/bin/tcsh -f
cp $gtm_tst/$tst/inref/largefile.m .
echo "Compile M file"
$gtm_exe/mumps largefile.m
if ( "HOST_LINUX_IA64" == $gtm_test_os_machtype || "HOST_LINUX_X86_64" == $gtm_test_os_machtype) then
    setenv gt_ld_m_shl_options "-shared"
endif
if ( "HOST_SUNOS_SPARC" == $gtm_test_os_machtype) then
        setenv gt_ld_m_shl_options "-G"
endif
echo "Create shared library for largefile.o"
$gt_ld_m_shl_linker $gt_ld_m_shl_options -o largefile$gt_ld_shl_suffix largefile.o >& largefile.out
if ( $HOSTOS == "OS/390" ) then
	if (!(-f largefile.dll) || !(-f largefile.x)) then
		echo "Failed to create shared library"
	endif
else 	if ( !(-f largefile$gt_ld_shl_suffix)) then
		echo "Failed to create shared library"
	endif
endif

echo "End of the test"

