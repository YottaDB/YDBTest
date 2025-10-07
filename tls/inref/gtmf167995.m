;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gtmf167995 ;
	new version,verNum,tlsid,pieces,sslversion,ciphers,ciphersuite,tlsversion,tlstype,context,err,outFile,cipherStr
	write "### Test 1: getversion",!
	write "# TLS version: "_$&libgtmtls.getversion(.version),!
	write "# TLS details: "_version,!
	write !

	set options("context",0)="SOCKET"
	set options("context",1)="REPLICATION"
	set options("ciphersuite",0)=""
	set options("ciphersuite",1)="ALL"
	set options("ciphersuite",2)="RSA"
	set options("ciphersuite",3)="DHE"
	set options("ciphersuite",4)="ECDHE"

	write "### Test 2: gettlslibsslversion",!
	for i=0:1:2  do
	. if 0=i  do
	. . set option="run-time"
	. else  if 1=i  do
	. . set option="compile-time"
	. else  do
	. . set option="badoption"
	. write "## Pass """_option_""" option"
	. if ("badoption"=option)  do
	. . write " (error case)"
	. write ":",!
	. set verNum=$&libgtmtls.gettlslibsslversion(.version,option,.err)
	. if (verNum>=0)&("badoption"'=option)  do
	. . write "# libssl version: "_verNum,!
	. . write "# libssl details: "_version,!
	. else  if ("badoption"=option) do
	. . write "# gettlslibsslversion issued error: "_err,!
	. else  do
	. . write "FAIL: gettlslibsslversion failed with error: "_err,!
	. . zhalt 1
	write !

	write "### Test 3: getdefaultciphers",!
	for i=2:1:4  do
	. set tlsversion="tls1_"_i
	. write "## Pass tlsversion="""_tlsversion_""""
	. if ("tls1_4"=tlsversion)  do
	. . write " (error case)"
	. write ":",!
	. set pieces=$&libgtmtls.getdefaultciphers(.ciphers,tlsversion,.err)
	. if (pieces>=0)&("tls1_4"'=tlsversion)  do
	. . for piece=1:1:pieces  do
	. . . write "#   "_$piece(ciphers,":",piece),!
	. else  if ("tls1_4"=tlsversion)  do
	. . write "# getdefaultciphers issued error: "_err,!
	. else  do
	. . write "FAIL: getdefaultciphers failed with error: "_err,!
	. . zhalt 1
	write !

	write "### Test 4: getciphers",!
	; RHEL systems don't include the lsb_release command. In that case, we know it isn't a SUSE system.
	; So, check if lsb_release command exists and, if so, run it to check for an openSUSE system.
	zsystem "command -v lsb_release >& /dev/null && lsb_release -a | grep openSUSE > lsb_release.out"
	if $zsystem=0  do
	. write "# Skipping test case for OpenSUSE platform",!
	. write "# Output differs, but the reason for this was not investigated.",!
	. write "# See discussion at https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2362#note_2616237386 for more information.",!
	. zhalt 0
	for i=2:1:3  do
	. set tlsversion="tls1_"_i
	. for j=0:1:1  do
	. . set context=options("context",j)
	. . for k=1:1:3  do
	. . . set tlsid="INSTANCE"_k
	. . . for l=0:1:4  do
	. . . . set ciphersuite=options("ciphersuite",l)
	. . . . write "## Pass tlsversion="""_tlsversion_""""
	. . . . write " context="""_context_""""
	. . . . write " tlsid="""_tlsid_""":"
	. . . . write " ciphersuite="""_ciphersuite_""":",!
	. . . . if ""=ciphersuite  do
	. . . . . set cipherStr="ANY"
	. . . . else  do
	. . . . . set cipherStr=ciphersuite
	. . . . set basename=tlsversion_"-"_context_"-"_tlsid_"-"_cipherStr_".out"
	. . . . ; Get the list of expected ciphers and store in a file for later comparison
	. . . . if "tls1_2"=tlsversion  do
	. . . . . ; In the case of TLS 1.2, get also the TLS 1.3 ciphers
	. . . . . if ciphersuite=""  do
	. . . . . . zsystem "openssl ciphers -tls1_3 -s -v | cut -f 1 -d ' ' > "_basename_".exp"
	. . . . . . ; Systems may set a different default SECLEVEL, causing different ciphers to be output and leading to erroneous test failures
	. . . . . . ; so, enforce a the same SECLEVEL for all systems explicitly when calling openssl ciphers. This behavior has only been observed
	. . . . . . ; with TLS 1.2, so only apply to the below call.
	. . . . . . zsystem "openssl ciphers -"_tlsversion_" -s -v 'DEFAULT:@SECLEVEL=1' | cut -f 1 -d ' ' >> "_basename_".exp"
	. . . . . . zsystem "sort -o "_basename_".exp "_basename_".exp"
	. . . . . else  do
	. . . . . . zsystem "openssl ciphers -tls1_3 -s -v "_"'"_ciphersuite_"' | cut -f 1 -d ' ' > "_basename_".exp"
	. . . . . . zsystem "openssl ciphers -"_tlsversion_" -s -v "_"'"_ciphersuite_"' | cut -f 1 -d ' ' >> "_basename_".exp"
	. . . . . . zsystem "sort -o "_basename_".exp "_basename_".exp"
	. . . . else  do
	. . . . . if ciphersuite=""  do
	. . . . . . zsystem "openssl ciphers -"_tlsversion_" -s -v | cut -f 1 -d ' ' | sort > "_basename_".exp"
	. . . . . else  do
	. . . . . . zsystem "openssl ciphers -"_tlsversion_" -s -v "_"'"_ciphersuite_"' | cut -f 1 -d ' ' | sort > "_basename_".exp"
	. . . . set outFile=basename_".act"
	. . . . open outFile:New
	. . . . use outFile
	. . . . set pieces=$&libgtmtls.getciphers(.ciphers,tlsversion,context,tlsid,ciphersuite,.err)
	. . . . if pieces>=0  do
	. . . . . for piece=1:1:pieces  do
	. . . . . . write $piece(ciphers,":",piece),!
	. . . . else  do
	. . . . . close outFile
	. . . . . use $p
	. . . . . write "FAIL: getciphers failed with error: "_err,!
	. . . . . zhalt 1
	. . . . close outFile
	. . . . use $p
	. . . . zsystem "sort -o "_basename_".act "_basename_".act"
	. . . . zsystem "diff "_basename_".exp "_basename_".act > "_basename_".diff"
	. . . . if 0=$ZSYSTEM  do
	. . . . . write "PASS: getciphers returned the expected ciphers",!
	. . . . else  do
	. . . . . write "FAIL: getciphers did not return the expected ciphers. See "_basename_".diff for details.",!
	write "## Pass tlsversion=""NOTAVERSION"" (error case)",!
	set pieces=$&libgtmtls.getciphers(.ciphers,"NOTAVERSION","SOCKET","INSTANCE1","ALL",.err)
	if pieces<0  do
	. write "getciphers issued error: "_err,!
	else  do
	. write "FAIL: Error expected from getciphers.",!
	quit
