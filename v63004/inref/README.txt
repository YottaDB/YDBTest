This is a dummy file that is needed in "inref" directory of every new test (until we have at least one
other file in this directory) to avoid test failures due to ZROSYNTAX errors because the test framework
always assumes $gtm_tst/$tst/inref exists when it sets up ydb_routines/gtmroutines env var for the test.
