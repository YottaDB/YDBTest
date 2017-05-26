# system: C9B12-001868 $SYSTEM setup does not work as advertised
echo "Entering SYSTEM_ISV subtest"
unsetenv gtm_sysid
$gtm_exe/mumps -run dsystem
setenv gtm_sysid foobar
$gtm_exe/mumps -run dsystem
unsetenv gtm_sysid
echo "Leaving SYSTEM_ISV subtest"
