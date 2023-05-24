#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
##some of the allowed SUSPEND_OUTPUT/ALLOW_OUTPUT options:
#HOST_ALL
# server name, such as: dingo (or DINGO, case insensitive)
# platform, recognized platforms are (see defaults_csh)
#HOST_AIX_RS6000
#HOST_HP-UX_PA_RISC
#HOST_LINUX_IX86
#HOST_LINUX_S390X
#HOST_OS390_S390
#HOST_OSF1_ALPHA
#HOST_SUNOS_SPARC
#HOST_LINUX_IA64
#HOST_HP-UX_IA64
#HOST_CYGWIN_IX86
#HOST_LINUX_X86_64
#HOST_LINUX_ARMVXL	# ARMVXL is for ARMV6L, ARMV7L etc.
#HOST_LINUX_AARCH64
# and machine type. For example:
#IA64 (for Itanium machines)
# and OS name. For example: AIX
#
# note that if you want to allow output for one server only (and disallow others),
# you should use SUSPEND_OUTPUT HOST_ALL to disallow others
#
# also note that unite will not be able to handle any of the above, the reference files will need to be
# modified manually.

BEGIN {
	nr_outref = 0
	nr_outstream = 0
	tst_dir = ENVIRON[ "tst_working_dir" ]
	envvar = ENVIRON[ "envvar" ]	# used by v53003/u_inref/D9I10002703.csh
	remote_tst_dir = ENVIRON[ "SEC_DIR" ]
	tst_osname = toupper(ENVIRON[ "gtm_test_osname" ]);
	tst_machtype = toupper(ENVIRON[ "gtm_test_machtype" ]);
	tst_linux_distrib = toupper(ENVIRON[ "gtm_test_linux_distrib"]);
	if ("" == tst_linux_distrib) { tst_linux_distrib = "NON_LINUX"}
	tst_hostos_machtype = ENVIRON[ "gtm_test_os_machtype" ]
	tst_hostos_machtype_all = ENVIRON[ "gtm_test_os_machtype_all" ]
	tst_server_location = ENVIRON[ "gtm_server_location" ]
	tst_remote_dir = ENVIRON[ "tst_remote_dir" ]
	tst_remote_dir_gtcm_total = ENVIRON[ "tst_remote_dir_gtcm_total" ]
	split(tst_remote_dir_gtcm_total, dir_gtcm_array, " ");
	tst_gtcm_server_list = ENVIRON[ "tst_gtcm_server_list"]; gsub(/^[ ]*/, "", tst_gtcm_server_list);
	no_gtcm_hosts = split(tst_gtcm_server_list, server_list_array, " ");
	for (i in dir_gtcm_array)
		dir_gtcm_array[i] = ENVIRON["SEC_DIR_GTCM_"i]
        gtm_tst_out = ENVIRON[ "gtm_tst_out" ]
        tst = ENVIRON[ "tst" ]
        testname = ENVIRON[ "testname" ]
	gtm_tst = ENVIRON[ "gtm_tst" ]
	in_test_path = gtm_tst "/" tst
	gtm_exe = ENVIRON[ "gtm_exe" ]
	gtm_exe_realpath = ENVIRON[ "gtm_exe_realpath" ]
	gtm_root = ENVIRON[ "gtm_root" ]
	home = ENVIRON[ "HOME" ]
        tst_image = toupper(ENVIRON[ "tst_image" ])
	gtm_src = ENVIRON[ "gtm_src" ]
	remote_gtm_exe = ENVIRON[ "remote_gtm_exe" ]
	tst_org_host = ENVIRON[ "tst_org_host" ]
	tst_org_host_short = tst_org_host; sub(/\..*$/, "", tst_org_host_short)
	tst_node = tst_org_host_short
	option_names[++no_options] = "TST_ORG_HOST"
	envir["TST_ORG_HOST"] = toupper(tst_org_host_short)
	tst_remote_host_ms_1 = ENVIRON[ "tst_remote_host_ms_1" ]
	tst_remote_host_ms_2 = ENVIRON[ "tst_remote_host_ms_2" ]
	tst_remote_dir_ms_1 = ENVIRON[ "tst_remote_dir_ms_1" ]
	tst_remote_dir_ms_2 = ENVIRON[ "tst_remote_dir_ms_2" ]
	tst_remote_host = ENVIRON[ "tst_remote_host" ]
	tst_remote_host_short = tst_remote_host; sub(/\..*/, "", tst_remote_host_short)
	tst_remote_host_2 = ENVIRON[ "tst_remote_host_2"]
	envir["LFE"] = ENVIRON[ "LFE" ]
	gt_ld_shl_suffix = ENVIRON[ "gt_ld_shl_suffix" ]
	no_options = split(ENVIRON[ "tst_options_all" ], option_names, " ")
	for (i in option_names)
	{
		x = option_names[i]
		envir[x] = ENVIRON[x]
	}
	# The options in tst_random_all would mostly have 0/1 or null/non-null values (eg gtm_test_trigger)
	# To have meaningful flag names reinitialize them below
	no_options = split(ENVIRON[ "tst_random_all" ], option_names, " ")
	for (i in option_names)
	{
		x = option_names[i]
		envir[x] = ENVIRON[x]
	}
	option_names[++no_options] = "tst_osname"
	envir[no_options] = tst_osname
	option_names[++no_options] = "tst_server_location"
	envir[no_options] = tst_server_location
	option_names[++no_options] = "tst_linux_distrib"
	envir[no_options] = tst_linux_distrib
	option_names[++no_options] = "tst_machtype"
	envir[no_options] = tst_machtype
	option_names[++no_options] = "tst_hostos_machtype"
	envir[no_options] = tst_hostos_machtype
	option_names[++no_options] = "tst_image"
	envir[no_options] = tst_image
	#
	option_names[++no_options] = "gtm_endian"
	if ("BIG_ENDIAN" == ENVIRON["gtm_endian"])
		envir[no_options] = "BIG_ENDIAN"
	else
		envir[no_options] = "LITTLE_ENDIAN"
	#
	option_names[++no_options] = "gtm_test_unicode_support"
	if ("TRUE" == ENVIRON["gtm_test_unicode_support"])
		envir[no_options] = "UTF8"
	else
		envir[no_options] = "NON_UTF8"
	#
	option_names[++no_options] = "gtm_chset"
	if ("UTF-8" == ENVIRON["gtm_chset"])
	{
		envir[no_options] = "UNICODE_MODE"
		option_names[++no_options] = "gtm_chset_3state"
		envir[no_options] = "CHSET_UTF8"
	} else
	{
		envir[no_options] = "NONUNICODE_MODE"
		option_names[++no_options] = "gtm_chset_3state"
		if ("M" == ENVIRON["gtm_chset"])
			envir[no_options] = "CHSET_M"
		else
			envir[no_options] = "CHSET_UNDEF"
	}
	#
	option_names[++no_options] = "gtm_test_jnl_nobefore"
	if ("1" == ENVIRON["gtm_test_jnl_nobefore"])
		envir[no_options] = "JNL_NOBEFORE"
	else
		envir[no_options] = "JNL_BEFORE"
	#

	option_names[++no_options] = "gtm_platform_size"
        if ("64" == ENVIRON["gtm_platform_size"])
                envir[no_options] = "64BIT_GTM"
        else
                envir[no_options] = "32BIT_GTM"
        #
	option_names[++no_options] = "gtm_platform_no_V4"
        if ("" != ENVIRON["gtm_platform_no_V4"])
                envir[no_options] = "PLATFORM_NO_V4GTM"
        #
	option_names[++no_options] = "gtm_test_nopriorgtmver"
        if ("1" == ENVIRON["gtm_test_nopriorgtmver"])
                envir[no_options] = "PLATFORM_NO_PRIORGTM"
        #
	option_names[++no_options] = "gtm_platform_no_compress_ver"
        if ("1" == ENVIRON["gtm_platform_no_compress_ver"])
                envir[no_options] = "PLATFORM_NO_COMPRESS_VER"
        #
	option_names[++no_options] = "gtm_platform_no_ds_ver"
        if ("1" == ENVIRON["gtm_platform_no_ds_ver"])
                envir[no_options] = "PLATFORM_NO_DSVER"
        #
	option_names[++no_options] = "gtm_test_noggtoolsdir"
        if ("1" == ENVIRON["gtm_test_noggtoolsdir"])
                envir[no_options] = "PLATFORM_NO_GGTOOLSDIR"
        #
	option_names[++no_options] = "gtm_test_noggusers"
        if ("1" == ENVIRON["gtm_test_noggusers"])
                envir[no_options] = "PLATFORM_NO_GGUSERS"
        #
	option_names[++no_options] = "gtm_test_noggbuilddir"
        if ("1" == ENVIRON["gtm_test_noggbuilddir"])
                envir[no_options] = "PLATFORM_NO_GGBUILDDIR"
        #
	option_names[++no_options] = "gtm_test_noIGS"
        if ("1" == ENVIRON["gtm_test_noIGS"])
                envir[no_options] = "PLATFORM_NO_IGS"
        #
        option_names[++no_options] = "gtm_platform_no_4byte_utf8"
        if ("1" == ENVIRON["gtm_platform_no_4byte_utf8"])
                envir[no_options] = "PLATFORM_NO_4BYTE_UTF8"
        #
	if ("MULTISITE" != ENVIRON["test_repl"])
	{
		tst_multisite = "NON_MULTISITE"
		option_names[++no_options] = "tst_multisite"
		envir[no_options] = "NON_MULTISITE"
	}
	#
	option_names[++no_options] = "gtm_platform_mmfile_ext"
	if (("MM" != ENVIRON["acc_meth"]) || ("0" != ENVIRON["gtm_platform_mmfile_ext"]))
		envir[no_options] = "MM_FILE_EXT"
	else
		envir[no_options] = "MM_FILE_NO_EXT"
	#
	option_names[++no_options] = "test_encryption"
	if ("ENCRYPT" == ENVIRON["test_encryption"])
		envir[no_options] = "ENCRYPT"
	else
		envir[no_options] = "NON_ENCRYPT"
	#
	option_names[++no_options] = "gtm_test_trigger"
	if (1 == ENVIRON["gtm_test_trigger"])
		envir[no_options] = "TRIGGER"
	else
		envir[no_options] = "NOTRIGGER"
	#
	option_names[++no_options] = "gtm_test_trigupdate"
	if (1 == ENVIRON["gtm_test_trigupdate"])
		envir[no_options] = "TRIGUPDATE"
	else
		envir[no_options] = "NOTRIGUPDATE"
	#
	option_names[++no_options] = "gtm_test_tls"
	if ("TRUE" == ENVIRON["gtm_test_tls"])
		envir[no_options] = "TLS"
	else
		envir[no_options] = "NOTLS"
	#
	option_names[++no_options] = "gtm_test_java_support"
	if (1 == ENVIRON["gtm_test_java_support"])
		envir[no_options] = "PLATFORM_JAVA"
	else
		envir[no_options] = "PLATFORM_NOJAVA"
	option_names[++no_options] = "test_replic_suppl_type"
	if (1 == ENVIRON["test_replic_suppl_type"])
		envir[no_options] = "SUPPLEMENTARY_AP"
	else if (2 == ENVIRON["test_replic_suppl_type"])
		envir[no_options] = "SUPPLEMENTARY_PQ"
	else
		envir[no_options] = "SUPPLEMENTARY_AB"
	option_names[++no_options] = "gtm_test_spanreg"
	if ((1 == ENVIRON["gtm_test_spanreg"]) || (3 == ENVIRON["gtm_test_spanreg"]))
		envir[no_options] = "SPANNING_REGIONS"
	else
		envir[no_options] = "NONSPANNING_REGIONS"
	option_names[++no_options] = "gtm_custom_errors"
	if ("" != ENVIRON["gtm_custom_errors"])
		envir[no_options] = "CUSTOM_ERRORS"
	else
		envir[no_options] = "NO_CUSTOM_ERRORS"
	#
	option_names[++no_options] = "gtm_test_forward_rollback"
	if (1 == ENVIRON["gtm_test_forward_rollback"])
		envir[no_options] = "FORWARD_ROLLBACK"
	else
		envir[no_options] = "NOFORWARD_ROLLBACK"
	#
	option_names[++no_options] = "gtm_mupjnl_parallel"
	if ((1 == ENVIRON["gtm_mupjnl_parallel"]) || ("" == ENVIRON["gtm_mupjnl_parallel"]))
		envir[no_options] = "NOMUPJNL_PARALLEL"
	else
		envir[no_options] = "MUPJNL_PARALLEL"
	#
	if ("x86_64" == ENVIRON["real_mach_type"])
	{
		option_names[++no_options] = "OS_ARCH"
		if ("arch" == ENVIRON["gtm_test_linux_distrib"])
			envir[no_options] = "ARCH_LINUX_X86_64"
		else if ("debian" == ENVIRON["gtm_test_linux_distrib"])
			envir[no_options] = "DEBIAN_LINUX_X86_64"
		else if ("ubuntu" == ENVIRON["gtm_test_linux_distrib"])
			envir[no_options] = "UBUNTU_LINUX_X86_64"
		else if ("centos" == ENVIRON["gtm_test_linux_distrib"])
			envir[no_options] = "CENTOS_LINUX_X86_64"
		else if ("rhel" == ENVIRON["gtm_test_linux_distrib"])
			envir[no_options] = "RHEL_LINUX_X86_64"
			option_names[++no_options] = "OS_ARCH_VER"
			if ("7.9" == ENVIRON["gtm_test_linux_version"])
				envir[no_options] = "RHEL_7.9"
		else if ("suse" == ENVIRON["gtm_test_linux_distrib"])
			envir[no_options] = "SUSE_LINUX_X86_64"
	} else if ("aarch64" == ENVIRON["real_mach_type"])
	{
		option_names[++no_options] = "OS_ARCH"
		if ("debian" == ENVIRON["gtm_test_linux_distrib"])
			envir[no_options] = "DEBIAN_LINUX_AARCH64"
		else if ("ubuntu" == ENVIRON["gtm_test_linux_distrib"])
			envir[no_options] = "UBUNTU_LINUX_AARCH64"
	}
	option_names[++no_options] = "OS"
	if ("arch" == ENVIRON["gtm_test_linux_distrib"])
		envir[no_options] = "ARCH_LINUX"
	else if ("debian" == ENVIRON["gtm_test_linux_distrib"])
		envir[no_options] = "DEBIAN_LINUX"
	else if ("ubuntu" == ENVIRON["gtm_test_linux_distrib"])
		envir[no_options] = "UBUNTU_LINUX"
	else if ("centos" == ENVIRON["gtm_test_linux_distrib"])
		envir[no_options] = "CENTOS_LINUX"
	else if ("rhel" == ENVIRON["gtm_test_linux_distrib"])
		envir[no_options] = "RHEL_LINUX"
	else if ("suse" == ENVIRON["gtm_test_linux_distrib"])
		envir[no_options] = "SUSE_LINUX"
	#
	option_names[++no_options] = "gtm_test_singlecpu"
	if (1 == ENVIRON["gtm_test_singlecpu"])
		envir[no_options] = "ONECPU"
	#
	option_names[++no_options] = "ydb_test_exclude_diskfollow_timeout"
	if (1 == ENVIRON["ydb_test_exclude_diskfollow_timeout"])
		envir[no_options] = "EXCLUDE_DISKFOLLOW_TIMEOUT"
	#
	option_names[++no_options] = "ydb_test_exclude_sem_counter"
	if (1 == ENVIRON["ydb_test_exclude_sem_counter"])
		envir[no_options] = "EXCLUDE_SEM_COUNTER"
	#
	option_names[++no_options] = "ydb_test_exclude_ydb362b"
	if (1 == ENVIRON["ydb_test_exclude_ydb362b"])
		envir[no_options] = "EXCLUDE_YDB362B"
	#
	option_names[++no_options] = "ydb_test_exclude_gtm7083a"
	if (1 == ENVIRON["ydb_test_exclude_gtm7083a"])
		envir[no_options] = "EXCLUDE_GTM7083A"
	#
	option_names[++no_options] = "ydb_test_exclude_V5_tests"
	if (1 == ENVIRON["ydb_test_exclude_V5_tests"])
		envir[no_options] = "EXCLUDE_V5_TESTS"
	#
	option_names[++no_options] = "ydb_test_exclude_ydb749"
	if (1 == ENVIRON["ydb_test_exclude_ydb749"])
		envir[no_options] = "EXCLUDE_YDB749"
	#
	option_names[++no_options] = "is_tst_dir_ssd"
	if (1 == ENVIRON["is_tst_dir_ssd"])
		envir[no_options] = "TST_DIR_SSD"
	else
		envir[no_options] = "TST_DIR_HDD"
	#
	option_names[++no_options] = "real_mach_type"
	if ("armv6l" == ENVIRON["real_mach_type"])
		envir[no_options] = "MACHTYPE_ARMV6L"
	#
	option_names[++no_options] = "big_files_present"
	if ("0" == ENVIRON["big_files_present"])
		envir[no_options] = "BIG_FILES_ABSENT"
	else
		envir[no_options] = "BIG_FILES_PRESENT"
	#
	option_names[++no_options] = "ydb_test_tls13_plus"
	if (1 == ENVIRON["ydb_test_tls13_plus"])
		envir[no_options] = "TLS1.3PLUS"
	else
		envir[no_options] = "TLS1.3MINUS"
	#
	option_names[++no_options] = "gtm_test_dynamic_literals"
	if ("DYNAMIC_LITERALS" == ENVIRON["gtm_test_dynamic_literals"])
		envir[no_options] = "DYNAMIC_LITERALS"
	else
		envir[no_options] = "NODYNAMIC_LITERALS"
	#
	option_names[++no_options] = "gtm_test_asyncio"
	if ("1" == ENVIRON["gtm_test_asyncio"])
		envir[no_options] = "ASYNCIO"
	else
		envir[no_options] = "NOASYNCIO"
	#
	option_names[++no_options] = "gtm_test_libyottadb_asan_enabled"
	if ("1" == ENVIRON["gtm_test_libyottadb_asan_enabled"])
		envir[no_options] = "ASAN_ENABLED"
	else
		envir[no_options] = "ASAN_DISABLED"
	#
	option_names[++no_options] = "gtm_test_asan_compiler"
	if ("clang" == ENVIRON["gtm_test_asan_compiler"])
		envir[no_options] = "ASAN_CLANG"
	#
	option_names[++no_options] = "clang_major_ver"
	if (("14" == ENVIRON["clangmajorver"]) || ("15" == ENVIRON["clangmajorver"]))
		envir[no_options] = "CLANG14_OR_15"
	#
	options_names[++no_options] = "ydb_allow64GB_jnlpool"
	if ("0" == ENVIRON["ydb_allow64GB_jnlpool"])
		envir[no_options] = "JNLPOOL64GB_DISALLOW"
	#
	if (("ubuntu" == ENVIRON["gtm_test_linux_distrib"]) && ("21.10" == ENVIRON["gtm_test_linux_version"]))
	{
		option_names[++no_options] = "ubuntu_21.10"
		envir[no_options] = "UBUNTU_21.10"
	}
	#
	option_names[++no_options] = "is_tst_dir_cmp_fs"
	if ("1" == ENVIRON["is_tst_dir_cmp_fs"])
		envir[no_options] = "TST_DIR_COMPRESSED"
	else
		envir[no_options] = "TST_DIR_NOT_COMPRESSED"
	#
	option_names[++no_options] = "tst_dir_fstype"
	if ("zfs" == ENVIRON["tst_dir_fstype"])
		envir[no_options] = "TST_DIR_ZFS"
	else
		envir[no_options] = "TST_DIR_NOT_ZFS"
	#
	# For now set the [UPGRADE_DOWNGRADE_UNSUPPORTED] tag all the time as MUPIP UPGRADE/MUPIP DOWNGRADE functionality
	# is not supported in V7 format database and likely will not be supported (by GT.M) in the future either.
	# Use this tag to also note the fact that MUPIP REORG UPGRADE/MUPIP REORG DOWNGRADE functionality is not supported
	# currently. This tag is noted in test scripts where UPGRADE or DOWNGRADE related functionality currently disabled.
	# Using this tag convention makes it easy to identify all such places in the future (for example, how many subtests
	# are disabled due to this tag). Note that MUPIP REORG UPGRADE/DOWNGRADE functionality is available in GT.M V7.1-000
	# but MUPIP UPGRADE/DOWNGRADE functionality is not. So when GT.M V7.1-000 is merged, a few places that use this tag
	# can be uncommented/re-enabled as long as they only do MUPIP REORG UPGRADE/DOWNGRADE stuff.
	option_names[++no_options] = "upgrade_downgrade_unsupported"
	envir[no_options] = "UPGRADE_DOWNGRADE_UNSUPPORTED"
	#
	split(tst_hostos_machtype_all, all_platforms, " ")
	if ("AIX" == tst_osname)
	{
		if (6 > ENVIRON[ "gtm_test_osver" ])
		{
			option_names[++no_options] = "aix_5"
			envir[no_options] = "AIX_5"
		}
		else
		{
			option_names[++no_options] = "aix_new"
			envir[no_options] = "AIX_NEW"
		}
	}
	#
        for (elem in envir)
	{
		if (envir[elem] == "")  envir[elem] = "@" ;
		else envir[elem] = "#" envir[elem]"#";
	}
	# A is missing since it is local!
	database_layout = "DEFAULT B C D E F G H I J K L"
	max_regions = split(database_layout, database_layout_array, " ");
	# dbcreate_multi.awk would have randomly added "@" prefix to <hostname>:<filename> in remote file specification
	# for gtcm tests. Take that into account to generate the *.cmp file from the *.txt reference file.
	split(ENVIRON["tst_gtcm_server_at_prefix_list"], at_prefix_array, " ");
	at_prefix[0] = ""
	at_prefix[1] = "@"
}
$1 ~ /##ALLOW_OUTPUT/ {
	tstring = sprintf("##ALLOW_OUTPUT")
	for (i = 2;i<= NF;i++)
	{
		tstring = sprintf ("%s %s",tstring,$i)
		if ("HOST_ALL" != process($i, "correct"))
		{
			denytmp = gensub("#"process($i, "correct")"#", "#", "g", deny);
			deny = denytmp;
		} else
		{
			for (h in all_platforms)
			{
				denytmp = gensub("#"all_platforms[h]"#", "#", "g", deny);
				deny = denytmp;
			}
			# we can remove this specific host from the deny string as well
			denytmp = gensub("#"envir["TST_ORG_HOST"]"#", "#", "g", deny)
			deny = denytmp;
		}
		# if a host/osname/machtype/linux_distrib is specifically ALLOW'ed, remove it's platform from deny list
		envlist = envir["TST_ORG_HOST"]" "tst_machtype" "tst_osname" "tst_linux_distrib
		allowthis = process($i, "correct")
			if(index(envlist,allowthis) !=0 )
			{
				d1 = gensub("#"tst_hostos_machtype"#", "#", "g", deny);
				d2 = gensub("#"tst_machtype"#", "#", "g", d1);
				d3 = gensub("#"tst_osname"#", "#", "g", d2);
				d4 = gensub("#"tst_linux_distrib"#", "#", "g", d3);
				deny = d4;
			}
	}
	printf "%s:\n%s\n",tstring,deny > "suspended_output"
	next
}

