#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
BEGIN {
	hex = " .[A-Fa-f0-9x]*."
	jnlcount = -1;
	offset1 = -1;
}
/CTL Journal Seqno/ {
	split($0,line," ");
	jnlcount =  line[NF-1];
	jnlcount_2 = jnlcount - 10;
	# Earlier, The number of spaces was hard coded to 10 as the journal sequence
        # number will normally be a 3 digit number( 10 + 3 = length of "##JNLSEQNO1##"
	# But now we see it can vary so calculate it based on the length of offset
	# The below calculations are strictly for right alignment of the filter
	# in the reference file
	numspaces1 = length("##JNLSEQNO1##") - length(jnlcount)
	numspaces2 = length("##JNLSEQNO2##") - length(jnlcount_2)

}
/Secondary INET Address/ {
	# The size of sockaddr_storage can differ across systems
	gsub(/^0x........ 0x..../, "0x........ 0x....");
}

{
	if ("-1" != jnlcount )
	{
		spaces = ""
		for(i=1 ; i<=numspaces1 ; i++ ) { spaces = spaces" " }
		if (/Resync/ || /Connect Sequence Number/ || /Journal Seqno/) gsub(spaces""jnlcount hex, "##JNLSEQNO1##")
		spaces = ""
		for(i=1 ; i<=numspaces2 ; i++ ) { spaces = spaces" " }
		if (/Resync/ || /Connect Sequence Number/ || /Journal Seqno/) gsub(spaces""jnlcount_2 hex, "##JNLSEQNO2##");
	}
	# Filter out the date (all time related fields)
	gsub(/[0-9][0-9][0-9][0-9]\/[0-9][0-9]\/[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]/,"..../../.. ..:..:..");
	# The following are run specific fields
	gsub(/CTL YottaDB Version         *YottaDB r[a-zA-Z0-9_\-\. ]*/, "CTL YottaDB Version                         ##YDBVERSION##");
	gsub(/CTL Instance file name      *[a-zA-Z0-9_\.\/]*/,      "CTL Instance file name                        ##INSTFILE##");
	gsub(/Journal Pool Sem Id                          *[0-9][0-9]* .0x[0-9A-F][0-9A-F]*./, "Journal Pool Sem Id             .......... [0x........]");
	gsub(/Journal Pool Shm Id                          *[0-9][0-9]* .0x[0-9A-F][0-9A-F]*./, "Journal Pool Shm Id             .......... [0x........]");
	gsub(/Secondary Address Family    *[a-zA-Z0-9]*./, "Secondary Address Family        ##IPv4_OR_IPv6##")
	gsub(/Secondary Port                              *[0-9][0-9]* .0x[0-9A-F][0-9A-F]*./, "Secondary Port                        ##PORTNO## [0x........]")
	gsub(/Source Server Pid                       *[0-9][0-9]*/, "Source Server Pid                        ##PID##")
	gsub(/Journal record Compression Level               [0-9]/, "Journal record Compression Level         ##LVL##")
	gsub(/Log File               *[a-zA-Z0-9_\.\/]*/, "Log File                             ##LOGFILE##")
	gsub(/CTL Journal Data Base Offset                        *[0-9][0-9]* .0x[0-9A-F][0-9A-F]*./, "CTL Journal Data Base Offset                  ##JNLDBOFF## [0x........]");
	gsub(/CTL Journal Pool Size .in bytes.                  *[0-9][0-9]* .0x[0-9A-F][0-9A-F]*./, "CTL Journal Pool Size (in bytes)            ##JNLPOOLSIZ## [0x........]");
	gsub(/Trigger Supported                                 TRUE/, "Trigger Supported                    ##TRUE_OR_FALSE##");
	gsub(/Trigger Supported                                FALSE/, "Trigger Supported                    ##TRUE_OR_FALSE##");
	gsub(/FTOK Counter Halted                               TRUE/, "FTOK Counter Halted                  ##TRUE_OR_FALSE##");
	gsub(/FTOK Counter Halted                              FALSE/, "FTOK Counter Halted                  ##TRUE_OR_FALSE##");
	gsub(/Custom Errors Loaded                             ( TRUE|FALSE)/, "Custom Errors Loaded                 ##TRUE_OR_FALSE##");
	gsub(/CTL Phase2 Commit Index1 *[1-9][0-9]* .0x[0-9A-F][0-9A-F]*./, "CTL Phase2 Commit Index1                   ##PHS2CMTINDX## [0x........]");
	gsub(/CTL Phase2 Commit Index2 *[1-9][0-9]* .0x[0-9A-F][0-9A-F]*./, "CTL Phase2 Commit Index2                   ##PHS2CMTINDX## [0x........]");
	# Most below can sometime be non-zero (depending on system load when running test) so convert a non-zero value into 0 for a deterministic reference file.
	gsub(/CTL JnlPoolWrite Sleep       Cntr  *[1-9][0-9]* .0x[0-9A-F][0-9A-F]*./, "CTL JnlPoolWrite Sleep       Cntr                        0 [0x00000000]");
	gsub(/CTL JnlPoolWrite Sleep       Seqno *[1-9][0-9]* .0x[0-9A-F][0-9A-F]*./, "CTL JnlPoolWrite Sleep       Seqno                       0 [0x00000000]");
	gsub(/CTL ReplPhs2Clnup IsPrcAlv   Cntr  *[1-9][0-9]* .0x[0-9A-F][0-9A-F]*./, "CTL ReplPhs2Clnup IsPrcAlv   Cntr                        0 [0x00000000]");
	gsub(/CTL ReplPhs2Clnup IsPrcAlv   Seqno *[1-9][0-9]* .0x[0-9A-F][0-9A-F]*./, "CTL ReplPhs2Clnup IsPrcAlv   Seqno                       0 [0x00000000]");
	gsub(/Remote Supports Triggers                    TRUE/, "Remote Supports Triggers       ##TRUE_OR_FALSE##");
	gsub(/Remote Supports Triggers                   FALSE/, "Remote Supports Triggers       ##TRUE_OR_FALSE##");
	gsub(/Remote is Cross Endian                      TRUE/, "Remote is Cross Endian         ##TRUE_OR_FALSE##");
	gsub(/Remote is Cross Endian                     FALSE/, "Remote is Cross Endian         ##TRUE_OR_FALSE##");
	gsub(/CTL Supplementary Instance                           FALSE/, "CTL Supplementary Instance               ##TRUE_OR_FALSE##");
	gsub(/CTL Supplementary Instance                            TRUE/, "CTL Supplementary Instance               ##TRUE_OR_FALSE##");
	gsub(/HDR Supplementary Instance                           FALSE/, "HDR Supplementary Instance               ##TRUE_OR_FALSE##");
	gsub(/HDR Supplementary Instance                            TRUE/, "HDR Supplementary Instance               ##TRUE_OR_FALSE##");
	gsub(/: Remote is Supplementary Instance           FALSE/, ": Remote is Supplementary Instance  ##TRUE/FALSE##");
	gsub(/: Remote is Supplementary Instance            TRUE/, ": Remote is Supplementary Instance  ##TRUE/FALSE##");
	gsub(/: Currently Reading from                      (POOL|FILE)/, ": Currently Reading from          ##POOL_OR_FILE##");
	gsub(/: Journal File Only                          ( TRUE|FALSE)/, ": Journal File Only              ##TRUE_OR_FALSE##");
	# The following are machine specific fields
	gsub(/Secondary HOSTNAME           *[a-zA-Z0-9\.\:]*/, "Secondary HOSTNAME                  ##HOSTNAME##")
	gsub(/Secondary INET Address  *[0-9a-fA-F:\.]*/, "Secondary INET Address              ##INETADDR##")
	gsub(/HDR Instance File Created Nodename         *[a-zA-Z0-9\.]*/, "HDR Instance File Created Nodename            ##HOSTNAME##")
	gsub(/HDR LMS Group Created Nodename         *[a-zA-Z0-9\.]*/, "HDR LMS Group Created Nodename                ##HOSTNAME##")
	gsub(/Instance File Creator Pid *[0-9]* .0x[0-9a-fA-F]*./, "Instance File Creator Pid                 PIDINDECIMAL [0xPIDINHEX]")
	gsub(/LMS Group Creator Pid *[0-9]* .0x[0-9a-fA-F]*./, "LMS Group Creator Pid                     PIDINDECIMAL [0xPIDINHEX]")
	# Filter out the offset
	gsub(/^0x[0-9A-F][0-9A-F]*[0-9A-F] /, "0x........ ");

	# The size of time fields on IA64 is 8 bytes and on 32-bit platforms, it will be 4 bytes. So using "0x000." to work in both cases.
	gsub(/^0x........ 0x000[48] HDR Journal Pool Sem Create Time/, "0x........ 0x000. HDR Journal Pool Sem Create Time");
	gsub(/^0x........ 0x000[48] HDR Journal Pool Shm Create Time/, "0x........ 0x000. HDR Journal Pool Shm Create Time");
	gsub(/^0x........ 0x000[48] HDR Receive Pool Sem Create Time/, "0x........ 0x000. HDR Receive Pool Sem Create Time");
	gsub(/^0x........ 0x000[48] HDR Receive Pool Shm Create Time/, "0x........ 0x000. HDR Receive Pool Shm Create Time");
	gsub(/^0x........ 0x000[48] HDR Instance File Create Time/, "0x........ 0x000. HDR Instance File Create Time");
	gsub(/Relative Read Offset.*/, "Relative Read Offset                 ##OFFSET1##");
	gsub(/Absolute Read Offset.*/, "Absolute Read Offset                 ##OFFSET1##");
	gsub(/Absolute Write Offset.*/, "Absolute Write Offset                      ##OFFSET1##");
	gsub(/Reserved Write Offset.*/, "Reserved Write Offset                      ##OFFSET1##");
	# LITTLE or BIG Endian should be converted to a static value
	gsub(/HDR Endian Format                                   LITTLE/,"HDR Endian Format                                   ......");
	gsub(/HDR Endian Format                                      BIG/,"HDR Endian Format                                   ......");
	# 64-bit Format should be converted to a static value
	gsub(/HDR 64-bit Format                                     TRUE/,"HDR 64-bit Format                                    .....");
	gsub(/HDR 64-bit Format                                    FALSE/,"HDR 64-bit Format                                    .....");
	# QDBRUNDOWN is randomly true or false
	gsub(/HDR Quick database rundown is active                 ...../,"HDR Quick database rundown is active                 .....");
	print;
}
