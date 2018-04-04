;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2013-2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Routine to test $ZPEEK() function. Obtain fields from each supported control block type plus
; some adhoc queries based on extracted addresses. The fields are formatted in various ways.
; Added as part of GTM-7421 (InfoHub) but the functionality can certainly use useful outside
; InfoHub.
;
	;
	; Initialization
	;
	do init^zpeekhelper
	Set maxstrlen=1024*1024		; For use in maxstrlen testing
	Set origlvl=$ZLevel
	Set $ETrap="ZShow ""*"" ZHalt 1"
	;
	; For the region type fields, process all regions available
	;
	Set reg=""
	For  Set reg=$View("GVNEXT",reg) Quit:(""=reg)  Do fetchregflds(reg)
	Kill reg 	; Trying to not pollute ZWrite output with too much kruft
	;
	; Test jnlpool fetch to see if it is available
	;
	Do	; Another level so we can save/restore $ETRAP
	. New $ETrap,tst
	. Set $ETrap="Do poolnotfound(""jnlpool"")"	; If fails, see if expected message and resume at nojnlpool below
	. Set tst=$ZPeek("nlrepl",0,8,"Z")
	;
	; Fetch some fields from replication's gtm_src_array (2 array levels even though 2nd should be zeroes).
	; The gsa() values are from gtmsrc_lcl_array while the GSA() values are from gtmsource_local_array.
	;
	For i=0:1:1 Do
	. Set gsa(i,"secondary_instname")=$$fetchfld("glfrepl:"_i,"gtmsrc_lcl.secondary_instname","s")
	. Set gsa(i,"resync_seqno")=$$fetchfld("Glf:"_i,"gtmsrc_lcl.resync_seqno","X")
	. Set gsa(i,"resync_seqno")=$$fetchfld("GLFRepl:"_i,"gtmsrc_lcl.resync_seqno","U")
	. Set gsa(i,"connect_jnl_seqno")=$$fetchfld("gLF:"_i,"gtmsrc_lcl.connect_jnl_seqno","X")
	. Set GSA(i,"secondary_instname")=$$fetchfld("gsLREPL:"_i,"gtmsource_local_struct.secondary_instname","S")
	. Set GSA(i,"mode")=$$fetchfld("GsL:"_i,"gtmsource_local_struct.mode","i")
	. Set GSA(i,"gtmsource_pid")=$$fetchfld("GSlrEPL:"_i,"gtmsource_local_struct.gtmsource_pid","I")
	Kill i		; Trying to not pollute ZWrite output with too much kruft
	;
	; Fetch some fields from the journal pool control structure
	;
	Set jpcnowrunning=$$fetchfld("JPCrepl","jnlpool_ctl_struct.jnlpool_id.now_running","S")
	Set jpcinstfn=$$fetchfld("jpc","jnlpool_ctl_struct.jnlpool_id.instfilename","S")
	Set jpcseqno=$$fetchfld("Jpcrepl","jnlpool_ctl_struct.jnl_seqno","x")
	If (jpcnowrunning=$ZYRelease) Kill jpcnowrunning	; Verify and remove from reference file
	;
	; Fetch some fields from the replication instance header
	;
	Set rihlabel=$$fetchfld("rihrepl","repl_inst_hdr.label","S")
	Set rihissuppl=$$fetchfld("rIH","repl_inst_hdr.is_supplementary","u")
	Set rihendian=$$fetchfld("RihREPL","repl_inst_hdr.is_little_endian","u")
	If (rihendian=('bigendian)) Kill rihendian	; Verify and remove from reference file
	;
	; Fetch a field from replication's dummy_region node_local (much of this dummy node_local not filled in)
	;
	Set rnlrefcnt=$$fetchfld("NLREPL","node_local.ref_cnt","U")
	;
	; Rejoin here if no journal pool was available to test with
	;
nojnlpool
	Do	; Another level so we can save/restore $ETRAP
	. New $ETrap,tst
	. Set $ETrap="Do poolnotfound(""recvpool"")"	; If fails, see if expected message and resume at norecvpool below
	. Set tst=$ZPeek("rpcrepl",0,8,"Z")
	;
	; Fetch some fields from recvpool_ctl
	;
	Set rpclabel=$$fetchfld("RpCrEpL","recvpool_ctl_struct.recvpool_id.label","S")
	Set rpcnowrunning=$$fetchfld("RpCrEpL","recvpool_ctl_struct.recvpool_id.now_running","s")
	Set rpcinstname=$$fetchfld("rPc","recvpool_ctl_struct.recvpool_id.now_running","S")
	If (rpcnowrunning=$ZYRelease) Kill rpcnowrunning	; Verify and remove from reference file
	If (rpcinstname=$ZYRelease) Kill rpcinstname	; ditto
	;
	; Fetch some fields from upd_proc_local
	;
	Set upllogfile=$$fetchfld("UPLrePl","upd_proc_local_struct.log_file","S")
	Set uplrjseqno=$$fetchfld("UPLrEpl","upd_proc_local_struct.read_jnl_seqno","u")
	Set upllogintvl=$$fetchfld("UPLrepl","upd_proc_local_struct.log_interval","U")
	;
	; Fetch some fields from gtmrecv_local
	;
	Set grllogintvl=$$fetchfld("GRLrePL","gtmrecv_local_struct.log_interval","u")
	Set grllogfile=$$fetchfld("GRLrepl","gtmrecv_local_struct.log_file","S")
	;
	; Fetch some fields from upd_helper_ctl
	;
	Set uhchelpers=$$fetchfld("UHCrePl","upd_helper_ctl_struct.start_helpers","i")
	Set uhchelprds=$$fetchfld("UHCrePl","upd_helper_ctl_struct.start_n_readers","u")
	Set uhchelpwts=$$fetchfld("UHCrePl","upd_helper_ctl_struct.start_n_writers","X")
	;
	; Rejoin here if no receive pool was available to test with
	;
norecvpool
	;
	; Test some error messages
	;
	New fmt										; Undefined format
	Do tstzpeek(,0,1,,"UNDEF","")							; Check if base addr is undefined
	Do tstzpeek("FHREG:DEFAULT",,1,,"UNDEF","")					; Check if offset is undefined
	Do tstzpeek("FHREG:DEFAULT",0,,,"UNDEF","")					; Check if length is undefined
	Do tstzpeek("FHREG:DEFAULT",0,1,.fmt,"UNDEF","")				; Check if format is undefined
	Do tstzpeek("FHREG:DEFAULT"_$Char(0),0,1,"s","BADZPEEKARG","region name")	; Verify baseaddress length check
	Do tstzpeek("FHREG:DEFAULT",-1,1,"i","BADZPEEKARG","offset")			; Verify negative offset check
	Do tstzpeek("FHREG:DEFAULT",0,maxstrlen+1,"i","BADZPEEKARG","length")		; Verify too long length check
	Do tstzpeek("FHREG:DEFAULT",0,-100,"i","BADZPEEKARG","length")			; Verify negative length check
	Do tstzpeek("FHREG:DEFAULT",0,4,"y","BADZPEEKARG","format")			; Verify invalid format
	Do tstzpeek("FHREG:DEFAULT",0,3,"i","BADZPEEKFMT","")				; Verify invalid format-length
	Do tstzpeek("FHREG:DEFAULT",0,9,"X","BADZPEEKFMT","")				; Ditto for different format code
	Do tstzpeek("FHREG:DEFAULT",0,8,"CC","BADZPEEKARG","format")			; Multi-char format gives error per [RP]
	;
	; Fetch a field with a bogus offset/length - should fail and raise BADZPEEKRANGE
	;
	Kill xrefflds,gtmtypes,gtmtypfldindx		; Leave only interesting vars
	Kill maxstrlen,bigendian,gtm64
	Set $ETrap="Set $ECode="""" ZGoto origlvl:theend"
	Set bogus=$ZPeek("PEEK:0xFFFFFFFE",0,3,"Z")	; 3 bytes that straddle the 4GB boundary
	Write "Expected error did not occur correctly - unexpectedly fetched a value",!
	ZShow "*"
	ZHalt 1
	;
	; If/when the error occurs, we should end up here
	;
theend
	Set $ETrap="ZShow ""*"" ZHalt 1"		; Reset to usable (non-looping) error trap
	If ($ZStatus["BADZPEEKRANGE") Do
	. Kill origlvl
	. Write "Expected error occurred",!
	. ZWrite
	Else  Do
	. Write "Expected error DID NOT occur (but some other error did) -- FAIL",!
	. ZShow "*"
	Quit

;
; Routine to extract the offset/length needed to fetch a given field and fetch it.
;
fetchfld(base,fldname,fmt)
	new val
	Set val=$Select((0=$Data(fmt)):$$fetchfld^zpeekhelper(base,fldname),1:$$fetchfld^zpeekhelper(base,fldname,fmt))
	Quit val

;
; Routine to test $ZPEEK() with an expected error condition and return to caller
;
tstzpeek(base,offset,len,fmt,experr,errrsn)
	New $ETrap,x
	Set $ETrap="Do errorvalidate Set $ECode="""" Quit"
	Set x=$ZPeek(base,offset,len,fmt)
	Write "Unexpected success for call args - caller: ",$Stack($ZLevel-2,"place"),!
	Do dmpargs
	Write !
	Quit

;
; Routine driven from $ETRAP in tstzpeek(). Validate we got the expected error.
;
errorvalidate
	If (($ZStatus'[experr)!((""'=errrsn)&($ZStatus'[errrsn))) Do
	. ZWrite $ZStatus
	. Write "Expected error and/or reason not found - Error expected: ",experr,"  Reason: ",errrsn," for the following call parms:",!
	. Do dmpargs
	. Write !
	;Else  Write !,"Expected error validated:",! ZWr $zstatus Do dmpargs ; Uncomment to show error validations working.
	Quit

;
; Routine to dump arguments even if some of them are undefined
;
dmpargs
	If $Data(base) ZWrite base
	Else  Write "base=<undefined>",!
	If $Data(offset) ZWrite offset
	Else  Write "offset=<undefined>",!
	If $Data(len) ZWrite len
	Else  Write "len=<undefined>",!
	If $Data(fmt) ZWrite fmt
	Else  Write "fmt=<undefined>",!
	ZWrite experr,errrsn
	ZSHow "S"
	Write !!
	Quit

;
; Routine to fetch fields related to specific region
;
fetchregflds(reg)
	New uselc
	;
	; Fetch some fields from node_local
	;
	Set nldbfile(reg)=$$fetchfld("nlReg:"_reg,"node_local.fname","s")
	Set nlnowrunning(reg)=$$fetchfld("NL:"_reg,"node_local.now_running","S")
	Set nlrefcnt(reg)=$$fetchfld("NLreg:"_reg,"node_local.ref_cnt","U")
	If (nlnowrunning(reg)=$ZYRelease) Kill nlnowrunning	; Verify and remove from reference file
	;
	; Fetch some fields from the file header (sgmnt_data)
	;
	Set fhlabel(reg)=$$fetchfld("Fhreg:"_reg,"sgmnt_data.label")
	Set fhaccmeth(reg)=$$fetchfld("Fh:"_reg,"sgmnt_data.acc_meth","i")
	Set fhblksiz(reg)=$$fetchfld("FHReg:"_reg,"sgmnt_data.blk_size","u")
	Set fhcurrtn1(reg)=$$fetchfld("FH:"_reg,"sgmnt_data.trans_hist.curr_tn","X")
	Set fhcurrtn2(reg)=$$fetchfld("fHREG:"_reg,"sgmnt_data.trans_hist.curr_tn","Z")
	Set fhcurrtn3(reg)=$$fetchfld("Fh:"_reg,"sgmnt_data.trans_hist.curr_tn","i")
	Set fhcurrtn4(reg)=$$fetchfld("FHReg:"_reg,"sgmnt_data.trans_hist.curr_tn","u")
	;
	; Fetch some fields from sgmnt_addrs
	;
	Set csatotblk(reg)=$$fetchfld("CSAreg:"_reg,"sgmnt_addrs.total_blks","U")
	Set csarefcnt(reg)=$$fetchfld("Csa:"_reg,"sgmnt_addrs.ref_cnt","i")
	;
	; Fetch from fields from gd_region
	;
	Set gdrrname(reg)=$$fetchfld("gDrreg:"_reg,"gd_region.rname")
	Set gdrrnamelen(reg)=$$fetchfld("gDrreg:"_reg,"gd_region.rname_len","i")
	Set gdrrname(reg)=$ZExtract(gdrrname(reg),1,gdrrnamelen(reg))
	;
	; Fetch some fields from jnl_private_control
	;
	Set jpcchannel(reg)=$$fetchfld("JnLReg:"_reg,"jnl_private_control.channel","i")
	Set jpcjnlbuff(reg)=$$fetchfld("Jnl:"_reg,"jnl_private_control.jnl_buff","X")
	;
	; Fetch some fields from jnl_buffer
;
	Set jbfepochitvl(reg)=$$fetchfld("JbFrEg:"_reg,"jnl_buffer.epoch_interval","I")
	Set jbfnxtepoch(reg)=$$fetchfld("jbf:"_reg,"jnl_buffer.next_epoch_time","t")
	;
	; Fetch some free-form fields using PEEK operator and and address fetched from cs_addrs
	;
	Set csahdr(reg)=$$fetchfld("csa:"_reg,"sgmnt_addrs.hdr","X")		; Fetch the fileheader address
	Set fhlabel2(reg)=$$fetchfld("Peek:"_csahdr(reg),"sgmnt_data.label")	; Fetch the label
	If (fhlabel2(reg)=fhlabel(reg)) Kill csahdr(reg),fhlabel2(reg)		; Verify and remove from reference file
	Quit

;
; Routine to deal with issues when the pool is not found (after validating that)
;
poolnotfound(pool)
	If ($ZStatus'["ZPEEKNORPLINFO") Do
	. Write "Unexpected error occurred: ",$ZStatus,!!
	. ZShow "*"
	. ZHalt 1
	Write "The ",pool," pool was not found - bypassing related testing section",!
	Xecute "ZGoto origlvl:no"_pool