$1 ~ /##SUSPEND_OUTPUT/ {
	tstring = sprintf("##SUSPEND_OUTPUT")
	for (i = 2;i<= NF;i++)
	{
		tstring = sprintf ("%s %s",tstring,$i)
		if ("HOST_ALL" != process($i, "correct"))
		{
			# add to the deny string if not already there
			tmpstr = "#"process($i, "correct")"#"
			if (index(deny,tmpstr) == 0)
				deny = deny (tmpstr)
		}
		else
		{
			for (h in all_platforms)
			{
				# add to the deny string if not already there
				tmpstr = "#"all_platforms[h]"#"
				if (index(deny,tmpstr) == 0)
					deny = deny (tmpstr)
			}
		}
	}
	denytmp = gensub(/#[#]*/, "#", "g", deny);
	deny = denytmp;
	printf "%s:\n%s\n",tstring,deny > "suspended_output"
	next
}

FILENAME ~/outref/ {
	allow = 1
	hostno = 1
	gtcm_chunk_line_no = 0;
	replace_flags();
	for (elem in envir)
	{	# do not print out the line if one of the options is in the deny string
		if (0 != index(deny, envir[elem]))
			allow = 0 ;
	}
	if (allow)
	{
		if ($0 ~ /##GT.CM##/)
		{
			if (0 ==  tst_remote_dir_gtcm_total)
			{
				print "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
				print "OUTREF-E-REFERENCE reference file has GT.CM output, but test was not run with GT.CM"
				print "Cannot go on creating cmp file. Either run test with -gtcm, or correct reference file"
				print "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
				exit;
			}
			#GT.CM chunk, find the end, print as many times as the number of hosts (no_gtcm_hosts)
			do {
				gsub("##GT.CM##", "");
				gtcm_chunk[++gtcm_chunk_line_no] = $0
				getline;
				replace_flags();
			} while ($0 ~ /##GT.CM##/)
		}
		if (gtcm_chunk_line_no)
		{
			for (gtcm_i = 1; gtcm_i<= no_gtcm_hosts; gtcm_i++)
			{
				for (x = 1; x<= gtcm_chunk_line_no; x++)
				{
					line = gtcm_chunk[x]
					gsub(/##TEST_REMOTE_PATH_GTCM##/, dir_gtcm_array[hostno], line);
					gsub(/##TEST_REMOTE_HOST_GTCM##/, server_list_array[hostno], line);
					node_name = server_list_array[hostno]
					sub(/\..*$/,"",node_name)
					gsub(/##TEST_REMOTE_NODE_PATH_GTCM##/, at_prefix[at_prefix_array[hostno]] node_name ":" dir_gtcm_array[hostno], line);
					print line;
				}
				hostno++; if (hostno > no_gtcm_hosts) hostno = 1;
			}
		}
		##########Then clean any other GT.CM related flags that there may be
		if (($0 ~ /##TEST_REMOTE_HOST_GTCM##/)||($0 ~ /##TEST_REMOTE_HOST_GTCM##/)||($0 ~ /##TEST_REMOTE_NODE_PATH_GTCM##/))
		{
			letter = substr($1, 1, 1);
			if ($1 ~ /DEFAULT/)
				hostno = 1
			else {
				for (x = 1;x<max_regions;x++)
					if (database_layout_array[x] ==  letter)
						dat_no = x
				hostno = (dat_no-1)%no_gtcm_hosts +1;
				#print hostno " = " dat_no " modulo" no_gtcm_hosts " = " dat_no%no_gtcm_hosts
			}
			gsub(/##TEST_REMOTE_PATH_GTCM##/, dir_gtcm_array[hostno]);
			gsub(/##TEST_REMOTE_HOST_GTCM##/, server_list_array[hostno]);
			node_name = server_list_array[hostno]
			sub(/\..*$/,"",node_name)
			gsub(/##TEST_REMOTE_NODE_PATH_GTCM##/, at_prefix[at_prefix_array[hostno]] node_name ":" dir_gtcm_array[hostno])
		}
		#########
		if ($0 ~ /##TEST_AWK/)
		{
			gsub(/##TEST_AWK/, "")
			$0 = "^" $0 "$"
			if (out_file[nr_outref] !~ $0)
				print "##DIFFERENT EXPRESSION##" $0 "## VS ##"out_file[nr_outref] "##"
			else
				print out_file[nr_outref]
		}
		else
			print;
		nr_outref++
		nr_outref+= gtcm_chunk_line_no*no_gtcm_hosts
	}
}

FILENAME !~ /outref/ {
	out_file[nr_outstream] = $0
	nr_outstream++
}

function replace_flags()
{
	gsub(/##TEST_REMOTE_HOST_GTCM_1##/, server_list_array[1]);
	gsub(/##TEST_REMOTE_PATH_GTCM_1##/, dir_gtcm_array[1]);
	node_name = server_list_array[1]
	sub(/\..*$/,"",node_name)
	gsub(/##TEST_REMOTE_NODE_PATH_GTCM_1##/, at_prefix[at_prefix_array[1]] node_name ":" dir_gtcm_array[1])
	gsub(/##TEST_REMOTE_HOST_GTCM_2##/, server_list_array[2]);
	gsub(/##TEST_REMOTE_PATH_GTCM_2##/, dir_gtcm_array[2]);
	node_name = server_list_array[2]
	sub(/\..*$/,"",node_name)
	gsub(/##TEST_REMOTE_NODE_PATH_GTCM_2##/, at_prefix[at_prefix_array[2]] node_name ":" dir_gtcm_array[2])
	if ("" == remote_tst_dir)
		gsub(/##REMOTE_TEST_PATH##/, tst_remote_dir"/"gtm_tst_out"/"testname"/tmp")
	else
		gsub(/##REMOTE_TEST_PATH##/, remote_tst_dir)
	gsub(/##TEST_PATH##/, tst_dir)
	gsub(/##YDBENVVAR##/, envvar) # used by v53003/u_inref/D9I10002703.csh
	gsub(/##IN_TEST_PATH##/, in_test_path)
	gsub(/##REMOTE_SOURCE_PATH##/, remote_gtm_exe)
	gsub(/##SOURCE_PATH##/, gtm_exe)
	gsub(/##SOURCE_REALPATH##/, gtm_exe_realpath)
	gsub(/##HOME_PATH##/, home)
	gsub(/##TST_IMAGE##/, tolower(tst_image))
	gsub(/##TEST_HOST##/, tst_org_host)
	gsub(/##TEST_HOST_SHORT##/, tst_org_host_short)
	gsub(/##TEST_NODE##/, tst_node)
	gsub(/##TEST_REMOTE_HOST##/, tst_remote_host)
	gsub(/##TEST_REMOTE_HOST_SHORT##/, tst_remote_host_short)
	gsub(/##TEST_REMOTE_HOST_MS_1##/, tst_remote_host_ms_1)
	gsub(/##TEST_REMOTE_HOST_MS_2##/, tst_remote_host_ms_2)
	gsub(/##TEST_REMOTE_DIR_MS_1##/, tst_remote_dir_ms_1)
	gsub(/##TEST_REMOTE_DIR_MS_2##/, tst_remote_dir_ms_2)
	gsub(/##TEST_GTCM_SERVER_LIST##/, tst_gtcm_server_list)
	gsub(/##TEST_REMOTE_HOST_2##/, tst_remote_host_2)
	gsub(/##TEST_COM_PATH##/, gtm_tst"/com")
	gsub(/##TEST_SHL_SUFFIX##/, gt_ld_shl_suffix)
	gsub(/##GTM_LIBRARY_PATH##/, gtm_root)
}
