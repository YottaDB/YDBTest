#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
BEGIN {
        env["tst_dir"] = ENVIRON[ "tst_dir" ]
	env["tst_general_dir"] = ENVIRON[ "tst_general_dir" ]
	env["tst_working_dir"] = ENVIRON[ "tst_working_dir" ]
        env["tst_remote_dir"] = ENVIRON[ "tst_remote_dir" ]
	env["test_path_comp"] = ENVIRON[ "test_path_comp" ]
	env["tst_remote_dir_gtcm"] = ENVIRON[ "tst_remote_dir_gtcm" ]
	split(env["tst_remote_dir_gtcm"], dir_gtcm_array," ")
	for (i in dir_gtcm_array) dir_gtcm_array[i]=dir_gtcm_array[i] env["test_path_comp"]
        env["tst_out_path"] = ENVIRON[ "tst_out_path" ]
	env["testname"] = ENVIRON[ "testname" ]
        env["tst"] = env["testname"]; gsub(/_[0-9][0-9]*/,"",env["tst"])
	env["gtm_tst"] = ENVIRON[ "gtm_tst" ]
	env["in_test_path"]=env["gtm_tst"] "/" env["tst"]
	env["gtm_exe"] = ENVIRON[ "gtm_exe" ]
	env["gtm_exe_realpath"] = ENVIRON[ "gtm_exe_realpath" ]
	env["gtm_root"] = ENVIRON[ "gtm_root" ]
	env["gtm_src"] = ENVIRON[ "gtm_src" ]
	env["home"] = ENVIRON[ "HOME" ]
	env["tst_org_host"] = ENVIRON[ "tst_org_host" ]
	env["tst_remote_host"] = ENVIRON[ "tst_remote_host" ]
	env["tst_remote_host_ms_1"] =  ENVIRON[ "tst_remote_host_ms_1" ]
	env ["tst_remote_host_ms_2"] = ENVIRON[ "tst_remote_host_ms_2" ]
	env["tst_gtcm_server_list"] = ENVIRON["tst_gtcm_server_list"]
	split(env["tst_gtcm_server_list"],server_list_array," ")
	env["remote_test_path"] = ENVIRON[ "remote_test_path" ]
	env["remote_gtm_exe"] = ENVIRON[ "remote_gtm_exe" ]
	env["gt_ld_shl_suffix"] = ENVIRON[ "gt_ld_shl_suffix" ]
	sub(/\./,"\\.",env["gt_ld_shl_suffix"]); # escape the .
	# Don't want any empty strings
	for (var in env)
	{
		if ("" == env[var]) env[var]="iMpOsSiBbLe"
		#print "VAR:" var "===="env[var]
	}
    }
	       {
	       replace_flags()
		###########################################
		#GT.CM dbcreate
		if ($0 ~/Create database on GT.CM Servers/)
		{
			print $0 #Create database on GT.CM Servers
			getline; replace_flags();
			printed_one_set=0;
			do {
				#till the GT.CM chunk is over
				if (! printed_one_set) print "##GT.CM##" $0;
				if ($0 ~ /Using: .*mupip/) {printed_one_set++}
				getline; replace_flags();
			} while ($0 !~ /Create local .client. database/)
		}
		###########################################
		#GT.CM dbcheck
		if ($0 ~/Check the databases on the GT.CM Servers.../)
		{
			print; #Check the databases on the GT.CM Servers...
			getline; replace_flags();
			printed_one_set=-1;
			if ($0 !~ /Check local .client. database/)
				do {
					replace_flags();
					#till the GT.CM chunk is over
					if (0 >= printed_one_set)
					{
					print "##GT.CM##" $0;
					if ($0 ~ /No errors detected by integ/) printed_one_set=1;
					}
				} while (((getline) > 0 ) &&  ($0 !~ /Check local .client. database/))

		}
		###########################################
	       print;
	       }
