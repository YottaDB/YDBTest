# zdate: C9C02-001928 Provide a means of formatting 21st century as 4 digits as default
echo "Entering ZDATE_FORM subtest"
unsetenv gtm_zdate_form
$gtm_exe/mumps -run zdform
setenv gtm_zdate_form 1
$gtm_exe/mumps -run zdform
unsetenv gtm_zdate_form
echo "Leaving ZDATE_FORM subtest"
