#!/usr/local/bin/tcsh
echo "------------" >>! check_jnlpool.log
set expected = $1	# whether we expect it to exist or not 1 exists, 0 does not exist
echo "Expected: $expected" >> check_jnlpool.log
set error = "TEST-E-JNLPOOL"
set errorstat = "1"
if ($expected) then
	set error_exist = ""
	set error_noexist = $error
else
	set error_exist = $error
	set error_noexist = ""
endif
set jnlpool_ftok = `$gtm_tst/com/jnlpool_ftok.csh | sed 's/-s//g;s/-m//g;s/^ [ ]*//;s/ [ ]*/|/g'`
echo "jnlpool_ftok is: $jnlpool_ftok" >>&! check_jnlpool.log
echo $jnlpool_ftok | $grep "1|-1" >& /dev/null
if (! $status) then
	echo "mupip ftok -jnlpool returned -1, so no need to check" >>&! check_jnlpool.log
	set jnlpoolstat = -1
else
	$gtm_tst/com/ipcs -a | $grep $USER >>&! check_jnlpool.log
	$gtm_tst/com/ipcs -a | $grep $USER | $grep -E $jnlpool_ftok >& /dev/null
	set jnlpoolstat = $status
endif
if (! $jnlpoolstat) then
	echo $error_exist "JNLPOOL exists."
else
	echo $error_noexist "JNLPOOL does not exist"
endif
exit ($expected == $jnlpoolstat)
