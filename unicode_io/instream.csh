#!/usr/local/bin/tcsh -f
echo "Unicode I/O test starts..."
if ( "TRUE" == $gtm_test_unicode_support ) then
	setenv subtest_list "basic_io_encoding simple_io_encoding unicode_readonly"
	setenv subtest_list "$subtest_list unicode_delete unicode_length bomtest eoftest"
	if ( $HOSTOS == "OS/390" ) then
		setenv subtest_list "$subtest_list zunicode_fifo"
	else
		setenv subtest_list "$subtest_list unicode_fifo"
	endif
	setenv subtest_list "$subtest_list unicode_null unicode_socket"
	setenv subtest_list "$subtest_list unicode_rewind unicode_xy unicode_recwid"
	setenv subtest_list "$subtest_list unicode_fixedlen fixed varstr unicode_truncate"
endif
# filter out some subtests for some servers
set hostn = $HOST:r:r:r
# Disable subtest on platforms that don't support unicode 5.0 (4 byte unicode chars)
if ("1" == "$gtm_platform_no_4byte_utf8") then
	setenv subtest_exclude_list "basic_io_encoding"
endif

$gtm_tst/com/submit_subtest.csh
echo "Unicode I/O test done..."
