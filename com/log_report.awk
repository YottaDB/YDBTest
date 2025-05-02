#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
BEGIN {
	count = split(ENVIRON[ "tst_random_all" ],option_names," ")
}
{
	if ("" != $1) printf "%-11s: %-20s ",$1,$2;
	printf "CC:%-5s ", ENVIRON["gtm_test_yottadb_compiler"]
	printf "ASAN:%-1s ", ENVIRON["gtm_test_libyottadb_asan_enabled"]
	for (i=1 ; i<=count ; i++)
	{
		rname = option_names[i]
		rval[i] = ENVIRON[rname]
		if ( "gtm_test_jnl" == rname)
		{
			if ("SETJNL" == rval[i]) { jnlon = 1
			} else { jnlon = 0 }
			printf "JNL:%-1s ",jnlon
		}
		if ( "gtm_test_jnl_nobefore" == rname)
		{
			 if ( 0 == rval[i] ) { b4img = 1
			 } else { b4img = 0 }
			printf "B4IMG:%-1s ",b4img
		}
		if ( "test_align" == rname ) printf "ALIGN:%-6s ",rval[i]
		if ( "test_collation" == rname )
		{
			colnum = ENVIRON["test_collation_no"]
			printf "COL:%-1s ",colnum
		}
		if ( "gtm_tp_allocation_clue" == rname ) printf "TPALC:%-9s ",rval[i]
		if ( "gtm_zlib_cmp_level" == rname ) printf "CMP:%-2s ",rval[i]
		# Encryption will be represented as two binary values, encryption (1 or 0) and on the fly encryption (1 or 0) - like ENCR:11
		if ( "test_encryption" == rname )
		{
			if ( "ENCRYPT" == rval[i]) {encropt = 1
			} else { encropt = 0 }
		}
		if ( "gtm_test_do_eotf" == rname )
		{
			if ( 0 == rval[i]) { eotf = 0
			} else { eotf = 1}
			# The below will result in ENCR:11 ; ENCR:10 ; ENCR:00 ; ENCR:01 (last one not actually done)
			printf "ENCR:%-2s ",encropt""eotf
		}
		if ( "gtmdbglvl" == rname ) printf "DBGLVL:%-10s ",rval[i]
		if ( "gtm_test_online_integ" == rname ) printf "OLI:%-3s ",substr(rval[i],1,3)
		if ( "gtm_test_trigger" == rname ) printf "TRG:%-1s ",rval[i]
		if ( "gtm_chset" == rname )
		{
			if ("" == rval[i]) {chsetopt = "undef"
			} else {chsetopt = rval[i] }
			printf "CHSET:%-5s ",chsetopt
		}
		if ( "gtm_boolean" == rname ) printf "BOOL:%-1s ",rval[i]
		if ( "gtm_jnl_release_timeout" == rname ) printf "JRLSTIM:%-11s ",rval[i]
		if ( "gtm_trace_gbl_name" == rname )
		# Its not straight forward to differentiate between undefined and defined to null. So rely on passed value just for this one
		{
			if (isset_gtm_trace_gbl_name) { printf "MPROF:def "
			} else { printf "MPROF:    " }
		}
		if ( "test_replic_suppl_type" == rname ) printf "SUPPL:%-1s ",rval[i]
		if ( "gtm_test_tp" == rname )
		{
			if ("NON_TP" == rval[i]) { tp=0
			} else { tp=1}
			printf "TP:%-1s ",tp
		}
		if ( "acc_meth" == rname ) printf "ACC:%-2s ",rval[i]
		if ( "gtm_test_spannode" == rname )
		{
			spnod = ""
			if ( "1" == rval[i] ) {spnod = "N"}
		}
		if ( "gtm_test_spanreg" == rname )
		{
			spreg = ""
			if (("1" == rval[i]) || ("3" == rval[i])) {spreg="R"}
			# The below will result in SPAN:N SPAN:R SPAN:NR SPAN:
			SPAN = spnod spreg
			printf "SPAN:%-2s ",SPAN
		}
		if ( "gtm_db_counter_sem_incr" == rname )
		{
			if ("" == rval[i]) { incr="undef"
			} else {incr=rval[i]}
			printf "SEMINCR:%-5s ",incr
		}
		if ( "gtm_test_qdbrundown" == rname ) printf "QDBR:%-1s ",rval[i]
		if ( "gtm_test_freeze_on_error" == rname ) printf "IFOE:%-1s ",rval[i]
		if ( "gtm_test_fake_enospc" == rname ) printf "ENOS:%-1s ",rval[i]
		if ( "gtm_custom_errors" == rname )
		{
		    if ("" == rval[i]) { ce="undef"
		    } else if ("/dev/null" == rval[i]) { ce=0
		    } else { ce=1 }
		    printf "CERR:%-5s ",ce
		}
		if ( "gtm_side_effects" == rname ) printf "SE:%-1s ",rval[i]
		if ( "gtm_test_hugepages" == rname ) printf "HP:%-1s ",rval[i]
		if ( "gtm_test_dynamic_literals" == rname)
		{
			if ( "DYNAMIC_LITERALS" == rval[i] ) { dl = 1
			} else { dl = 0 }
			printf "DL:%-1s ",dl
		}
		if ("ydb_ipv4_only" == rname )
		{
			if ( 1 == rval[i]) { ipv6=0
			} else { ipv6=1 }
			printf "IPv6:%-1s ",ipv6
		}
		if ( "gtm_test_tls" == rname )
		{
			if ( "TRUE" == rval[i]) { tls="1-"ENVIRON["gtm_test_tls_renegotiate"]
			} else { tls=0 }
			printf "TLS:%-4s ",tls
		}
		if ( "gtm_test_embed_source" == rname )
		{
			if ( "TRUE" == rval[i] ) { embsource=1
			} else { embsource=0 }
			printf "EMBSRC:%-1s ",embsource
		}
		if ( "gtm_test_jnlfileonly" == rname ) printf "JFO:%-1s ",rval[i]
		if ( "gtm_test_jnlpool_sync" == rname ) printf "JPS:%-5s ",rval[i]
		if ( "test_replic_mh_type" == rname ) printf "MH:%-1s ",rval[i]
		if ( "gtm_test_autorelink_dirs" == rname) printf "ARD:%s ",rval[i]
		if ( "gtm_autorelink_keeprtn" == rname ) printf "ARK:%-5s ",keeprtn_bool
		if ( "gtm_poollimit" == rname ) printf "PL:%-3s ",rval[i]
		if ( "gtm_test_passcurlvn" == rname ) printf "PLV:%-1s ",rval[i]
		if ( "gtm_test_defer_allocate" == rname ) printf "DA:%-1s ",rval[i]
		if ( "gtm_test_epoch_taper" == rname ) printf "ET:%-1s ",rval[i]
		if ( "gtm_test_asyncio" == rname ) printf "AIO:%-1s ",rval[i]
		if ( "gtm_test_updhelpers" == rname ) printf "UH:%-3s ",rval[i]
		if ( "gtm_test_forward_rollback" == rname ) printf "FR:%-1s ",rval[i]
		if ( "gtm_mupjnl_parallel" == rname ) printf "MP:%-1s ",rval[i]
		if ( "ydb_lockhash_n_bits" == rname ) printf "LH:%-1s ",rval[i]
		if ( "gtm_test_trigupdate" == rname ) printf "TRGUPD:%-1s ",rval[i]
		if ( "ydb_test_4g_db_blks" == rname ) printf "HUGEDB:%-1s ",((rval[i] == 0) ? 0 : 1)
		if ( "gtm_test_use_V6_DBs" == rname )
		{	# If V6DB mode, print random version used - else null string
			if (0 != rval[i])
				rval[i] = ENVIRON["gtm_test_v6_dbcreate_rand_ver"]
			else
				rval[i] = ""
			printf "V6DB:%-11s ", rval[i]
		}
		if ( "ydb_readline" == rname ) printf "RL:%-1s ",rval[i]
		if ( "gtm_statshare" == rname ) printf "STATS:%-1s ",rval[i]
	}
	print "",$3
}
