# ------------------------------------------------------------------------------
# extra tests for percent routines
# ------------------------------------------------------------------------------
#-----------------------------------------------------------------------------

echo "mpt_extra test starts..."
#
if ( "TRUE" == $gtm_test_unicode_support ) then
	setenv unicode_testlist "conv_utf8 gbl_utf8 rtn_utf8 utf2hex "
else
	setenv unicode_testlist ""
endif
setenv subtest_list "date testdate conv math gbl rtn $unicode_testlist "
$gtm_tst/com/submit_subtest.csh
echo "mpt_extra test DONE."
