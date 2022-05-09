#################################################################
#								#
# Copyright 2006, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
BEGIN{
	print "#!/usr/local/bin/tcsh -f"
	print "set echo"
	print "set verbose"
	print "echo 'The command to get executed is "arguments"'"
	print "setenv save_working_dir `pwd`"
	split(arguments,arg_list," ");
	ins_cnt = host_cnt = link_cnt = cmd_cnt = rcvcnt = 1;
	srand()
}
FILENAME ~ /msr_instance_config.txt/ {
	if ($0 ~ /^[ 	]*#/) next;	#skip comment lines
	# let's get all env. configuration details before going into replic action
	if ( "INST" == substr($1,1,4) )
	{
		ins_details[ins_cnt] = $0;
		dollar1[ins_cnt] = $1;
		dollar2[ins_cnt] = $2;
		dollar3[ins_cnt] = $3;
		if (! instinfo_version[$1])
			instinfo_version[$1] = instinfo_version["INST1"] # version information might not be present for all instances
		if (! instinfo_image[$1])
			instinfo_image[$1] = instinfo_image["INST1"]	 # image information might not be present for all instances
		if ($2 ~ /INSTNAME:/)	instinfo_instname[$1] = $3;
		if ($2 ~ /VERSION:/)	instinfo_version[$1] = $3;
		if ($2 ~ /IMAGE:/)	instinfo_image[$1] = $3;
		if ($2 ~ /DBDIR:/)
		{
			instinfo_dbdir[$1] = $3;
			instinfo_jnldir[$1] = instinfo_dbdir[$1]	 # jnldir info might not be present for all instances if it is equal to the dbdir
		}
		if ($2 ~ /JNLDIR:/) 	instinfo_jnldir[$1] = $3;
		if ($2 ~ /BAKDIR:/)	instinfo_bakdir[$1] = $3;
		if ($2 ~ /HOST:/) 	instinfo_host[$1] = $3;
		if ($2 ~ /PORTNO:/)	instinfo_portno[$1] = $3;
		ins_cnt++;
	}
	# keep a separate array for HOST related information to iterate later
	else
	{
		host_details[host_cnt] = $0
		host_field1[host_cnt] = $1;
		host_field2[host_cnt] = $2;
		host_field3[host_cnt] = $3;
		if ($2 ~ /NAME:/) hostinfo_name[$1] = $3;
		tmpstr = $0;
		gsub(/.*[A-Z][A-Z]*:[ 	]*/,"",tmpstr);
		if ($2 ~ /GETENV:/) hostinfo_getenv[$1] = tmpstr;
		if ($2 ~ /SHELL:/) hostinfo_shell[$1] = tmpstr;
		host_cnt++;
	}
}
FILENAME ~ /msr_active_links.txt/ {
	if ($0 ~ /^[ 	]*#/) next;	#skip comment lines
	# let's get all current link details before setting up new ones
	alllinks[link_cnt] = $0;
	col1[link_cnt] = $1;
	col2[link_cnt] = $2;
	col3[link_cnt] = $3;
	# keep a list of instances that are being sourced to - to be used down the line for SYNC task
	if ( "ACTIVE_LINKS_SRCTO" == $1 ) all_srcs = $3" "all_srcs
	link_cnt++;
}
FILENAME ~ /multisite_action_command.lis/ {
	# we can as well get the particular command from the action here itself but sometimes some action
	# needs to be broken down to sub-action level  and then be fetched for proper command.
	if ($0 ~ /^[ 	]*#/) next;	#skip comment lines
	cmd_list[cmd_cnt] = $0;
	cmd_list_1[cmd_cnt] = $1;
	cmd_cnt++;
	action = $1;
	sub("^"action"[ 	]*","");
	cmd_listassoc[action] = $0;
}
END{
	# we will have a separate function call for RUN command as this is a versatile option that could be used
	# by other multisite action as well.
	if ("RUN" == arg_list[1]) run_multisite_action();
	else do_multisite_action(arg_list[1]);
	print "cd $save_working_dir"
	# at the end of each multisite run these variables has to be made sure they are unset and next run starts afresh
	print "unsetenv inside_multisite_replic gtm_test_instsecondary gtm_test_rp_pp"
	print "unset echo"
	print "unset verbose"
	print "exit $action_status"
}
function coin_flip()
{	# Coin Flip : randomly return 0 or 1
	return (0 + int(rand() * 2))
}
function ver_no_supp(ver)
{
	# return 1 if ver is less then v5.5-000 (the version that provided supplementary instances)
	return (ver < "V55000")
}
function rp_pp(arg, envstr, version)
{	# Set envstr for either rootprimary or propagateprimary, depending on arg.  The qualifier used is randomly chosen.
	# Return 0 if arg's value is not supported.
	if ( "PP" == arg )
	{
		if (coin_flip() || ver_no_supp(version)) print "setenv " envstr " '-propagateprimary'"
		else print "setenv " envstr " '-updnotok'"
	}
	else if ("RP" == arg )
	{
		if (coin_flip() || ver_no_supp(version)) print "setenv " envstr " '-rootprimary'"
		else print "setenv " envstr " '-updok'"
	}
	else return 0
	return 1
}
function run_multisite_action()
{
	cnt = 2
	# first get the command to be run from the argument list
	command = arguments
	while ( "" != arg_list[cnt] )
	{
		if ( 0 != index(arg_list[cnt],"SRC") || 0 != index(arg_list[cnt],"RCV") || 0 != index(arg_list[cnt],"INST") )
		{
			sub(arg_list[cnt],"",command);
		}
		else
		{
			sub("RUN","",command);
			break
		}
		cnt++
	}
	# check if we need a filter for the command
	if ( 0 != index(command,"__") )
	{
		pass_action = "setvar"
	}
	if ( substr(arg_list[2],1,3) == "SRC" ) at_inst = pass_src = substr(arg_list[2],5,10)
	if ( substr(arg_list[2],1,3) == "RCV" ) at_inst = pass_rcvr = substr(arg_list[2],5,10)
	if ( substr(arg_list[2],1,5) == "INST=" ) at_inst = pass_src = substr(arg_list[2],6,10)
	if ( substr(arg_list[2],1,4) == "INST" && 0 == index(arg_list[2],"=") ) at_inst = pass_src = arg_list[2]
	if ( substr(arg_list[3],1,3) == "SRC" ) pass_src = substr(arg_list[3],5,10)
	if ( substr(arg_list[3],1,3) == "RCV" ) pass_rcvr = substr(arg_list[3],5,10)
	if ( ("" == at_inst) || ("" == pass_src && "" == pass_rcvr) )
	{
		error_reports("arguments supplied to RUN are suspect, cannot decide on the instance and action");
	}
	REPLIC_ENVIRON(pass_src,pass_rcvr,pass_action,command)
	if ( 0 != match(command,"__") ) error_reports("RUN command still has some un-filtered values.Pls. check config files,the command still is "command);
	cd_execute(at_inst);
}
function do_multisite_action(task)
{
	# flag to check in some tests whether are we taking the MULTISITE route or not.
	print "setenv inside_multisite_replic"
	if ( "START" == task )
	{
		# setup primary and secondary env. here
		REPLIC_ENVIRON(arg_list[2],arg_list[3]);
		if ("needupdatersync" in ENVIRON) print "setenv needupdatersync \"" ENVIRON["needupdatersync"]"\""
		rp_pp(arg_list[4], "gtm_test_rp_pp",instinfo_version[arg_list[2]])
		# update active links information here
		update_links_add(arg_list[2],arg_list[3],"BOTH")
		print "setenv add_update_port"
		repl_state(task)
	}
	else if ( "STARTRCV" == task || "STARTSRC" == task )
	{
		REPLIC_ENVIRON(arg_list[2],arg_list[3]);
		gen_upd_portno(arg_list[2],arg_list[3]);
		if ("needupdatersync" in ENVIRON) print "setenv needupdatersync \"" ENVIRON["needupdatersync"]"\""
		# if gtm_test_repl_skipsrcchkhlth is in the environment make available on source side (in case test is multi host and src instance is not INST1)
		if ( "STARTSRC" == task && "gtm_test_repl_skipsrcchkhlth" in ENVIRON ) print "setenv gtm_test_repl_skipsrcchkhlth"
		# if gtm_test_repl_skiprcvrchkhlth is in the environment make available on receiver side (in case test is multi host)
		if ( "STARTRCV" == task && "gtm_test_repl_skiprcvrchkhlth" in ENVIRON ) print "setenv gtm_test_repl_skiprcvrchkhlth"
		# if gtm_tst_ext_filter_rcvr is in the environment make available in remote host
		if ( "STARTRCV" == task && "gtm_tst_ext_filter_rcvr" in ENVIRON ) print "setenv gtm_tst_ext_filter_rcvr \"" ENVIRON["gtm_tst_ext_filter_rcvr"]"\""
		# if gtm_tst_ext_filter_src is in the environment make available in remote host
		if ( "STARTRCV" == task && "gtm_tst_ext_filter_src" in ENVIRON ) print "setenv gtm_tst_ext_filter_src \"" ENVIRON["gtm_tst_ext_filter_src"]"\""
		# the below condn check is for STARTSRC action
		rp_pp(arg_list[4], "gtm_test_rp_pp",instinfo_version[arg_list[2]])
		update_links_add(arg_list[2],arg_list[3],substr(task,6,3))
		repl_state(task)
	}
	else if ( "STOPRCV" == task )
	{
		REPLIC_ENVIRON(arg_list[2],arg_list[3])
		update_links_del("RCVR",arg_list[3],arg_list[3])
		del_upd_portno(arg_list[3],"SRC",arg_list[3]) # yes check whether src is live to delete the port
		repl_state(task)
	}
	else if ( "STOPSRC" == task)
	{
		REPLIC_ENVIRON(arg_list[2],arg_list[3]);
		update_links_del("SRC",arg_list[2],arg_list[3]);
		del_upd_portno(arg_list[3],"RCV",arg_list[3]) # yes check whether rcv is live to delete the port
		repl_state(task)
	}
	else if ( "STOP" == task || "CRASH" == task )
	{
		if ( ("INST" == substr(arg_list[2],1,4) ) && ("INST" == substr(arg_list[3],1,4) ) ) # which means arg = link
		{
			# in case of stop a single call to RF_SHUT here will be enough as shutdown
			# now has the capability to shutdown both passive and active servers.
			# In our case here it will shut down the passive instance.
			REPLIC_ENVIRON(arg_list[2],arg_list[3]);
			update_links_del("BOTH",arg_list[2],arg_list[3]);
			print "setenv del_update_port "arg_list[3]
		}
		else if ( "INST" == substr(arg_list[2],1,4)  ) # which means arg = instance
		{
			task = stop_or_crash_action(arg_list[2],task);
		}
		else if ( "ALL_LINKS" == arg_list[2] )
		{
			# calling it quits here. stop all replication instances of the system
			loop_thro_all(task)
			# Before returning print a null in the links file to indicate all washed out
			print "" > "msr_links_temp.txt"
			print "setenv close_all_ports"
			return;
		}
		repl_state(task)
	}
	else if ( "CRASHGTM" == task )
	{
		# this action might not be trigerred at all in multisite scenario
		# so the command to be executed will be removed from multisite_action_command.lis
		cd_execute(arg_list[2]) # switch to the instance that needs to be crashed.
		# No need for setting environment for this task
		# should we update the links as we just crashed GTM?
		# may not be necessary as the replic serves might still be running
	}
	else if ( "SYNC" == task )
	{
		if ( "INST" == substr(arg_list[2],1,4) && "INST" == substr(arg_list[3],1,4) )
		{
			REPLIC_ENVIRON(arg_list[2],arg_list[3]);
		}
		else if ( "ALL_LINKS" == arg_list[2] )
		{
			loop_thro_all_sync(task)
			return;
		}
		else error_reports("SYNC action not called with proper arguments or instances.pls. check the call");
	}
	else if ( "CHECKHEALTH" == task || "SHOWBACKLOG" == task )
	{
		REPLIC_ENVIRON(arg_list[2],arg_list[3]);
	}
	else if ( "ACTIVATE" == task )
	{
		REPLIC_ENVIRON(arg_list[2],arg_list[3]);
		if (0 == rp_pp(arg_list[4], "msr_activate_type",instinfo_version[arg_list[2]])) print "setenv msr_activate_type"
		gen_upd_portno(arg_list[2],arg_list[3]);
		update_links_add(arg_list[2],arg_list[3],"SRC");
	}
	else if ( "EXTRACT" == task )
	{
		if ( "ALL" == arg_list[2] )
		{
			ii = 1;
			while ( "" != ins_details[ii] )
			{
				if ( "DBDIR:" == dollar2[ii] ) tmp_dollar1 = tmp_dollar1" "dollar1[ii]
				ii++;
			}
			tot_ins = tmp_dollar1;
		}
		else
		{
			tot_ins = arguments;
			gsub("EXTRACT","",tot_ins);
		}
		print "setenv msr_inst_list \""tot_ins"\""
	}
	else if ( "REFRESHLINK" == task )
	{
		REPLIC_ENVIRON(arg_list[2],arg_list[3])
		# msr_links_temp needs to be touched for msr to recognize active links changes
		print "" > "msr_links_temp.txt"
		print "setenv pri_node "arg_list[2]
		print "setenv sec_node "arg_list[3]
	}
	if ( 0 != index(arguments,"RESERVEPORT") ) print "setenv dont_release_port"
	#  fetch the all important command for a given task here!
	FETCH_COMMAND(task)
	print "set action_status = $status"
	print "setenv gtmroutines \"$gtmroutines_saved\""
}
function REPLIC_ENVIRON(srcstr, rcvstr, actstr, cmdstr)
{
	srchost = instinfo_host[srcstr];
	rcvhost = instinfo_host[rcvstr];
	if (0 == instinfo_getenv[srcstr])
	{
		instinfo_getenv[srcstr] = hostinfo_getenv[srchost];
		sub(/CUR_DIR/,instinfo_dbdir[srcstr],instinfo_getenv[srcstr]);
	}
	if (0 == instinfo_getenv[rcvstr])
	{
		instinfo_getenv[rcvstr] = hostinfo_getenv[rcvhost];
		sub(/CUR_DIR/,instinfo_dbdir[rcvstr],instinfo_getenv[rcvstr]);
	}
	srchostname = hostinfo_name[srchost]
	rcvhostname = hostinfo_name[rcvhost]
	srchostname_short = srchostname; sub(/\..*/, "", srchostname_short)
	rcvhostname_short = rcvhostname; sub(/\..*/, "", rcvhostname_short)
	if (1 != ENVIRON["host_ipv6_support_" srchostname_short])
		rcvhostname = rcvhostname_short
	if (1 != ENVIRON["host_ipv6_support_" rcvhostname_short])
		srchostname = srchostname_short
	cmdstr = print_or_set("PRI_DIR,PRI_SIDE", "__SRC_DIR__", instinfo_dbdir[srcstr], actstr, cmdstr);
	cmdstr = print_or_set("test_jnldir", "__SRC_JNLDIR__", instinfo_jnldir[srcstr], actstr, cmdstr);
	cmdstr = print_or_set("test_bakdir", "__SRC_BAKDIR__", instinfo_bakdir[srcstr], actstr, cmdstr)
	cmdstr = print_or_set("gtm_test_cur_pri_name", "__SRC_INSTNAME__", instinfo_instname[srcstr], actstr, cmdstr)
	cmdstr = print_or_set("dummy_port", "__SRC_PORTNO__", instinfo_portno[srcstr], actstr, cmdstr)
	cmdstr = print_or_set("tst_now_primary", "__SRC_HOST__", srchostname, actstr, cmdstr)
	cmdstr = print_or_set("pri_ver", "__SRC_VERSION__", instinfo_version[srcstr], actstr, cmdstr)
	cmdstr = print_or_set("pri_image", "__SRC_VERSION__", instinfo_image[srcstr], actstr, cmdstr)
	cmdstr = print_or_set("SEC_DIR,SEC_SIDE", "__RCV_DIR__", instinfo_dbdir[rcvstr], actstr, cmdstr)
	cmdstr = print_or_set("test_remote_jnldir", "__RCV_JNLDIR__", instinfo_jnldir[rcvstr], actstr, cmdstr)
	cmdstr = print_or_set("test_remote_bakdir", "__RCV_BAKDIR__", instinfo_bakdir[rcvstr], actstr, cmdstr)
	cmdstr = print_or_set("gtm_test_cur_sec_name", "__RCV_INSTNAME__", instinfo_instname[rcvstr], actstr, cmdstr)
	cmdstr = print_or_set("portno", "__RCV_PORTNO__", instinfo_portno[rcvstr], actstr, cmdstr)
	cmdstr = print_or_set("tst_now_secondary", "__RCV_HOST__", rcvhostname, actstr, cmdstr)
	cmdstr = print_or_set("remote_ver", "__RCV_VERSION__", instinfo_version[rcvstr], actstr, cmdstr)
	cmdstr = print_or_set("remote_image", "__RCV_VERSION__", instinfo_image[rcvstr], actstr, cmdstr)
	# host details
	cmdstr = print_or_set("pri_shell", "DUMMY", hostinfo_shell[srchost], actstr,cmdstr);
	if ( (0 != index(instinfo_getenv[srcstr],"remote_getenv.csh")) )
	{
		cmdstr = print_or_set("pri_getenv", "DUMMY",instinfo_getenv[srcstr],actstr,cmdstr);
	}
	else
	{
		# pri_getenv can only be pri_getenv.csh and so the value is hard-coded.
		# pri_ver will get set for that instance beforehand
		cmdstr = print_or_set("pri_getenv", "DUMMY","source $gtm_tst/com/pri_getenv.csh $pri_ver $pri_image",actstr,cmdstr);
	}
	cmdstr = print_or_set("sec_shell", "DUMMY", hostinfo_shell[rcvhost], actstr,cmdstr);
	# for sec_getenv it cannot be pri_getenv.csh. Due to fail-over and differing versions we will have
	# msr reporting pri_getenv.csh for it sometimes. so lets avoid those cases
	if ( (0 != index(instinfo_getenv[rcvstr],"pri_getenv.csh")) ) instinfo_getenv[rcvstr] = "source $gtm_tst/com/getenv.csh"
	cmdstr = print_or_set("sec_getenv", "DUMMY", instinfo_getenv[rcvstr], actstr,cmdstr);
}
function print_or_set(printstr, setstr, value, action, str_cmd)
{
	if ("" == value)
	{
		return str_cmd;
	}
	for(j = 1;j <= split(printstr,arr,",");j++)
	{
		if ("portno" == arr[j]) print "setenv "arr[j]" \""value"\" # portno before below msr action";
		else print "setenv "arr[j]" \""value"\""
	}
	if ( "setvar" == action )
	{
		# filter the constants in the command here
		sub(setstr,value,str_cmd);
		# actual command gets modified , filters one/one and gets set here
		command = str_cmd;
		return str_cmd;
	}
}
function update_links_add(arg1, arg2, arg3)
{
	srcto = "init";
	rcvfrom = "init";
	i = 1;
	while ( alllinks[i] != "" )
	{
		if ( ("SRC" == arg3 || "BOTH" == arg3) && ("ACTIVE_LINKS_SRCTO" == col1[i]) )
		{
			if ( (arg1 == col2[i]))
			{
				srcto = "done";
				if (0 == index(col3[i],arg2)) col3[i] = col3[i]","arg2;
			}
		}
		else if ( ("RCV" == arg3 || "BOTH" == arg3) && ("ACTIVE_LINKS_RCVFROM" == col1[i]) )
		{
			if (arg2 == col2[i])
			{
				if ( arg1 != col3[i] )
				{
					error_reports("ACTIVE_LINK-ERROR instance "arg2" receving from more than one host")
				}
				else
				{
					rcvfrom = "done"
				}
			}
		}
		print col1[i]"	"col2[i]"	"col3[i] > "msr_links_temp.txt";
		i++;
	}
	if ( ("SRC" == arg3 || "BOTH" == arg3) && ("init" == srcto) ) print "ACTIVE_LINKS_SRCTO	"arg1"	"arg2 > "msr_links_temp.txt";
	if ( ("RCV" == arg3 || "BOTH" == arg3) && ("init" == rcvfrom) ) print "ACTIVE_LINKS_RCVFROM	"arg2"	"arg1 > "msr_links_temp.txt";
}
function update_links_del(type, arg1, arg2)
{
	i = 0;
	while ( alllinks[i+1] != "" )
	{
		i++;
		if ( "RCVR" == type || "BOTH" == type )
		{
			# just delete the straight forward rcvfrom link
			if ( "ACTIVE_LINKS_RCVFROM" == col1[i] && col2[i] == arg2 ) continue;
		}
		if ("SRC" == type || "BOTH" == type )
		{
			# just delete straight forward srcto link
			if ( "ACTIVE_LINKS_SRCTO" == col1[i] && col2[i] == arg1 )
			{
				if ( 0 == index(col3[i],",") || arg1 == arg2 || "" == arg2 ) continue;
				# we need to consider the third column here which could be comma separated
				# with many instances. Just unplug the one we are interested in
				aa = col3[i] # preserve col' arrays
				if ( 1 == index(aa,arg2) ) sub(arg2",","",aa)
				else sub(","arg2,"",aa)
				print col1[i]"	"col2[i]"	"aa > "msr_links_temp.txt";
				continue;
			}
		}
		null_flag = 0;
		print col1[i]"	"col2[i]"	"col3[i] > "msr_links_temp.txt";
	}
	# a null set necessary for further processing. It just creates an empty link file to state all links as gone.
	if ( "" == null_flag ) print "" > "msr_links_temp.txt"
}
function stop_or_crash_action(rcvd_inst, rcvd_act)
{
	# this is because SRC_SHUT/RCVR_SHUT.csh expects instsec to be null for this case so as to shutdown all sources
	print "setenv gtm_test_instsecondary"
	# first identify who this instance is - source (RP or PP) or receiver or both etc.
	output = identify(rcvd_inst);
	if ( index(output,"RCVR") && index(output,"SRC") ) # this is an instance that acts both as a receiver and source (propagate)
	{
		# here is a cheeky way, we will make this action as STOPRCV here inspite of knowing both source
		# and receiver needs to be stopped  as instsecondary will be null and that will shut down
		# all source servers not just passive in RF_SHUT.csh
		REPLIC_ENVIRON(rcvd_inst,rcvd_inst);
		update_links_del("BOTH",rcvd_inst,rcvd_inst);
		del_upd_portno(rcvd_inst,"SRC",rcvd_inst); # this is to identify any active srcto links for the receiver
		del_upd_portno(rcvd_inst,"CRASHSRC",""); # this is a recursive logic to identify active rcvfrom links for the source
		task = "STOPRCV";
	}
	else if ( index(output,"RCVR") && !(index(output,"SRC")) ) # this is just a receiver instance
	{
		if ( "STOP" == rcvd_act )
		{
			task = "STOPRCV"
			REPLIC_ENVIRON("DUMMY",rcvd_inst);
		}
		else if ( "CRASH" == rcvd_act )
		{
			# This is because for CRASH action we decided to call primary_crash only from our
			# current test system and so PRI_SIDE has to be defined for this action
			REPLIC_ENVIRON(rcvd_inst,"DUMMY");
			task = "CRASH"
		}
		update_links_del("RCVR",rcvd_inst,rcvd_inst);
		del_upd_portno(rcvd_inst,"SRC",rcvd_inst); # to identify active srcto links
	}
	else if ( index(output,"SRC") && !(index(output,"RCVR")) ) # this is a source instance
	{
		REPLIC_ENVIRON(rcvd_inst,"DUMMY");
		if ( "STOP" == rcvd_act ) task = "STOPSRC"
		else if ( "CRASH" == rcvd_act ) task = "CRASH"
		update_links_del("SRC",rcvd_inst,rcvd_inst);
		del_upd_portno(rcvd_inst,"CRASHSRC",""); # call recursive rcvfrom links check to determine active receivers if any
	}
	return task;
}
function identify(whoami)
{
	i = 1;
	while (alllinks[i] != "")
	{
		if ( "ACTIVE_LINKS_RCVFROM" == col1[i] && col2[i] == whoami ) str = str"RCVR@"
		else if ( "ACTIVE_LINKS_RCVFROM" == col1[i] && col3[i] == whoami ) str = str"SRC"
		else if ( "ACTIVE_LINKS_SRCTO" == col1[i] && col2[i] == whoami ) str = str"SRC@"
		else if ( "ACTIVE_LINKS_SRCTO" == col1[i] && (index(col3[i],whoami ))) str = str"RCVR"
		i++;
	}
	if ( "" == str ) error_reports("Cannot find who this instance is! Conditions are not met for "whoami" pls check current links logs")
	else if ( 0 == index(str,"@") ) error_reports("The instance "whoami" is not alive at this point in time,the requested action cannot be carried out")
	return str;
}
function cd_execute(inststr)
{
	print "unset echo"
	print "unset verbose"
	print "echo \"-----##############################################----\""
	hst = instinfo_host[inststr]
	# for RUN we do a remote_ver set followed by getenv.csh, so stick to that always
	if ( (0 != index(instinfo_getenv[inststr],"pri_getenv.csh")) ) instinfo_getenv[inststr] = "source $gtm_tst/com/getenv.csh"
	# keep the three ;;; pattern here this is useful for multiple host scenarios when we need to determine the directory
	# to copy the env_suppl information file
	print hostinfo_shell[hst]" 'setenv remote_ver "instinfo_version[inststr]"; setenv remote_image "instinfo_image[inststr]"; "instinfo_getenv[inststr]"; setenv remote_ver "instinfo_version[inststr]"; setenv remote_image "instinfo_image[inststr]"; source $gtm_tst/com/getenv.csh;;;cd "instinfo_dbdir[inststr]";if (-e env_supplementary.csh) source env_supplementary.csh; source $gtm_tst/com/reset_gtmroutines.csh;"command"'"
	print "set action_status = $status"
	return
	if ( "" == instinfo_host[inststr] || "" == instinfo_getenv[inststr] || "" == instinfo_dbdir[inststr] ) error_reports("DBDIR/VERSION cannot be located for "inststr" from the config files");
}
function loop_thro_all(rcvd_task)
{
	print "set action_status = 0"
	loop_i = 1;
	while (alllinks[loop_i] != "" )
	{
		no_action = "FALSE"
		if ( "ACTIVE_LINKS_RCVFROM" == col1[loop_i] )
		{
			if ( "STOP" == rcvd_task )
			{
				REPLIC_ENVIRON(col3[loop_i],col2[loop_i]);
				task = "STOPRCV"
			}
			if ("FALSE" == no_action )
			{
				repl_state(task)
				if ( 0 != index(arguments,"RESERVEPORT") ) print "setenv dont_release_port"
				FETCH_COMMAND(task)
				print "@ action_status = $status + $action_status"
				print "unsetenv gtm_test_instsecondary gtm_test_rp_pp"
			}
		}
		loop_i++;
	}
	# we loop here twice to ensure we process the receiver of anode first before the source in it
	# especially with SHUT scripts on STOP ALL_LINKS we need this mechanism
	loop_i = 1;
	while (alllinks[loop_i] != "" )
	{
		if ( "ACTIVE_LINKS_SRCTO" == col1[loop_i] )
		{
			if ( "STOP" == rcvd_task )
			{
				REPLIC_ENVIRON(col2[loop_i],"DUMMY");
				print "setenv gtm_test_instsecondary"# it's going to shut down all source servers in that node
				task = "STOPSRC"
				repl_state(task)
				if ( 0 != index(arguments,"RESERVEPORT") ) print "setenv dont_release_port"
				FETCH_COMMAND(task)
				print "@ action_status = $status + $action_status"
				print "unsetenv gtm_test_instsecondary gtm_test_rp_pp"
			}
		}
		loop_i++;
	}
}
function loop_thro_all_sync(rcvd_task)
{
	print "set action_status = 0"
	loop_i = 1;
	sortrcvfromlink()
	while (rcvfromlink[loop_i] != "" )
	{
		split(rcvfromlink[loop_i],link);
		no_action = "FALSE"
		if ( 0 == index(all_srcs,link[2]) )
		{
			no_action = "TRUE";
			print arguments >> scriptname"_nosync.out"
			print "echo MSR-I-NOSYNC. Link "link[2]" "link[3]" will not be synced as the source is not alive at this point" >> scriptname"_nosync.out"
		}
		else
		{
			REPLIC_ENVIRON(link[3],link[2]);
			task = rcvd_task;
		}
		if ("FALSE" == no_action )
		{
			repl_state(task)
			FETCH_COMMAND(task)
			print "@ action_status = $status + $action_status"
			print "unsetenv gtm_test_instsecondary gtm_test_rp_pp"
		}
		loop_i++;
	}
}

# "numswaps" is a variable internal only to the below function (i.e. variable scope is just the below function).
# Hence have 4 spaces before it to indicate it is not a function parameter but is an internal variable.
# See https://www.gnu.org/software/gawk/manual/html_node/Variable-Scope.html for more details.
function sortrcvfromlink(    numswaps)
{
	rcvcnt=0
	i=1
	while (alllinks[i] != "")
	{
		if ( ( "ACTIVE_LINKS_RCVFROM" == col1[i] ) && ( 0 != index(all_srcs,col2[i]) ))
		{
			rcvcnt++
			rcvfromlink[rcvcnt] = alllinks[i]
		}
		i++
	}
	# Now sort rcvfromlink array
	numswaps=0
	i=1
	while (rcvfromlink[i] != "")
	{
		split(rcvfromlink[i],linki);
		j = i + 1
		while (rcvfromlink[j] != "")
		{
			split(rcvfromlink[j],linkj);
			if (linki[3] == linkj[2])
			{
				# Current src is a rcv down the line - swap
				# It is possible we have a configuration with a cycle (possible in case the test had
				# some errors resulting in some link lines not being correctly deleted/updated).
				#	ACTIVE_LINKS_RCVFROM	INST1	INST2
				#	ACTIVE_LINKS_RCVFROM	INST2	INST3
				#	ACTIVE_LINKS_RCVFROM	INST3	INST1
				# For example, in the above 3-line configuration, INST1 receives from INST2,
				# INST2 receives from INST3 and INST3 receives from INST1 which is a cycle of length 3.
				# In that case, we have to detect the cycle and stop trying to sort an unsortable array.
				# Hence the check below. We don't expect to have more than N*(N-1) swaps in a bubble-sort
				# like algorithm of N elements (where N is "rcvcnt").
				numswaps++
				if (numswaps > (rcvcnt * (rcvcnt - 1)))
				{	# This is an out-of-design situation. Signal error and exit right away.
					error_reports("msr_active_links.txt ACTIVE_LINKS_RCVFROM cycle detected. Aborting...");
					exit 1
				}
				tmp1=rcvfromlink[i]
				rcvfromlink[i] = rcvfromlink[j] ; rcvfromlink[j]=tmp1
				i=0
				break;
			}
			j++
		}
		i++
	}

}
function gen_upd_portno(srcport_ins, rcvport_ins)
{
	port_flag = ""
	pno = 1;
	while ( "" != alllinks[pno] )
	{
		if ( "ACTIVE_LINKS_RCVFROM	"rcvport_ins"	"srcport_ins == col1[pno]"	"col2[pno]"	"col3[pno] )
		{
			port_flag = "yes"
			break;
		}
		else if ( "ACTIVE_LINKS_SRCTO	"srcport_ins == col1[pno]"	"col2[pno] )
		{
			if ( 0 != index(col3[pno],rcvport_ins) )
			{
				port_flag = "yes"
				break;
			}
		}
		pno++;
	}
	if ( "" == port_flag )
	{
		reserve_flag = check_reserve_portno(rcvport_ins);
		if ("yes" != reserve_flag) print "setenv portno `$sec_shell \"$sec_getenv; cd $SEC_SIDE; source $gtm_tst/com/portno_acquire.csh\"`"
		print "setenv add_update_port"
		print "$sec_shell \"$sec_getenv;echo $portno >&! $SEC_DIR/portno\""
	}
}
function del_upd_portno(inport, deltask, result_port)
{
	del_flag = ""
	pcnt = 1;
	while ( "" != alllinks[pcnt] )
	{
		if ( ("SRC" == deltask) && ("ACTIVE_LINKS_SRCTO" == col1[pcnt]) && (0 != index(col3[pcnt],inport)) )
		{
			del_flag = "no"
			break;
		}
		else if ( ("RCV" == deltask) && ("ACTIVE_LINKS_RCVFROM" ==  col1[pcnt]) && (inport == col2[pcnt]) )
		{
			del_flag = "no"
			break;
		}
		else if ("CRASHSRC" == deltask)
		{
			if ( "ACTIVE_LINKS_SRCTO" == col1[pcnt] && inport == col2[pcnt] )
			{
					split(col3[pcnt],tmp_port,",")
					tmp_cnt = result_cnt = 1;
					while ( "" != tmp_port[tmp_cnt] )
					{
						# recursive call to know the list of dead links
						del_upd_portno(tmp_port[tmp_cnt],"RCV","");
						if ( "" == del_flag ) result_cnt++;
						tmp_cnt++;
					}
					if ( (tmp_cnt-1) == result_cnt ) result_port = inport; # this means all rcvform links are dead
					break; # break the main while itself as the purpose is over by now.
			}
		}
		pcnt++;
	}
	if ( "" == del_flag && "" != result_port ) print "setenv del_update_port "result_port
}
# This function is to check whether any ports are reserved and needs to be reused.
function check_reserve_portno(x)
{
	pno = 1;
	while ( "" != ins_details[pno] )
	{
		if ( (x"	PORTNO:" == dollar1[pno]"	"dollar2[pno]) && ( 0 != match(dollar3[pno],/[1-9]/)) )
		{
			print "setenv portno "dollar3[pno];
			return "yes"
		}
		pno++;
	}
}
function FETCH_COMMAND(xpand_cmd)
{
	# argument processing mechanism
	# This is where we process and pass the additional qualifiers supplied to the msr action
	if ( qual_args == "" )
	{
		qual_cnt = 2
		split(arguments,qual_list," ");
		while ( "" != qual_list[qual_cnt] )
		{
			# filter all the known qualifiers and actions that are not meant to be passed to the software
			if ( (qual_list[qual_cnt] !~ /INST[0-9]/) &&
			     ("ON" != qual_list[qual_cnt]) &&
			     ("OFF" != qual_list[qual_cnt]) &&
			     ("ALL_LINKS" != qual_list[qual_cnt] ) &&
			     ("RP" != qual_list[qual_cnt]) &&
			     ("PP" != qual_list[qual_cnt]) &&
			     ("RESERVEPORT" != qual_list[qual_cnt]) &&
			     ( 0 == index(qual_list[qual_cnt],"-output")) )
			{
				qual_args = qual_args" "qual_list[qual_cnt]
			}
			qual_cnt++;
		}
		print "setenv msr_other_qualifiers \""qual_args"\"";
	}
	print "setenv gtmroutines_saved \"$gtmroutines\""
	print "echo 'COMMAND TO EXECUTE "cmd_listassoc[xpand_cmd]"'"
	print "unset echo"
	print "unset verbose"
	print "echo \"-----##############################################----\""
	print cmd_listassoc[xpand_cmd];
	if ("" == cmd_listassoc[xpand_cmd]) error_reports(xpand_cmd" command requested not found in multisite_action_command.lis file");
}
function repl_state(repl_task)
{
	if ( "STAR" == substr(repl_task,1,4) )
	{
		if ( 0 != match(arguments,/[\t ]+ON/) ) print "setenv msr_repl_state on"
		else if ( 0 != match(arguments,/[\t ]+OFF/) ) error_reports("you are trying to turn off the replication while starting the servers!!")
		else print "setenv msr_repl_state decide"
	}
	else if ( "STOP" == substr(repl_task,1,4) )
	{
		if ( 0 != match(arguments,/[\t ]+OFF/) ) print "setenv msr_repl_state decide"
		else print "setenv msr_repl_state on"
	}
}
function error_reports(message_str)
{
	print "MULTISITE-F-TSSERT "message_str > "msr_error.log"
}
