#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Called for multi-machine tests only
#
# if running in UTF-8 locale, punctuation marks get displayed as their octal equivalents due to some tcsh bug
# to work around this until tcsh is fixed, we transform such an output to what it should normally be.
# gtm_icu_version is host specific (depending on the ICU version installed). It is dynamically obtained at shell startup.
# So remove it from the environment variable sending list
if ($HOSTOS == "SunOS") then
	setenv | $grep -E "^gtm|^acc_meth|^tst|^test|^PRI|^SEC|^remote_ver|^remote_image|^user|^mailing_list" | $grep -vE "gtm_icu_version" |  sed 's/\\\075/=/g' >&! ${TMP_FILE_PREFIX}_env_${USER}.txt
	# Fix user specific environment variables
	setenv | $grep -E "gtm_linktmpdir" | sed 's/\\\075/=/g' | sed 's/'$user'/$user/' >>&! ${TMP_FILE_PREFIX}_env_${USER}.txt

else
	setenv | $grep -E "^gtm|^acc_meth|^tst|^test|^PRI|^SEC|^remote_ver|^remote_image|^user|^mailing_list" | $grep -vE "gtm_icu_version" >&! ${TMP_FILE_PREFIX}_env_${USER}.txt
	setenv | $grep -E "gtm_linktmpdir" | sed 's/'$user'/$user/' >>&! ${TMP_FILE_PREFIX}_env_${USER}.txt
	# Fix user specific environment variables
endif
if ($?test_replic) then
# Send encryption related environment for remote host from current host to remote host we need this for multisite tests

	if ( -e $tst_dir/$gtm_tst_out/$testname/$tst_now_secondary"_encrypt_env_settings.txt" ) cat $tst_dir/$gtm_tst_out/$testname/$tst_now_secondary"_encrypt_env_settings.txt" >>&! ${TMP_FILE_PREFIX}_env_${USER}.txt

	if ("MULTISITE" != "$test_replic") then
		$rcp ${TMP_FILE_PREFIX}_env_${USER}.txt "$tst_remote_host":$SEC_DIR/env.txt
		if ($?gtm_test_replay) then
			$rcp $gtm_test_replay "$tst_remote_host":$SEC_DIR
		endif
	else
		#send it to all the remote hosts listed in msr_instance_config.txt
		$tst_awk '	/^HOST.*NAME:/ {hostinfo_name[$1]=$3}				\
				/^INST.*HOST:/ {instinfo_host[$1]=$3}				\
				/^INST.*INSTNAME:/ {instinfo_instname[$1]=$3}			\
				/^INST.*DBDIR:/ {instinfo_dbdir[$1]=$3}				\
			    END { for (i in instinfo_dbdir)					\
				  {	hname = hostinfo_name[instinfo_host[i]];                \
					if ("'$INSTXNAME'" == instinfo_instname[i])		\
					print "$rcp ${TMP_FILE_PREFIX}_env_${USER}.txt "hname ":" instinfo_dbdir[i]"/env.txt";	\
				  }								\
				}' msr_instance_config.txt > env_rcpfile_$$.txt

		source env_rcpfile_$$.txt
	endif
else if ("GT.CM" == $test_gtm_gtcm) then
	#cat $tst_dir/$gtm_tst_out/$testname/$tst_now_secondary"_encrypt_env_settings.txt" >>&! ${TMP_FILE_PREFIX}_env_${USER}.txt
	$sec_shell "SEC_SHELL_GTCM if (-e SEC_DIR_GTCM/env.txt) mv SEC_DIR_GTCM/env.txt SEC_DIR_GTCM/env.txt_`date +%H_%M_%S`"
	$sec_shell "$rcp ${TMP_FILE_PREFIX}_env_${USER}.txt TST_REMOTE_HOST_GTCM:SEC_DIR_GTCM/env.txt"
	if ($?gtm_test_replay) then
		$sec_shell "$rcp $gtm_test_replay TST_REMOTE_HOST_GTCM:SEC_DIR_GTCM"
	endif
else
	#some test might need to pass the environment to another user/process in the same directory
	mv ${TMP_FILE_PREFIX}_env_${USER}.txt ./env.txt
endif
