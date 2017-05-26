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
BEGIN { split("file_name n_regions key_size record_size block_size allocation global_buffer_count extension_count reserved_bytes collation_default null_subscripts access_method acc_meth_env journal test_collation test_stdnull_collation test_gtcm qdbrundown freeze defer_allocate epoch_taper lock_space", argmnts, " ")
	# name_override is an argument disguised from the user, used to take the $gtmgbldir definition from the shell if it exists
	# -different_gld is useful on replication tests with multi-region databases:
	#  	instead of a*, b*, c*, d* going to different regions, on the remote directories, they go in pairs: a* and b* to areg, c* and d* to creg, e* and f* to ereg, ...
	fn = "a b c d e f g h i j k l m n o p q r s t u v w x y z"
	FN = toupper(fn);
	split(fn,filenames," ")
	split(FN, FILENAMES," ")
	if (ENVIRON["tst_on_remote"]) tst_on_remote=1
	if (1 == ENVIRON["gtm_test_qdbrundown"]) value["qdbrundown"]="-qdbrundown"
	if (1 == ENVIRON["gtm_test_freeze_on_error"]) value["freeze"]="-inst_freeze_on_error"
	if (0 == ENVIRON["gtm_test_defer_allocate"]) value["defer_allocate"]="-nodefer_allocate"
	if (0 == ENVIRON["gtm_test_epoch_taper"]) value["epoch_taper"]="-noepochtaper"
	value["jnl_prefix"] = "***unspec***"
	value["jnl_suffix"] = "***unspec***"
	value["move"]=1
       }

      { for (i=1;i<=NF;i++)
	   {tmp=$i
	    gsub(/.*=/,"",tmp)
	    if (tmp == $i) tmp="NULL"
	    if ($i ~/-f/) value["file_name"]=tmp
	    else if ($i ~/^-bl/) value["block_size"]=tmp
	    else if ($i ~/^-al/) value["allocation"]=tmp
	    else if ($i ~/^-g/) value["global_buffer_count"]=tmp
	    else if ($i ~/^-e/) value["extension_count"]=tmp
	    else if ($i ~/^-c/) value["collation_default"]=tmp
	    else if ($i ~/^-rec/) value["record_size"]=tmp
	    else if ($i ~/^-res/) value["reserved_bytes"]=tmp
	    else if ($i ~/^-k/) value["key_size"]=tmp
	    else if ($i ~/^-nom/) value["move"]=0
	    # null_subscripts has multiple entries to differentiate from n_reg
	    else if ($i ~/^-nu.*$/) value["null_subscripts"]=tmp
	    else if ($i ~/^-n$/) value["null_subscripts"]="NOVAL"
	    else if ($i ~/^-n=/) value["null_subscripts"]=tmp
	    else if ($i ~/^-nu=/) value["null_subscripts"]=tmp
	    else if ($i ~/^-acc_meth/) value["access_method"]=toupper(tmp)
	    else if ($i ~/^-acc_meth_env/) value["acc_meth_env"]=toupper(tmp)
	    else if ($i ~/^-journal/) value["journal" ++jnl_count]=toupper(tmp)
	    else if ($i ~/^-n_regions/) value["n_regions"]=tmp
	    else if ($i ~/^-qdbrundown/) value["qdbrundown"]="-qdbrundown"
	    else if ($i ~/^-noqdbrundown/) value["qdbrundown"]="-noqdbrundown"
	    else if ($i ~/^-inst_freeze_on_error/) value["freeze"]="-inst_freeze_on_error"
	    else if ($i ~/^-noinst_freeze_on_error/) value["freeze"]="-noinst_freeze_on_error"
	    else if ($i ~/^-test_collation/) value["test_collation"]=tmp
	    else if ($i ~/^-name_override/) value["filename_override"]=tmp
	    else if ($i ~/^-test_gtcm/)  value["test_gtcm"]=tmp
	    else if ($i ~/^-t/)  value["template"]=tmp #template
	    else if ($i ~/^-stdnull/) value["test_stdnull_collation"]="-stdnull"
	    else if ($i ~/^-nostdnull/) value["test_stdnull_collation"]="-nostdnull"
	    else if ($i ~/^-different_gld/) value["different_gld"]=1
	    else if ($i ~/^-jnl_prefix=/) value["jnl_prefix"]=tmp
	    else if ($i ~/^-jnl_suffix=/) value["jnl_suffix"]=tmp
	    else if ($i ~/^-jnl_auto/) value["journal" ++jnl_count]="autoswitchlimit=" tmp
	    else if ($i ~/^-defer_allocate/) value["defer_allocate"]="-defer_allocate"
	    else if ($i ~/^-nodefer_allocate/) value["defer_allocate"]="-nodefer_allocate"
	    else if ($i ~/^-epoch_taper/) value["epoch_taper"]="-epochtaper"
	    else if ($i ~/^-noepoch_taper/) value["epoch_taper"]="-noepochtaper"
	    else if ($i ~/^-lock_space/) value["lock_space"]=tmp
	    else  { value[argmnts[i]]=$i;
		  }
	    }
      }

