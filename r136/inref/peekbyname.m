;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022-2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Helper M program used by r136/u_inref/peekbyname.csh
; This program gets a list of ALL fields supported by PEEKBYNAME using a call to LIST^%PEEKBYNAME.
; It then generates an M command to do a PEEKBYNAME call to each of those fields.
; This M program is then run by the caller script which then verifies there are only a few/expected errors.
;

peekbyname	;
	set side=$zcmdline
	; The below control blocks require a region argument so provide that using the "secondparam" lvn.
	for controlblock="gd_region","gd_segment","jnl_buffer","jnl_private_control","node_local","sgmnt_addrs","sgmnt_data","unix_db_info" do
	.	set secondparam(controlblock)=",""DEFAULT"""
	; The below control blocks require an index argument so provide that using the "secondparam" lvn.
	for controlblock="gtmsource_local_struct","gtmsrc_lcl" do
	.	set secondparam(controlblock)=",0"
	; The below control blocks can only be used on the receiver side. Note that using the "receiverside" lvn.
	for controlblock="recvpool_ctl_struct","gtmrecv_local_struct","upd_helper_ctl_struct","upd_proc_local_struct" do
	.	set receiverside(controlblock)=""
	; Get list of ALL fields supported by PEEKBYNAME using a call to LIST^%PEEKBYNAME
	do LIST^%PEEKBYNAME(.out)
	set fld=$order(out(""))
	; Check if the next field is an extension of the current field. If so, skip the current field because this is
	; a structure containing the next field and so doing a PEEKBYNAME on the next field will get us the fine grained value.
	;
	; For example, the below 2 fields have a separator of "." between them ("u" and "u.pid_imgcnt")
	;	upd_helper_ctl_struct.pre_read_lock.u
	;	upd_helper_ctl_struct.pre_read_lock.u.pid_imgcnt
	;
	; For example, the below 2 fields have a separator of "[" between them ("helper_list" and "helper_list[0]")
	;	upd_helper_ctl_struct.helper_list
	;	upd_helper_ctl_struct.helper_list[0].helper_pid
	;
	; Hence the check of "." and "[" between "nextfld" and "fld" below.
	;
	for  set nextfld=$order(out(fld)) quit:fld=""  do:(nextfld'[(fld_"."))&(nextfld'[(fld_"["))  set fld=nextfld
	.	set controlBlock=$piece(fld,".",1)
	.	quit:(side'="receiver")&$data(receiverside(controlBlock))  ; Do not generate receiver-only fields on source side
	.	set cmd="set x=$$^%PEEKBYNAME("""_fld_""""
	.	set:$data(secondparam(controlBlock)) cmd=cmd_secondparam(controlBlock)
	.	set cmd=cmd_")"
	.	write " write ",$zwrite(cmd),",!"
	.	write " ",cmd,!
	quit

