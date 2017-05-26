# This script overrides the MM access method.  This should be sourced
# in those tests/subtests that require BG access method to run
# properly.  Such tests should have the following line at the
# beginning of instream.csh or <subtest>.csh driver script.
#
# source $gtm_tst/com/gtm_test_setbbgaccess.csh
#
# The preference is to have this in specific subtests. But if all subtests of a given test need to have this, it
# might be easy maintenance to place this in the top of the test's instream.csh
#
# Those tests that will run fine with either setting (MM or BG) should NOT source this script as it will
# otherwise cause them to run only with BG which reduces the test/code coverage.
#
if ("MM" == $acc_meth) then
	setenv acc_meth "BG"
#
#	The value of acc_meth has changed, so let's log the modified acc_meth in settings.csh
	echo "# acc_meth is modified by gtm_test_setbgaccess.csh"	>> settings.csh
	echo "setenv acc_meth $acc_meth"				>> settings.csh
endif