END {
      if (value["test_gtcm"])
      {
	#if the value is a "x;y,z" x is the local host, this means, just create the regions for that one.y or z must be same as x
	loc_semicolon=index(value["test_gtcm"],";")
	if (loc_semicolon)
	{
		# this is a GT.CM server, nullify all the others.
		this_host=substr(value["test_gtcm"],1,loc_semicolon-1);
		print "#This is a GT.CM server ("this_host"). Only some regions will be here"
		gsub(".*;","",value["test_gtcm"])
		this_is_a_gtcm_server=1
	}
	total_gtcm_serv_no=split(value["test_gtcm"],gtcm_servers,",")
	if (this_is_a_gtcm_server)
		for (serv in gtcm_servers)
			if (!index(gtcm_servers[serv],this_host)) gtcm_servers[serv]=""
	gtcm_serv_no=1
	cur_gtcm_server = gtcm_servers[gtcm_serv_no++]
      }
      default_filename="mumps"
      sub("\\.gld$","",value["filename_override"])
      if (value["filename_override"]!="") default_filename=value["filename_override"]
      if (value["file_name"] !~/..*/ || value["file_name"] ~/\./) value["file_name"]=default_filename
      print "setenv dbname " value["file_name"]
      print "setenv gtmgbldir \"$dbname.gld\""
      print "set timenow = `date +%H_%M_%S`"
      print "set renamecount = 0 ; set rename = \"$timenow\""
      print "if (-e $gtmgbldir) then"
      print "	while ( -e ${gtmgbldir}_$rename)"
      print "		@ renamecount++"
      print "		set rename = \"${timenow}_$renamecount\""
      print "	end"
      print " 	mv $gtmgbldir ${gtmgbldir}_$rename"
      print "endif"
      if (value["move"])
      {
	      print "set datpat = '*.dat'"
	      print "set nonomatch"
	      print "set datfiles = $datpat"
	      print "unset nonomatch"
	      print "if (\"$datfiles\" != \"$datpat\") then"
	      print "	foreach datfile ($datfiles)"
	      print "		mv $datfile ${datfile}_$rename"
	      print "	end"
	      print "endif"
      }
      print "if (($?test_replic) && (-e mumps.repl)) mv mumps.repl mumps.repl_$rename"
      if (value["access_method"] !~ /..*/ || value["access_method"] ~/\./) value["access_method"]=value["acc_meth_env"]
      if (value["access_method"] !~ /..*/ ) value["access_method"]="BG"
      print "setenv acc_meth " value["access_method"]
      #-------- temporary change till GDE works for GLOBAL_BUFFERS for MM   -- nars - 98/02/25_09:05am
      print "set mmglobalbuffs=0"
      #-------- temporary change ends ----------------------------------------------------------------
      #-------- temporary change till GDE works for GLOBAL_BUFFERS for MM   -- nars - 98/02/25_09:05am
      if (value["access_method"] == "MM") { printf "set mmglobalbuffs = "
				       if (value["global_buffer_count"] ~ /..*/ )
					   print value["global_buffer_count"]
				       else
					   print 1024
					   }
      #-------- temporary change ends ----------------------------------------------------------------



      if (value["template"])
	print "#DBCREATE-I-TEMPLATE Will use the file "value["template"] " for \n# template commands, and will not use any of the other settings"
      print "cat << \\_GDE_EOF >>&! dbcreate.gde"
      if (value["template"])
      {
	command1 = "cat "value["template"]
	command2 = "sed -n 's/template.*-segment/change -segment DEFAULT/gp' "value["template"]
	command3 = "sed -n 's/template.*-region/change -region DEFAULT/gp' "value["template"]
	system(command1" ; "command2" ; "command3)
      }

      {	#DEFAULT region
	      if (this_is_a_gtcm_server) cur_gtcm_server = "" ; #local
	      sub(/\.[^:]*:/,":",cur_gtcm_server)
	      print "change -segment DEFAULT -file_name=" cur_gtcm_server value["file_name"] ".dat"
	      if (value["access_method"] ~ /MM/)
		  {
		   if (value["global_buffer_count"] !~/..*/ || value["global_buffer_count"] ~/\./)
			value["global_buffer_count"]=1024
		   }

	      if (! value["template"])
	      print_block("DEFAULT","DEFAULT")
		    if (value["test_collation"]) print "change -region DEFAULT -collation_default=" value["test_collation"]
      }
      # If value["n_regions"] is not an integer, the for loop below would go forever.
      if ( (value["n_regions"] ~ /^[0-9]+$/) && (value["n_regions"]>1) )
	{
	 for (i=1;i<value["n_regions"];i++)
	   {
	    skip=0
	    if (value["test_gtcm"])
	    {
		    if (1 != i) {cur_gtcm_server = gtcm_servers[gtcm_serv_no++]; if (gtcm_serv_no > total_gtcm_serv_no) gtcm_serv_no=1}
		    #print "#Region no:"i " Server:" cur_gtcm_server
		    if ("" == cur_gtcm_server) skip = 1
		    # i=1 means region A, which is going to be local on the original (client) server
		    cur_gtcm_server_hostname = substr(cur_gtcm_server,1,index(cur_gtcm_server,":")-1)
		    # remove any domain bits from the hostname, leaving only the first part, and bracket it
		    if ("" != cur_gtcm_server_hostname)
		    {
			    sub(/\.[^:]*$/,"",cur_gtcm_server_hostname)
			    cur_gtcm_server = cur_gtcm_server_hostname substr(cur_gtcm_server,index(cur_gtcm_server,":"))
		    }
		    #if ((1 != i)&&(cur_gtcm_server_hostname != this_host)) skip = 1
		    if (gtcm_server[i]) skip = 1
		    #print "#XXXa" skip "." cur_gtcm_server "."this_host "." cur_gtcm_server_hostname"."
		    if ((1 == i)&&(this_is_a_gtcm_server)) skip = 1
	    }
	    if (!skip)
	    {
		    if ((1 == i)||(this_is_a_gtcm_server)) cur_gtcm_server = "" #local
		    if (tst_on_remote && value["different_gld"])
		    {
			    print "! different_gld-specified-in-input"	# this output is relied upon by dbcreate_base.csh
			    if (i%2)
			    {
				fname = filenames[i]".dat"
				seg = filenames[i]"seg"
				reg = filenames[i]"reg"
			    }
		    } else
		    {
			    fname = filenames[i]".dat"
			    seg = filenames[i]"seg"
			    reg = filenames[i]"reg"
		    }
		    print "add -name " filenames[i] "* -region="  reg
		    print "add -name " FILENAMES[i] "* -region="  reg
		    if (!(tst_on_remote && value["different_gld"] && !(i%2)))
		    {
			print "add -region " reg " -dyn=" seg
			if ((0 != value["test_gtcm"])&&(i>1))
			{
				   print "add -segment " seg " -file=" cur_gtcm_server fname
				   # to test broken database
				   # print "add -segment " seg " -file=" cur_gtcm_server fname
			} else
				    print "add -segment " seg " -file=" fname
			if (! value["template"])
				    print_block(seg, reg)
			# for all regions but A, change collation
			if (value["test_collation"]) if (i>1) print "change -region " reg " -collation_default=" value["test_collation"]
		    }
	    }
	    }
      }

      print "\\_GDE_EOF"
      print "$gtm_tst/com/usesprgde.csh >> dbcreate.gde"
      print "$convert_to_gtm_chset dbcreate.gde"
      print "$GDE_SAFE @dbcreate.gde"
    }

