#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2022 YottaDB LLC and/or its subsidiaries.	#
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
oput=option
if (result=="correct") return oput
if      (option == "BG")			{var="acc_meth"				}
else if (option == "MM")			{var="acc_meth"				}
else if (option == "REPLIC")			{var="test_repl"			}
else if (option == "NON_REPLIC")		{var="test_repl"			}
else if (option == "MULTISITE")			{var="test_repl"			}
else if (option == "SUPPLEMENTARY_AB")		{var="test_replic_suppl_type"		} # Neither servers are Supplementary
else if (option == "SUPPLEMENTARY_AP")		{var="test_replic_suppl_type"		} # Receiver server is Supplementary
else if (option == "SUPPLEMENTARY_PQ")		{var="test_replic_suppl_type"		} # Both servers are Supplementary
else if (option == "BIG_ENDIAN")		{var="gtm_endian"			}
else if (option == "LITTLE_ENDIAN")		{var="gtm_endian"			}
else if (option == "UNICODE_MODE")		{var="gtm_chset"			}
else if (option == "NONUNICODE_MODE")		{var="gtm_chset"			}
else if (option == "REORG")			{var="test_reorg"			}
else if (option == "NON_REORG")			{var="test_reorg"			}
#test_region is not used anymore, it is kept here only for backward compatibility of reference files
else if (option == "SINGLE_REG")		{var="test_region"			}
else if (option == "MULTI_REG")			{var="test_region"			}
else if (option == "GT.M")			{var="test_gtm_gtcm"			}
else if (option == "GT.CM")			{var="test_gtm_gtcm"			}
else if (option == "TP")			{var="gtm_test_tp"			}
else if (option == "NON_TP")			{var="gtm_test_tp"			}
else if (option == "L")				{var="LFE"				}
else if (option == "F")				{var="LFE"				}
else if (option == "E")				{var="LFE"				}
else if (option == "UNNICE")			{var="test_nice"			}
else if (option == "NICE")			{var="test_nice"			}
else if (option == "COLLATION")			{var="test_collation"			}
else if (option == "NON_COLLATION")		{var="test_collation"			}
else if (option == "SETJNL")			{var="gtm_test_jnl"			}
else if (option == "NON_SETJNL")		{var="gtm_test_jnl"			}
else if (option == "NON_NOLINE")		{var="gtm_test_nolineentry"		}
else if (option == "NOLINE")			{var="gtm_test_nolineentry"		}
else if (option == "DBG")			{var="tst_image"			}
else if (option == "PRO")			{var="tst_image"			}
else if (option == "BTA")			{var="tst_image"			}
else if (option == "UTF8")			{var="gtm_test_unicode_support"		}
else if (option == "NON_UTF8")			{var="gtm_test_unicode_support"		}
else if (option == "JNL_BEFORE")		{var="gtm_test_jnl_nobefore"		}
else if (option == "JNL_NOBEFORE")		{var="gtm_test_jnl_nobefore"		}
else if (option == "64BIT_GTM")			{var="gtm_platform_size"		}
else if (option == "32BIT_GTM")			{var="gtm_platform_size"		}
else if (option == "PLATFORM_NO_V4GTM")		{var="gtm_platform_no_V4"		}
else if (option == "PLATFORM_NO_PRIORGTM")	{var="gtm_test_nopriorgtmver"		}
else if (option == "PLATFORM_NO_COMPRESS_VER")	{var="gtm_platform_no_compress_ver"	}
else if (option == "PLATFORM_NO_DSVER")		{var="gtm_platform_no_ds_ver"		}
else if (option == "PLATFORM_NO_GGTOOLSDIR")	{var="gtm_test_noggtoolsdir"		}
else if (option == "PLATFORM_NO_GGUSERS")	{var="gtm_test_noggusers"		}
else if (option == "PLATFORM_NO_GGBUILDDIR")	{var="gtm_test_noggbuilddir"		}
else if (option == "PLATFORM_NO_IGS")		{var="gtm_test_noIGS"			}
else if (option == "PLATFORM_NO_4BYTE_UTF8")	{var="gtm_platform_no_4byte_utf8"	}
else if (option == "PLATFORM_JAVA")		{var="gtm_test_java_support"		}
else if (option == "PLATFORM_NOJAVA")		{var="gtm_test_java_support"		}
else if (option == "MM_FILE_EXT")		{var="gtm_platform_mmfile_ext"		}
else if (option == "MM_FILE_NO_EXT")		{var="gtm_platform_mmfile_ext"		}
else if (option == "ENCRYPT")			{var="test_encryption"			}
else if (option == "NON_ENCRYPT")		{var="test_encryption"			}
else if (option == "TRIGGER")			{var="gtm_test_trigger"			}
else if (option == "NOTRIGGER")			{var="gtm_test_trigger"			}
else if (option == "TLS")			{var="gtm_test_tls"			}
else if (option == "NOTLS")			{var="gtm_test_tls"			}
else if (option == "SPANNING_REGIONS")		{var="gtm_test_spanreg"			}
else if (option == "NONSPANNING_REGIONS")	{var="gtm_test_spanreg"			}
else 						{var="NULL"				}

#print "#<"option "_"var "_"oput
if (result=="option_name") return var

}
