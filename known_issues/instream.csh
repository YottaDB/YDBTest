# Any subtest in this test must be an issue we know about, but hasn't been fixed yet. If a subtest passes, it should be moved to
# another test. There are currently no known issues with GT.M!

echo "known_issues test starts..."
setenv subtest_list_nonreplic ""
setenv subtest_list_replic ""
if ($?test_replic) then
	setenv subtest_list "$subtest_list_replic"
	exit # since there are no replication tests now.
else
	setenv subtest_list "$subtest_list_nonreplic"
endif
$gtm_tst/com/submit_subtest.csh
echo "known_issues test DONE."
