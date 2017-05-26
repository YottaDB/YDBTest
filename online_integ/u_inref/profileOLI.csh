# run test on v70perf
setenv profileversion 734
# indicate profile should run an OLI during the test
setenv runOLI
# If gtmdbglvl had been set, reset it unconditionally since otherwise we will be doing malloc storage chain
# verification for EVERY malloc/free. This test involves a LOT of mallocs as part of the profile perf test.
# This would cause the test to take excessive time, e.g., over 24 hours. To avoid this situation, we turn off
# gtmdbglvl checking for this particular subtest.
unsetenv gtmdbglvl
# Temp change to get a core for beowulf "Central Memory Exhausted" error
set hostn = $HOST:r:r:r
if ("beowulf" == "$hostn") then
	setenv gtm_memory_reserve 2000 	# keep 2MB in our back pocket
	setenv gtmdbglvl 0x400		# take a core on memory exhaustion (GDL_DumpOnStackOFlow)
endif
# Even if the test is run as non-replic, gtmenv script (in profile v73.* tarball), unconditionally sets $gtm_repl_instance.
# Furthermore, if $gtm_custom_errors is set, then any update done by profilebase.csh (and the scripts it calls) will try
# to do jnlpool_init which will fail with FTOKERR/ENO2 errors due to non-existent mumps.repl file. So, unsetenv gtm_custom_errors
# if run as non-replic
if (! $?test_replic) then
	unsetenv gtm_custom_errors
endif
# call base test
$gtm_tst/profile/u_inref/profilebase.csh
