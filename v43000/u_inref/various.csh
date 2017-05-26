# Various new tests
/bin/echo "Beginning 'various' tests"
$gtm_tst/com/dbcreate.csh .
$GTM <<EOF
d ^c6010103
d ^maxindr1
d ^testack
d ^trterr
d ^tstidev
d ^tstread
d ^setdole
d ^tstsfex
h
EOF

# Stack overflow test needs its own invocation. Regular checking
# will determine if this test passed (did not core).
$GTM <<EOF
d ^tstoflow
EOF

/bin/echo "'various' tests complete"
# Move the GTM_FATAL_ERROR.* files, so that error catching mechanism do not show invalid failures
foreach file ( `ls -l GTM_FATAL_ERROR* | $tst_awk '{print $NF}'` )
	mv $file `echo $file | $tst_awk -F 'GTM_' '{print $2}'`
end
$gtm_tst/com/dbcheck.csh
