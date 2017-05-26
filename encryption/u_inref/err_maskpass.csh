#!/usr/local/bin/tcsh -f
# This test verifies whether $gtm_exe/plugin/gtmcrypt/maskpass handles the below error conditions in the user environment
#  1. $USER not set -- Required for getting the user id which will be used to mask one part of the unobfuscated password
#  2. $gtm_dist not set -- Required for getting the stat information of $gtm_dist/mumps
#  3. $gtm_dist/mumps executable doesn't exist -- Required to get the inode number of $gtm_dist/mumps executable to mask 
# 	the second part of the password
#  4 thru 7 are valid cases. Note: the combination of cases 5 thru 7 verify that the same password with a different
#	obfucscation file produces a different obfuscationed key.
#  8. Use invalid value for gtm_obfuscation_key.
#  9. Use non-existant filename as value for gtm_obfuscation_key.
# 10. Use an unreadable file as value for gtm_obfuscation_key.
# 11. Use a non-regular file as value for gtm_obfuscation_key.

# This does not need any database activity and hence no dbcreate

$echoline
echo "Current USER environment variable set to: GTM_TEST_DEBUGINFO $USER"
echo "Current gtm_dist environment variable set to: $gtm_dist"
$echoline
echo	

# Save the current USER and gtm_dist to be restored later to verify the correct case
set save_user = "$USER"
set save_gtm_dist = "$gtm_dist"

$echoline
echo "Test 1: Unset USER environment variable only. Appropriate error should be issued"
unsetenv USER
echo "SOMEPASSWORD" | $gtm_dist/plugin/gtmcrypt/maskpass
$echoline

echo	

$echoline
echo "Test 2: Unset gtm_dist environment variable only. Appropriate error should be issued"
unsetenv gtm_dist
setenv USER $save_user
echo "SOMEPASSWORD" | $save_gtm_dist/plugin/gtmcrypt/maskpass
$echoline

echo

$echoline
echo "Test 3: Set gtm_dist to a location where mumps executable is not present. Appropriate error should be issued"
setenv gtm_dist `pwd`
echo "SOMEPASSWORD" | $save_gtm_dist/plugin/gtmcrypt/maskpass
$echoline

echo 

$echoline
echo "Test 4: Constructive Testing. Everything is fine in the user environment. Maskpass should just work"
setenv gtm_dist "$save_gtm_dist"
echo "SOMEPASSWORD" | $save_gtm_dist/plugin/gtmcrypt/maskpass > obuserinode_pass.txt
# Note: the obfuscated value is based upon the userid and inode of the mumps executable (so it will change
# for different users and different mumps executables (including pro vs dbg)) so no need to put it in the output). 
$echoline

$echoline
echo "Test 5: Constructive Testing. gtm_obfuscation key points to a file with readable contents. Maskpass should just work"
echo "My kingdom for a horse!" > ob_key.txt
setenv gtm_obfuscation_key "ob_key.txt"
echo "SOMEPASSWORD" | $save_gtm_dist/plugin/gtmcrypt/maskpass > obfile_pass.txt ; cat obfile_pass.txt
# Note: with gtm_obfuscation_key if the password is the same and the contents of the file is the same the obfuscated
# key will be the same so put it in the output stream. 
$echoline

$echoline
echo "Test 6: Constructive Testing. gtm_obfuscation key points to a file with readable contents. Maskpass should just work"
setenv gtm_obfuscation_key "$gtm_test/big_files/dbload/tape5.dat" # 29K file
echo "SOMEPASSWORD" | $save_gtm_dist/plugin/gtmcrypt/maskpass
# Note: with gtm_obfuscation_key if the password is the same and the contents of the file is the same the obfuscated
# key will be the same so put it in the output stream.
$echoline

$echoline
echo "Test 7: Constructive Testing. gtm_obfuscation key points to a file with readable contents. Maskpass should just work"
setenv gtm_obfuscation_key "$gtm_test/big_files/dbload/tape1.dat" #1M file
echo "SOMEPASSWORD" | $save_gtm_dist/plugin/gtmcrypt/maskpass
# Note: with gtm_obfuscation_key if the password is the same and the contents of the file is the same the obfuscated
# key will be the same so put it in the output stream.
$echoline

$echoline
echo "Test 8: Use invalid value for gtm_obfuscation_key. Maskpass should fall back to using USER and inode"
setenv gtm_obfuscation_key "My kingdom for a horse!" 
echo "SOMEPASSWORD" | $save_gtm_dist/plugin/gtmcrypt/maskpass > try1.txt
if ( `diff obuserinode_pass.txt try1.txt` ) then
	echo FAIL
else	
	echo PASS
endif
$echoline

$echoline
echo "Test 9: Use non-existant filename as value for gtm_obfuscation_key. Maskpass should fall back to using USER and inode"
setenv gtm_obfuscation_key "nonexistant.txt" 
echo "SOMEPASSWORD" | $save_gtm_dist/plugin/gtmcrypt/maskpass > try2.txt
if ( `diff obuserinode_pass.txt try2.txt` ) then
	echo FAIL
else	
	echo PASS
endif
$echoline

$echoline
echo "Test 10: Use an unreadable file as value for gtm_obfuscation_key. Maskpass should fall back to using USER and inode"
echo "You cannot see this" > unreadable.txt
chmod a-r unreadable.txt
setenv gtm_obfuscation_key "unreadable.txt" 
echo "SOMEPASSWORD" | $save_gtm_dist/plugin/gtmcrypt/maskpass > try3.txt
if ( `diff obuserinode_pass.txt try3.txt` ) then
	echo FAIL
else	
	echo PASS
endif
$echoline

$echoline
echo "Test 11: Use a non-regular file as value for gtm_obfuscation_key. Maskpass should fall back to using USER and inode"
setenv gtm_obfuscation_key "$PWD" 
echo "SOMEPASSWORD" | $save_gtm_dist/plugin/gtmcrypt/maskpass > try4.txt
if ( `diff obuserinode_pass.txt try4.txt` ) then
	echo FAIL
else	
	echo PASS
endif
$echoline

echo "Test Ends"
