#!/usr/local/bin/tcsh -f
set run_reorg_upgrd_dwngrd
if ( "ENCRYPT" == $test_encryption ) then
        echo "TEST-I-ENCRYPT, Online upgrade-downgrade cannot be run since MUPIP SET version=V4 not supported with encryption"
	exit
endif
if (! $?gtm_test_disable_randomdbtn) then
	#cannot downgrade if the TN is too large, so makes no sense to try to upgrade, either
	# Check the gtm_test_dbcreate_initial_tn value in settings.csh
	if (-e settings.csh) then
		$grep gtm_test_dbcreate_initial_tn settings.csh >&! tmp.csh
		source tmp.csh
		\rm tmp.csh
	else
		echo "BKGRND_REORG_UPGRD_DWNGRD-E-SETTINGS.CSH is not found"
	endif
	if ($?gtm_test_dbcreate_initial_tn) then
		if (32 > $gtm_test_dbcreate_initial_tn) then
			set run_reorg_upgrd_dwngrd
		else
			echo "TEST-I-LARGETN, too large a starting TN, cannot downgrade, so makes no sense to run upgrade either"
			unset run_reorg_upgrd_dwngrd
		endif
	else
		echo "TEST-E-SKIP. gtm_test_dbcreate_initial_tn is not known. So will skip online_reorg_upgrd_dwngrd"
		exit
	endif
endif

if ($?run_reorg_upgrd_dwngrd) $gtm_tst/com/online_reorg_upgrd_dwngrd.csh >& online_reorg_upgrd_dwngrd.log &
