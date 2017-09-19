#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
function process(option,result){
#result: option_name or correct
#correct gives a standard output for each option recognized
#option_name gives the name of the option recognized
#print "#::"option
option=toupper(option)
if (option ~ /^BG$/)			{oput="BG";		var="acc_meth"			}
else if (option ~ /^MM$/)		{oput="MM";		var="acc_meth"			}
else if (option ~ /^REPLIC$/)		{oput="REPLIC";		var="test_repl"			}
else if (option ~ /^NO.*REP/)		{oput="NON_REPLIC";	var="test_repl"			}
else if (option ~ /^MULTISITE/)		{oput="MULTISITE";	var="test_repl"			}
else if (option ~ /^MULTI_SITE/)	{oput="MULTISITE";	var="test_repl"			}
else if (option ~ /^SUPPL.*_AB/)	{oput="SUPPLEMENTARY_AB"; var="test_replic_suppl_type"	} # Neither servers are Supplementary
else if (option ~ /^SUPPL.*_AP/)	{oput="SUPPLEMENTARY_AP"; var="test_replic_suppl_type"	} # Receiver server is Supplementary
else if (option ~ /^SUPPL.*_PQ/)	{oput="SUPPLEMENTARY_PQ"; var="test_replic_suppl_type"	} # Both servers are Supplementary
else if (option ~ /^2WL$/)		{oput="2WL";		var="gtm_server_location"	}
else if (option ~ /^ATL$/)		{oput="ATL";		var="gtm_server_location"	}
else if (option ~ /^NONGGSERVER/)	{oput="NONGGSERVER";	var="gtm_server_location"	}
else if (option ~ /^BIG_ENDIAN/)	{oput="BIG_ENDIAN";	var="gtm_endian"	}
else if (option ~ /^LITTLE_ENDIAN/)	{oput="LITTLE_ENDIAN";	var="gtm_endian"	}
else if (option ~ /^UNICODE_MODE/)	{oput="UNICODE_MODE";	var="gtm_chset"	}
else if (option ~ /^NONUNICODE_MODE/)	{oput="NONUNICODE_MODE";var="gtm_chset"	}
else if (option ~ /^REORG$/)		{oput="REORG";		var="test_reorg"		}
else if (option ~ /^NO.*REO/)		{oput="NON_REORG";	var="test_reorg"		}
#test_region is not used anymore, it is kept here only for backward compatibility of reference files
else if (option ~ /^SIN/)		{oput="SINGLE_REG";	var="test_region"		}
else if (option ~ /^MULTI_R/)		{oput="MULTI_REG";	var="test_region"		}
else if (option ~ /^MULTIR/)		{oput="MULTI_REG";	var="test_region"		}
else if (option ~ /^GT[^C]?M/)		{oput="GT.M";		var="test_gtm_gtcm"		}
else if (option ~ /^GT[^C]?CM/)		{oput="GT.CM";		var="test_gtm_gtcm"		}
else if (option ~ /^TP$/)		{oput="TP";		var="gtm_test_tp"		}
else if (option ~ /^NON?.?TP$/) 	{oput="NON_TP";		var="gtm_test_tp"		}
else if (option ~ /^[A-Z]$/)		{oput=option;		var="LFE"			}
else if (option ~ /^UNNICE$/)		{oput="UNNICE";		var="test_nice"			}
else if (option ~ /^NON?.?NI/)		{oput="UNNICE";		var="test_nice"			}
else if (option ~ /^NICE$/)		{oput="NICE";		var="test_nice"			}
else if (option ~ /^COLLATION$/)	{oput="COLLATION";	var="test_collation"		}
else if (option ~ /^NO.*CO/)		{oput="NON_COLLATION";	var="test_collation"		}
else if (option ~ /^SETJNL/)		{oput="SETJNL";		var="gtm_test_jnl"		}
else if (option == /^JNL/)		{oput="SETJNL";		var="gtm_test_jnl"		}
else if (option ~ /^NO.*JNL/)		{oput="NON_SETJNL";	var="gtm_test_jnl"		}
else if (option ~ /^NO.*NOLINE/)	{oput="NON_NOLINE";	var="gtm_test_nolineentry"	}
else if (option ~ /^NOLINE/)		{oput="NOLINE";		var="gtm_test_nolineentry"	}
else if (option ~ /^DBG$/)		{oput="DBG";		var="tst_image"			}
else if (option ~ /^PRO$/)		{oput="PRO";		var="tst_image"			}
else if (option ~ /^BTA$/)		{oput="BTA";		var="tst_image"			}
else if (option ~ /^UTF8/)		{oput="UTF8";		var="gtm_test_unicode_support"	}
else if (option ~ /^NON_UTF8/)		{oput="NON_UTF8";	var="gtm_test_unicode_support"	}
else if (option == /^JNL_BEFORE/)	{oput="JNL_BEFORE";	var="gtm_test_jnl_nobefore"	}
else if (option == /^JNL_NOBEFORE/)	{oput="JNL_NOBEFORE";	var="gtm_test_jnl_nobefore"	}
else if (option ~ /^64BIT_GTM/)         {oput="64BIT_GTM";      var="gtm_platform_size" 	}
else if (option ~ /^32BIT_GTM/)         {oput="32BIT_GTM";      var="gtm_platform_size" 	}
else if (option ~ /^PLATFORM_NO_V4GTM/)		{oput="PLATFORM_NO_V4GTM";		var="gtm_platform_no_V4"		}
else if (option ~ /^PLATFORM_NO_PRIORGTM/)	{oput="PLATFORM_NO_PRIORGTM";		var="gtm_test_nopriorgtmver"		}
else if (option ~ /^PLATFORM_NO_COMPRESS_VER/)	{oput="PLATFORM_NO_COMPRESS_VER";	var="gtm_platform_no_compress_ver"	}
else if (option ~ /^PLATFORM_NO_DSVER/)		{oput="PLATFORM_NO_DSVER";		var="gtm_platform_no_ds_ver"		}
else if (option ~ /^PLATFORM_NO_GGTOOLSDIR/)	{oput="PLATFORM_NO_GGTOOLSDIR";		var="gtm_test_noggtoolsdir"		}
else if (option ~ /^PLATFORM_NO_GGUSERS/)	{oput="PLATFORM_NO_GGUSERS";		var="gtm_test_noggusers"		}
else if (option ~ /^PLATFORM_NO_GGBUILDDIR/)	{oput="PLATFORM_NO_GGBUILDDIR";		var="gtm_test_noggbuilddir"		}
else if (option ~ /^PLATFORM_NO_IGS/)		{oput="PLATFORM_NO_IGS";		var="gtm_test_noIGS"			}
else if (option ~ /^PLATFORM_NO_4BYTE_UTF8/)	{oput="PLATFORM_NO_4BYTE_UTF8";		var="gtm_platform_no_4byte_utf8"	}
else if (option ~ /^PLATFORM_JAVA/)		{oput="PLATFORM_JAVA";			var="gtm_test_java_support"		}
else if (option ~ /^PLATFORM_NOJAVA/)		{oput="PLATFORM_NOJAVA";		var="gtm_test_java_support"		}
else if (option ~ /^MM_FILE_EXT/)	{oput="MM_FILE_EXT";	var="gtm_platform_mmfile_ext"	}
else if (option ~ /^MM_FILE_NO_EXT/)	{oput="MM_FILE_NO_EXT";	var="gtm_platform_mmfile_ext"	}
else if (option ~ /^ENCRYPT/)           {oput="ENCRYPT";	var="test_encryption"		}
else if (option ~ /^NON_ENCRYPT/)	{oput="NON_ENCRYPT";	var="test_encryption"		}
else if (option ~ /^TRIGGER/)           {oput="TRIGGER";		var="gtm_test_trigger"		}
else if (option ~ /^NOTRIGGER/)		{oput="NOTRIGGER";		var="gtm_test_trigger"		}
else if (option ~ /^TLS/)           	{oput="TLS";			var="gtm_test_tls"		}
else if (option ~ /^NOTLS/)           	{oput="NOTLS";			var="gtm_test_tls"		}
else if (option ~ /^SPANNING_REGIONS/)		{oput="SPANNING_REGIONS";	var="gtm_test_spanreg"	}
else if (option ~ /^NONSPANNING_REGIONS/)	{oput="NONSPANNING_REGIONS";	var="gtm_test_spanreg"	}
else {oput = option; var="NULL"}

#print "#<"option "_"var "_"oput
if (result=="option_name") return var
if (result=="correct") return oput

	}