function replace_flags()
{
	gsub(env["tst_working_dir"], "##TEST_PATH##")
	gsub(env["in_test_path"], "##IN_TEST_PATH##")
	gsub(env["gtm_exe"], "##SOURCE_PATH##")
	gsub(env["home"], "##HOME_PATH##")
	gsub(env["gtm_tst"]"/com", "##TEST_COM_PATH##")
	gsub(env["remote_gtm_exe"], "##REMOTE_SOURCE_PATH##")
	gsub(env["remote_test_path"], "##REMOTE_TEST_PATH##")
	gsub(env["gtm_exe_realpath"], "##SOURCE_REALPATH##")
	tosub="\\y"env["tst_org_host"]"\\y" ; gsub(tosub, "##TEST_HOST##")
	tosub="\\y"env["tst_remote_host"]"\\y" ; gsub(tosub, "##TEST_REMOTE_HOST##")
	tosub="\\y"env["tst_remote_host_ms_1"]"\\y" ; gsub(tosub, "##TEST_REMOTE_HOST_MS_1##")
	tosub="\\y"env["tst_remote_host_ms_2"]"\\y" ; gsub(tosub, "##TEST_REMOTE_HOST_MS_2##")
	gsub(env["tst_gtcm_server_list"], "##TEST_GTCM_SERVER_LIST##")
	gsub(env["gt_ld_shl_suffix"],"##TEST_SHL_SUFFIX##")
	gsub(env["gtm_root"], "##GTM_LIBRARY_PATH##")
	for (i in server_list_array)
	{
		node_name = server_list_array[i]
		sub(/\..*$/,"",node_name)
		node_path = node_name ":" dir_gtcm_array[i]
		gsub(node_path, "##TEST_REMOTE_NODE_PATH_GTCM##")
		tosub="\\y"server_list_array[i]"\\y"
		gsub(tosub, "##TEST_REMOTE_HOST_GTCM##")
		gsub(dir_gtcm_array[i], "##TEST_REMOTE_PATH_GTCM##")
	}
	#		 if ($0 ~ /^Previous journal file .*\/[a-z0-9]*.mjl_[0-9][0-9]*(_[0-9]|[0-9]) closed$/)
	if ($0 ~ /\.mjl_[0-9][0-9]*(_[0-9][0-9]*|[0-9])/)
	{
		gsub(/mjl_[0-9][0-9]*(_[0-9][0-9]*|[0-9])/,"mjl_[0-9]*(_[0-9][0-9]*|[0-9])");
		$0="##TEST_AWK"$0;
	}
	if ($0 ~ /\.mjf_[0-9][0-9]*(_[0-9][0-9]*|[0-9])/)
	{
		gsub(/mjf_[0-9][0-9]*(_[0-9][0-9]*|[0-9])/,"mjf_[0-9]*(_[0-9][0-9]*|[0-9])");
		$0="##TEST_AWK"$0;
	}
	if ($0 ~ /\.lost_[0-9][0-9]*(_[0-9][0-9]*|[0-9])/)
	{
		gsub(/lost_[0-9][0-9]*(_[0-9][0-9]*|[0-9])/,"lost_[0-9]*(_[0-9][0-9]*|[0-9])");
		$0="##TEST_AWK"$0;
	}
	if ($0 ~ /\.broken_[0-9][0-9]*(_[0-9][0-9]*|[0-9])/)
	{
		gsub(/broken_[0-9][0-9]*(_[0-9][0-9]*|[0-9])/,"broken_[0-9]*(_[0-9][0-9]*|[0-9])");
		$0="##TEST_AWK"$0;
	}
	#if ($0 ~ /^.YDB-I-FILERENAME, File .*\/[a-z0-9]*.mjl is renamed to .*\/[a-z0-9]*.mjl_[0-9][0-9]*(_[0-9][0-9]*|[0-9])$/)
	#{
	#	gsub(/mjl_[0-9][0-9_]*(_[0-9][0-9]*|[0-9]*)/,"mjl_[0-9]*(_[0-9][0-9]*|[0-9])");
	#	$0="##TEST_AWK"$0;
	#}
	if ($0 ~ /^%YDB-I-MUJNLSTAT, .* at /)#initial processing at Wed Mar 12 09:48:17 2003
	{
		gsub(/ at .*/," at ... ... .. ..:..:.. 20..");
		$0="##TEST_AWK"$0;
	}
	#Date/Time       07-OCT-2003 11:35:26 [$H = 59449,41726]
	if ( $0 ~ /^Date\/Time[ ]*[0-9][0-9]-[A-Z][A-Z][A-Z]-[0-9][0-9][0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9] ..H = [5-9][0-9][0-9][0-9][0-9],[0-9]+.$/)
	{
		$0="##TEST_AWKDate/Time       [0-9][0-9]-[A-Z][A-Z][A-Z]-[0-9][0-9][0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9] ..H = [5-9][0-9][0-9][0-9][0-9],[0-9]+."
	}
	# Online RollBack #"%YDB-I-IPCNOTDEL, Mon Dec  5 14:04:34 2011 : Mupip journal process did not delete IPC resources for region AREG"
	if ($0 ~ /^%YDB-I-IPCNOTDEL, /)
	{
		gsub (/[A-Z][aeiounhdrn]+ [A-Z][abcelmnopruv]+ [ 12][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9] 20[0-9][0-9]/,"... ... .. ..:..:.. 20..");
		$0="##TEST_AWK"$0;
	}

}
