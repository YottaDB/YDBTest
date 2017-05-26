;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; -----------------------------------------------------------------------------------------------
;             Trigger definitions for ZTRIGGER in imptp.m
; -----------------------------------------------------------------------------------------------

+^lasti(fillid=:,jobno=:,loop=:)       -commands=ZTRIGGER -xecute="set ^lasti(fillid,jobno)=loop" -name=lasti

+^andxarr(fillid=:,jobno=:,loop=:)     -commands=ZTR  -xecute="set ^andxarr(fillid,jobno,loop)=$ztwormhole"