function print_block(segname,regname){
      if (value["access_method"] == "MM")
      {
	    print_jnl(regname, 0)
	    print_out("access_method", "segment", segname)
	    print "change -region " regname " -nojournal"
      }
      else
	    print_jnl(regname, 1)
      print_out("block_size", "segment",segname)
      print_out("allocation","segment",segname)
      if (value["access_method"] != "MM") print_out("global_buffer_count","segment",segname)
      print_out("extension_count","segment",segname)
      print_out("reserved_bytes","segment",segname)
      print_out("lock_space","segment",segname)
      print_out("record_size","region",regname)
      print_out("key_size","region",regname)
      print_out("collation_default","region",regname)
      if (value["test_stdnull_collation"])
		print "change -region " regname " " value["test_stdnull_collation"]
      major_ver = gensub(/^.*V([0-9])[0-9]+.*/,"\\1","g",ENVIRON["gtm_dist"])
      # QDBRUNDOWN and INST_FREEZE_ON_ERROR options are not available for versions older than V60000
      if (6 <= major_ver)
      {
	  if (value["freeze"])
	      print "change -region " regname " " value["freeze"]
	  if (value["qdbrundown"])
		print "change -region " regname " " value["qdbrundown"]
	  # DEFER_ALLOCATE option is available from V62002
	  if ((6 < major_ver) || (2002 <= gensub(/^.*V[0-9]([0-9]+).*/,"\\1","g",ENVIRON["gtm_dist"])))
	  {
	      if (value["defer_allocate"])
		  print "change -segment " segname " " value["defer_allocate"]
	      if (value["epoch_taper"])
		  print "change -region " regname " " value["epoch_taper"]
	  }
      }
      if  ("NULL" == value["null_subscripts"]) # this NULL has nothing to do with "NULL"_subscripts, it is dbcreate_multi.awk's "NULL"
		value["null_subscripts"]="ALWAYS"
      if  (value["null_subscripts"])
      {
	if (value["null_subscripts"] == "NOVAL")
		print "change -region " regname " -NULL_SUBSCRIPTS"
	else if (value["null_subscripts"] != ".")
		print "change -region " regname " -NULL_SUBSCRIPTS="value["null_subscripts"]
      }
}

