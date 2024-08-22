#################################################################
#								#
# Copyright (c) 2005-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
BEGIN {
	#instream.csh is called in a sub-shell, so cannot handle priorver, so define an impossible one
	if (0 == priorver) priorver="IMPOSSIBLEVERNAME"
	if ("" != priorver) priorver = priorver"\\y"	# Include the boundary condition. If V53001 is priorver, V53001A should not
							# be filtered
	# variables to filter nodename/hostname
	nodename = ENVIRON["HOST:r:r:r"]
	username = ENVIRON["USER"]
	nodenameu = toupper(nodename)
	usernameu = toupper(username)
	# variables to filter epoch interval
	if ("dbg" == ENVIRON["tst_image"]) epochinterval = " 30"
	if ("pro" == ENVIRON["tst_image"]) epochinterval = "300"
	jnl_flag1line = 0
}

# Ignore non error errors on z/OS to avoid diff synchronization problems
/CEE5213S The signal SIGPIPE was received./ { next }

{
	########################################################
	# filter for output files (outstream.log and subtest.log). Adding a filter here rather than
	# using AWK expressions in reference files, which make it difficult to read diffs in the case
	# of errors elsewhere in the test.
	#####
	# IMPORTANT:
	# In order to differentiate the lines that have been filtered by this file, please prefix all strings filtered
	# with: "##FILTERED##"
	#####
	########################################################
	if ($0 ~ /^.YDB-I-FILERENAME, File .*[\/a-z0-9_]*\..* is renamed to .*[\/a-z0-9_]*\..*_[0-9][0-9]*(_[0-9][0-9]*|[0-9])$/)
	{
		substatus += gsub(/mjl_[0-9][0-9_]*(_[0-9][0-9]*|[0-9]*)/, "mjl_##TIMESTAMP##");
		substatus += gsub(/mjf_[0-9][0-9_]*(_[0-9][0-9]*|[0-9]*)/, "mjf_##TIMESTAMP##");
		substatus += gsub(/repl_[0-9][0-9_]*(_[0-9][0-9]*|[0-9]*)/, "repl_##TIMESTAMP##");
		substatus += gsub(/lost_[0-9][0-9_]*(_[0-9][0-9]*|[0-9]*)/, "lost_##TIMESTAMP##");
		substatus += gsub(/broken_[0-9][0-9_]*(_[0-9][0-9]*|[0-9]*)/, "broken_##TIMESTAMP##");
		if (substatus) $0="##FILTERED##"$0;
	}
	########################################################

	########################################################
		# filter the date in MUPIP EXTRACT line 2 label e.g.: 14-APR-2006  10:29:05
	gsub(/^[0-9 ]*-[A-Z][A-Z][A-Z]-[1-9][0-9][0-9][0-9]  [0-9][0-9]:[0-9][0-9]:[0-9][0-9]/, "##FILTERED##..-...-....  ..:..:..");
	########################################################

	########################################################
	# Label = GDS BINARY EXTRACT LEVEL 42006041410290500512004800025500000GT.M MUPIP EXTRACT
	strexpr = "GDS BINARY EXTRACT LEVEL [0-9][0-9]*"
	strrepl = "##FILTERED##GDS BINARY EXTRACT LEVEL ..................................."
	gsub(strexpr, strrepl)
	########################################################

	########################################################
        gsub("^.YDB-I-MUJNLSTAT, Backward processing started at ... ... .. ..:..:.. 20..$", "##FILTERED##%YDB-I-MUJNLSTAT, Backward processing started at ... ... .. ..:..:.. 20..");
	gsub("^.YDB-I-MUJNLSTAT, Before image applying started at ... ... .. ..:..:.. 20..$", "##FILTERED##%YDB-I-MUJNLSTAT, Before image applying started at ... ... .. ..:..:.. 20..");
	gsub("^.YDB-I-MUJNLSTAT, End processing at ... ... .. ..:..:.. 20..$", "##FILTERED##%YDB-I-MUJNLSTAT, End processing at ... ... .. ..:..:.. 20..");
	gsub("^.YDB-I-MUJNLSTAT, Forward processing started at ... ... .. ..:..:.. 20..$", "##FILTERED##%YDB-I-MUJNLSTAT, Forward processing started at ... ... .. ..:..:.. 20..");
	gsub("^.YDB-I-MUJNLSTAT, Initial processing started at ... ... .. ..:..:.. 20..$", "##FILTERED##%YDB-I-MUJNLSTAT, Initial processing started at ... ... .. ..:..:.. 20..");
	gsub("^.YDB-I-MUJNLSTAT, Lookback processing started at ... ... .. ..:..:.. ....$", "##FILTERED##%YDB-I-MUJNLSTAT, Lookback processing started at ... ... .. ..:..:.. ....");
	#%YDB-I-MUJNLSTAT, FETCHRESYNC processing started at Thu Dec 22 15:40:05 2005
	gsub("^.YDB-I-MUJNLSTAT, FETCHRESYNC processing started at [A-Z][a-z][a-z] [A-Z][a-z][a-z] [ 0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9] 20[0-9][0-9]$", "##FILTERED##%YDB-I-MUJNLSTAT, FETCHRESYNC processing started at... ... .. ..:..:.. 20..");
	gsub(/^.YDB-I-IPCNOTDEL, ... ... .. ..:..:.. 20.. : Mupip journal process did not delete IPC resources for region [A-Z]+$/, "##FILTERED##%YDB-I-IPCNOTDEL, ... ... .. ..:..:.. 20.. : Mupip journal process did not delete IPC resources for region XREG");
	if ($0 ~ /SHOW output for journal file/)
	{
		status = gsub(/mjl_[0-9][0-9_]*(_[0-9][0-9]*|[0-9]*)/, "mjl_##TIMESTAMP##");
		if (status) $0="##FILTERED##"$0;
	}
	########################################################

	########################################################
	# MUPIP replic -editinstance -show output fields:
	gsub(/Journal Pool Sem Id                          *[0-9][0-9]* \[0x[0-9A-F][0-9A-F]*\]/, "##FILTERED##Journal Pool Sem Id             .......... [0x........]");
	gsub(/Journal Pool Shm Id                          *[0-9][0-9]* \[0x[0-9A-F][0-9A-F]*\]/, "##FILTERED##Journal Pool Shm Id             .......... [0x........]");
	gsub(/Receive Pool Sem Id                          *[0-9][0-9]* \[0x[0-9A-F][0-9A-F]*\]/, "##FILTERED##Receive Pool Sem Id             .......... [0x........]");
	gsub(/Receive Pool Shm Id                          *[0-9][0-9]* \[0x[0-9A-F][0-9A-F]*\]/, "##FILTERED##Receive Pool Shm Id             .......... [0x........]");
	#HDR Instance File Created Nodename         estess.sanch 	-- remove the domain name
	#HDR Instance File Created Nodename         scylla 		-- domain name might not be printed either
	if (($0 ~ /HDR Instance File Created Nodename/)				\
		|| ($0 ~ /HDR LMS Group Created Nodename/)			\
		|| ($0 ~ /HDR STRM [ 0-9][0-9]: Group Created Nodename/) ||	\
		($0 ~ /HST #     [ 0-9][0-9] : LMS Group Created Nodename/))
	{
		gsub(/\.[a-z0-9\.]*$/, "");	# mask off the domain name
		gsub(/name [ ]*/, "name          ");	# mask off the variable number of spaces
		gsub(/$/, "##FILTERED##");	# note that this line was FILTERED
	}
	########################################################

	########################################################
	# Replication commands and logs
	replicationtimeexpr = "^[A-Z][a-z][a-z] [A-Z][a-z][a-z] [ 0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9] 20[0-9][0-9] : ";
	replicationtimerepl = "##FILTERED##... ... .. ..:..:.. 20.. : "


	#Thu Dec 15 18:46:54 2005 : Initiating START of source server for secondary instance [INSTANCE2]
	str = "Initiating START of source server for secondary instance"
	gsub(replicationtimeexpr str, replicationtimerepl str)
	#Fri Dec 16 18:07:46 2005 : Initiating ACTIVATE operation on source server pid [8233] for secondary instance name [INST2]
	strexpr = "Initiating ACTIVATE operation on source server pid .[0-9][0-9]*."
	strrepl = "Initiating ACTIVATE operation on source server pid [##PID##]"
	gsub(replicationtimeexpr strexpr, replicationtimerepl strrepl)
	#Fri Dec 16 18:07:46 2005 : Initiating DEACTIVATE operation on source server pid [8233] for secondary instance name [INST2]
	strexpr = "Initiating DEACTIVATE operation on source server pid .[0-9][0-9]*."
	strrepl = "Initiating DEACTIVATE operation on source server pid [##PID##]"
	gsub(replicationtimeexpr strexpr, replicationtimerepl strrepl)
	#Thu Jan  5 16:25:36 2006 : Not deleting jnlpool ipcs. 2 processes still attached to jnlpool
	str = "Not deleting jnlpool ipcs."
	gsub(replicationtimeexpr str, replicationtimerepl str)
	#Thu Dec 15 18:46:54 2005 : Initiating STATSLOG operation on source server pid [5162] for secondary instance name [INST2]
	strexpr = "Initiating STATSLOG operation on source server pid .[0-9][0-9]*. "
	strrepl = "Initiating STATSLOG operation on source server pid [##PID##] "
	gsub(replicationtimeexpr strexpr, replicationtimerepl strrepl)
	#Thu Dec 15 18:46:54 2005 : Initiating CHANGELOG operation on source server pid [22649] for secondary instance name [INST2]
	strexpr = "Initiating CHANGELOG operation on source server pid .[0-9][0-9]*. "
	strrepl = "Initiating CHANGELOG operation on source server pid [##PID##] "
	gsub(replicationtimeexpr strexpr, replicationtimerepl strrepl)
	#Fri Jan 13 14:52:46 2006 : Initiating SHUTDOWN operation on source server pid [10317] for secondary instance [INSTANCE2]
	strexpr = "Initiating SHUTDOWN operation on source server pid .[0-9][0-9]*. "
	strrepl = "Initiating SHUTDOWN operation on source server pid [##PID##] "
	gsub(replicationtimeexpr strexpr, replicationtimerepl strrepl)
	#Wed Feb 15 13:26:20 2006 : Initiating shut down
	str = "Initiating shut down"
	gsub(replicationtimeexpr str, replicationtimerepl str)
	#Wed Jan 18 19:44:02 2006 : Initiating NEEDRESTART operation on source server pid [16772] for secondary instance [INSTANCE1]
	strexpr = "Initiating NEEDRESTART operation on source server pid .[0-9][0-9]*. "
	strrepl = "Initiating NEEDRESTART operation on source server pid [##PID##] "
	gsub(replicationtimeexpr strexpr, replicationtimerepl strrepl)
	#Tue Feb 21 08:27:21 2006 : Initiating NEEDRESTART operation for secondary instance [INSTANCE3]
	strexpr = "Initiating NEEDRESTART operation for secondary instance .[A-Z0-9][A-Z0-9]*."
	strrepl = "Initiating NEEDRESTART operation for secondary instance [##INSTANCE##]"
	gsub(replicationtimeexpr strexpr, replicationtimerepl strrepl)
	#Thu Jan 19 02:36:29 2006 : Initiating SHOWBACKLOG operation on source server pid [11818] for
	strexpr = "Initiating SHOWBACKLOG operation on source server pid .[0-9][0-9]*. "
	strrepl = "Initiating SHOWBACKLOG operation on source server pid [##PID##] "
	gsub(replicationtimeexpr strexpr, replicationtimerepl strrepl)
	#Thu Jan 19 02:36:29 2006 : Initiating CHECKHEALTH operation on source server pid [11818] for
	strexpr = "Initiating CHECKHEALTH operation on source server pid .[0-9][0-9]*. "
	strrepl = "Initiating CHECKHEALTH operation on source server pid [##PID##] "
	gsub(replicationtimeexpr strexpr, replicationtimerepl strrepl)
	#Thu Jan 19 02:36:29 2006 : Initiating STOPSOURCEFILTER operation on source server pid [11818] for
	strexpr = "Initiating STOPSOURCEFILTER operation on source server pid .[0-9][0-9]*. "
	strrepl = "Initiating STOPSOURCEFILTER operation on source server pid [##PID##] "
	gsub(replicationtimeexpr strexpr, replicationtimerepl strrepl)
	#Thu Jan 19 02:36:29 2006 : Initiating LOSTTNCOMPLETE operation on source server pid [11818] for
	strexpr = "Initiating LOSTTNCOMPLETE operation on source server pid .[0-9][0-9]*. "
	strrepl = "Initiating LOSTTNCOMPLETE operation on source server pid [##PID##] "
	gsub(replicationtimeexpr strexpr, replicationtimerepl strrepl)
	#Thu Jan 26 13:41:52 2006 : Initiating LOSTTNCOMPLETE operation on instance [INSTANCE3]
	strexpr = "Initiating LOSTTNCOMPLETE operation on instance .[A-Z0-9][A-Z0-9]*."
	strrepl = "Initiating LOSTTNCOMPLETE operation on instance [##INSTANCE##]"
	gsub(replicationtimeexpr strexpr, replicationtimerepl strrepl)
	#Tue Jan 17 13:36:01 2006 : Forcing immediate shutdown
	str = "Forcing immediate shutdown"
	gsub(replicationtimeexpr str, replicationtimerepl str)
	#Tue Jan 17 15:10:42 2006 : Source server startup failed. See source server log file
	str = "Source server startup failed. See source server log file"
	gsub(replicationtimeexpr str, replicationtimerepl str)
	#Tue Jan 17 15:10:42 2006 : Journal pool shared memory removed
	str = "Journal pool shared memory removed"
	gsub(replicationtimeexpr str, replicationtimerepl str)
	#Tue Jan 17 15:10:42 2006 : Journal pool semaphore removed
	str = "Journal pool semaphore removed"
	gsub(replicationtimeexpr str, replicationtimerepl str)
	#Wed Feb 15 14:48:54 2006 : Receive pool shared memory removed
	str = "Receive pool shared memory removed"
	gsub(replicationtimeexpr str, replicationtimerepl str)
	#Wed Feb 15 14:48:54 2006 : Receive pool semaphore removed
	str = "Receive pool semaphore removed"
	gsub(replicationtimeexpr str, replicationtimerepl str)
	#Wed Feb 15 14:48:54 2006 : Waiting for upto [120] seconds for the source server to shutdown
	strexpr = "Waiting for upto .[0-9]*. seconds for the source server to shutdown"
	strrepl = "Waiting for upto XXX seconds for the source server to shutdown"
	gsub(replicationtimeexpr strexpr, replicationtimerepl strrepl)
	#Tue Jan 17 13:36:01 2016 : Shutting down with a backlog due to timeout
	str = "Shutting down with a backlog due to timeout"
	gsub(replicationtimeexpr str, replicationtimerepl str)
	#Tue Jan 17 13:36:01 2016 : Shutting down with zero backlog
	str = "Shutting down with zero backlog"
	gsub(replicationtimeexpr str, replicationtimerepl str)
	#Wed Feb 15 14:48:54 2006 : %YDB-E-REPLINSTSECMTCH,...
	str = "%YDB-E-"
	gsub(replicationtimeexpr str, replicationtimerepl str)
	########################################################

	########################################################
	# pid
	if ($0 ~ /SRCSRVEXISTS, Source server for secondary instance .* is already running with pid/)
	{
		gsub(/pid [0-9][0-9]*/, "pid ##FILTERED##");
	}

	#PID 21266 Source server is alive
	gsub(/PID [0-9][0-9]* Source server is alive/, "PID ##FILTERED##[##PID##] Source server is alive");
        #PID 1271 Receiver server is alive
        gsub(/PID [0-9][0-9]* Receiver server is alive/,"PID ##FILTERED##[##PID##] Receiver server is alive");
        #PID 1272 Update process is alive
        gsub(/PID [0-9][0-9]* Update process is alive/,"PID ##FILTERED##[##PID##] Update process is alive");
	########################################################

	########################################################
	# some common filenames we might have (in case they pop up in reference files):
	gsub(/START_[_0-9]*.out/, "##FILTERED##START_##TIMESTAMP##.out");
	gsub(/SRC_[_0-9]*.log/, "##FILTERED##SRC_##TIMESTAMP##.log");
	gsub(/RCVR_[_0-9]*.log/, "##FILTERED##RCVR_##TIMESTAMP##.log");
	gsub(/RCVR_[_0-9]*.log.updproc/, "##FILTERED##RCVR_##TIMESTAMP##.log.updproc");
	gsub(/SHUT_[_0-9]*.out/, "##FILTERED##SHUT_##TIMESTAMP##.out");
	gsub(/all logs related to timestamp [_0-9]*/, "all logs related to ##FILTERED## ##TIMESTAMP##");
        gsub(/passive_[_0-9]*.log/,"##FILTERED##passive_##TIMESTAMP##.log");
	gsub(/ACTIVATE_[_0-9]*.out/, "##FILTERED##ACTIVATE_##TIMESTAMP##.out");
	gsub(/backlog_[_0-9]*.out/, "##FILTERED##backlog_##TIMESTAMP##.out");
	########################################################

	########################################################
	# multisite tests might have different remote directories depending on being submitted with
	# -replic or -multisite options (i.e. single host or multiple hosts).
	# Since the file path is not very critical, let's filter it out for everyone:
	if ($0 ~ /instance[0-9]/)
	{
		sub(/Files Created in .*instance/, "Files Created in ##FILTERED##_REMOTE_TEST_PATH_/instance");
		sub(/Starting Passive Source Server and Receiver Server in .*instance/, "Starting Passive Source Server and Receiver Server in ##FILTERED##_REMOTE_TEST_PATH_/instance");
		sub(/Starting Primary Source Server in .*instance/, "Starting Primary Source Server in ##FILTERED##_REMOTE_TEST_PATH_/instance");
		sub(/Shutting down Passive Source Server and Receiver Server in .*instance/, "Shutting down Passive Source Server and Receiver Server in ##FILTERED##_REMOTE_TEST_PATH_/instance");
		sub(/Shutting down Primary Source Server Server in .*instance/,	"Shutting down Primary Source Server Server in ##FILTERED##_REMOTE_TEST_PATH_/instance");
		sub(/File .*instance[0-9]\/mumps.repl is renamed to .*instance[0-9]\/mumps.repl/, "File ##FILTERED##_REMOTE_TEST_PATH_INSTANCE_/mumps.repl is renamed to ##FILTERED##_REMOTE_TEST_PATH_INSTANCE_/mumps.repl");
	}
	if ($0 ~ /Simulating crash on Instance INSTANCE[2-9]/)
		sub(/ in .*/, " in ##FILTERED##_REMOTE_TEST_PATH_");
	sub(/Lost transactions extract file .*\/instance/,"Lost transactions extract file ##FILTERED##_REMOTE_TEST_PATH_/instance");
	if ( $0 ~ /ORLBKSTART/ ) { sub(/corresponding to .*instance/,"corresponding to ##FILTERED##_REMOTE_TEST_PATH_/instance"); }
	if ( $0 ~ /ORLBKCMPLT/ ) { sub(/corresponding to .*instance/,"corresponding to ##FILTERED##_REMOTE_TEST_PATH_/instance"); }
	########################################################

	########################################################
	# let's mask off counters in msr_execute_* filenames and instancefile_*.out
	# msr_execute_51.out
	gsub(/msr_execute_[0-9][0-9]*.out/, "msr_execute_##FILTERED##NO.out");
	# msr_execute_51.csh
	gsub(/msr_execute_[0-9][0-9]*.csh/, "msr_execute_##FILTERED##NO.csh");
	# written into instancefile_7.out
	gsub(/written into instancefile_[0-9][0-9]*.out/, "written into instancefile_##FILTERED##NO.out");
	########################################################

	########################################################
	# some tests use random prior versions, let's not get caught in that
	if ("" != priorver)
		gsub(priorver,"##FILTERED##PRIORVER##",$0)
	########################################################

	########################################################
	# The domain name apprears (or doesn't appear) in some messages
	if ($0 ~ /REPLREQRUNDOWN.*Must be rundown on cluster node/)
	{
		gsub(/\.[a-z0-9\.]*$/, "");	# mask off the domain name
		gsub(/$/, ".##FILTERED##");	# note that this line was FILTERED
	}
	########################################################

	########################################################
	# Let any test have any free-form debugging info it wants, as long as it is padded with GTM_TEST_DEBUGINFO
	sub(/GTM_TEST_DEBUGINFO.*/, "##FILTERED##GTM_TEST_DEBUGINFO.*");
	########################################################

	########################################################
	# Journal messages #
	# Filter the output of the form in the 3rd line below
	#PID        NODE         USER     TERM JPV_TIME
	#---------------------------------------------------------
	#0000000981 kishoreh     kishoreh      2009/03/03 06:34:20
	if (2 == jnl_flag1line)
	{
		strexp = "[0-9][0-9]*[ ]*("nodename"|"nodenameu").*("username"|"usernameu")[ ]* ..../../.. ..:..:.."
		strrep = "##FILTERED## ##PID## ##NODENAME## ##USER## ..../../.. ..:..:.."
		substatus = gsub(strexp,strrep)
		if (0 == substatus) jnl_flag1line = 0
	}
	if (1 == jnl_flag1line)
		if ($0 ~ /-----------------------------------------------------------------/) jnl_flag1line++
	if ($0 ~ /PID        NODE             USER         TERM JPV_TIME/) jnl_flag1line++
	###
	# Journal file label
	strexp = "Journal file label      YDBJNL45"
	strrep = "Journal file label      ##FILTERED##"
	gsub(strexp,strrep)
	# Journal Creation Time         2009/03/12 08:24:17
	strexp = "^ Journal Creation Time         [0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]"
	strrep = " Journal Creation Time         ..../../.. ..:..:.."
	gsub(strexp,strrep)
	###
	# Time of last update           2009/03/12 08:24:17
	strexp = "^ Time of last update           [0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]"
	strrep = " Time of last update           ..../../.. ..:..:.."
	gsub(strexp,strrep)
	###
	# End of Data                                 65832 [0x00010128]
	strexp = "^ End of Data[ ]*[0-9]+ .0x[0-9A-F]+."
	strrep = " End of Data                             ##FILTERED##"
	if (mask_jnleod) gsub(strexp,strrep)
	###
	# Journal file checksum seed             3950055518 [0xEB71105E]
	strexp = "^ Journal file checksum seed          [ ]*[0-9]+ .0x[0-9A-F]+."
	strrep = " Journal file checksum seed           ##FILTERED##"
	gsub(strexp,strrep)
	###
	# Journal file encrypted                       TRUE
	strexp = "^ Journal file encrypted                      ( TRUE|FALSE)$"
	strrep = " Journal file encrypted               ##FILTERED##"
	gsub(strexp,strrep)
	###
	# Journal file hash                            49EF1880D...
	strexp = "^ Journal file hash         *[0-9A-F]*"
	strrep = " Journal file hash                    ##FILTERED##"
	gsub(strexp,strrep)
	###
	# Epoch Interval                                 30
	strexp = "^ Epoch Interval                                "epochinterval
	strrep = " Epoch Interval                       ##FILTERED##"
	gsub(strexp,strrep)
	###
	########################################################
	# Endiancvt message filters
	#%YDB-I-ENDIANCVT, Converted database file mumps.dat from LITTLE endian to BIG endian on a LITTLE endian system
	#Converting database file mumps.dat from LITTLE endian to BIG endian on a LITTLE endian system
	if ($0 ~ /database file [a-zA-Z0-9_\.]* from [A-Z]* endian to [A-Z]* endian on a [A-Z]* endian system/)
	{
		strexpr = "from [A-Z]* endian to [A-Z]* endian on a [A-Z]* endian system"
		strrepl = "from ##ENDIAN## endian to ##ENDIAN## endian on a ##ENDIAN## endian system"
		substatus = gsub(strexpr, strrepl);
		if (substatus) $0="##FILTERED##"$0;
	}
	#%YDB-E-DBENDIAN, Database file /testarea1/kishoreh/tst_V994_dbg_03_060519_101438/multi_machine_3/tmp/tst_V994_dbg_03_060519_101606/endiancvt_3/tmp/mumps.dat is BIG endian on a LITTLE endian system
	if ($0 ~ /YDB-E-DBENDIAN, Database file .* is [A-Z]* endian on a [A-Z]* endian system/)
	{
		strexpr = "is [A-Z]* endian on a [A-Z]* endian system"
		strrepl = "is ##ENDIAN## endian on a ##ENDIAN## endian system"
		substatus = gsub(strexpr, strrepl);
		if (substatus) $0="##FILTERED##"$0;
	}
	# Endian Format for MUPIP REPLIC -EDIT -SHOW output
	strexpr = "HDR Endian Format                                   (   BIG|LITTLE)"
	strrepl = "HDR Endian Format                   ##FILTERED####ENDIAN##"
	gsub(strexpr, strrepl);
	# Endian Format for both DSE DUMP -FILE output and MUPIP JOURNAL -SHOW=HEADER output
	strexpr = " Endian Format                              (   BIG|LITTLE)"
	strrepl = " Endian Format              ##FILTERED####ENDIAN##"
	gsub(strexpr, strrepl);
	# Database file encrypted                       TRUE  Inst Freeze on Error         FALSE"
	strexp = "^  Database file encrypted                     ( TRUE|FALSE)  Inst Freeze on Error                 ( TRUE|FALSE)$"
	strrep = "  Database file encrypted              ##FILTERED##  Inst Freeze on Error                 ##FILTERED##"
	gsub(strexp,strrep)
	# spanning node flag
	strexp	="^  Spanning Node Absent                        ( TRUE|FALSE)  Maximum Key Size Assured             ( TRUE|FALSE)"
	strrep	="  Spanning Node Absent                 ##FILTERED##  Maximum Key Size Assured          ##FILTERED##"
	gsub(strexp,strrep)
	# defer allocation
	strexp	="^  Defer allocation                            ( TRUE|FALSE)"
	strrep	="  Defer allocation                     ##FILTERED##"
	gsub(strexp,strrep)
	# sleep spin mask
	strexp	="  Spin sleep time mask            0x[0-9A-F]*"
	strrep	="  Spin sleep time mask          ##FILTERED##"
	gsub(strexp,strrep)
	#
	########################################################
	# Instance Frozen messages - MUINSTFROZEN, MUINSTUNFROZEN
	# Skip them if fake ENOSPC test is enabled because those messages appear on random placed in the outref
	if (($0 ~ /^.YDB-I-MUINSTFROZEN,..../) || ($0 ~ /^.YDB-I-MUINSTUNFROZEN,...../))
	{
	    if ((NULL == ENVIRON["gtm_test_keep_muinstfrozen"])) { next }
	}
	gsub("^.YDB-I-MUINSTFROZEN, ... ... .. ..:..:.. 20..", "##FILTERED##YDB-I-MUINSTFROZEN, ... ... .. ..:..:.. 20..");
	gsub("^.YDB-I-MUINSTUNFROZEN, ... ... .. ..:..:.. 20..", "##FILTERED##YDB-I-MUINSTUNFROZEN, ... ... .. ..:..:.. 20..");
	# QDBRUNDOWN is randomly true or false
	gsub(/HDR Quick database rundown is active                 ...../,"HDR Quick database rundown is active                 .....");
	########################################################
	# ydbsh temporary object directory filters
	strexp	="ydbsh......\\("
	strrep	="ydbsh##OBJ##("
	gsub(strexp,strrep)
	########################################################
	#-------------------------------------------------------
	print;
}