function print_jnl(regname, addfn) {
      jnlarg = ""
      if (addfn && ((value["jnl_prefix"] != "***unspec***") || (value["jnl_suffix"] != "***unspec***")))
      {
	      prefix = (value["jnl_prefix"] != "***unspec***") ? value["jnl_prefix"] : ""
	      suffix = (value["jnl_suffix"] != "***unspec***") ? value["jnl_suffix"] : ".mjl"
	      jnlname = (regname == "DEFAULT") ? value["file_name"] : regname
	      jnlarg = "file_name=\"" prefix jnlname suffix "\""
      }
      if (0 < jnl_count)
      {
	      jnlarg = "(" jnlarg
	      for (jnlargnum=1; jnlargnum <= jnl_count; jnlargnum++)
	      {
		if (jnlarg != "(")
			jnlarg = jnlarg ","
		jnlarg = jnlarg value["journal" jnlargnum]
	      }
	      jnlarg = jnlarg ")"
      }
      if (jnlarg != "")
	      print "change -region " regname " -journal=" jnlarg
}

function print_out(x,seg_reg,name) {
     # x is the property, seg_reg is segment or region, name is segment or region name
     # so for segment or region, with name "name", the propery x is set to value[x]
     # if it is specified (not null or ".")
     # if value[x] matches anything but NULL or . (~/..*/ && !~/\./)
     #
     # Dbcreate also accepts multi-value strings of the form a:b:c, meaning a goes to first region, b to the next and c to the rest
     # Look for : in the values, use the first piece and remove it from the string for the next region to process
     if (((x == "record_size" && value[x] == "0") || value[x]) && value[x] != ".")
     {
        multi=index(value[x],":")
	if (multi)
	{
		val=substr(value[x],1,multi-1)
		value[x]=substr(value[x],multi+1,length(value[x]))
	}
	else
		val=value[x]
     	print "change -" seg_reg " " name " -" x "=" val
     }
}
