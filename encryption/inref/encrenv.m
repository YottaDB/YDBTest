;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; A helper script employed in the encryption/encr_env test. It
; generates valid and invalid combinations of environment
; variables as well as expected output from an attempted MUPIP
; CREATE.
;
; This routine works by optionally (as decided by $random())
; defining a number (again, selected randomly) of environment
; variables relevant to encryption to valid or invalid values and
; figuring out the result (a particular error or absence thereof)
; to expect.
;
; The script itself does not mess with the environment but rather
; produces a file that can be sourced by the test to apply the
; selected configuration. Additionally, the script writes out the
; string to be matched against the output of an attempted MUPIP
; CREATE operation in the resultant environment.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

encrenv
	new i,stateCount,vars,numOfVars,varIndex,varState,varName,error,version
	new UNDEFINED,EMPTY,INVALID,VALID,USEAGENT,DECRERROR,USER,GNUPGHOMEDIR
	; Get what we need from the environment.
	set version=+$ztrnlnm("gtm_gpg_exact_version")
	set USEAGENT=+$ztrnlnm("gtm_gpg_use_agent")
	set USER=$ztrnlnm("USER")
	set GNUPGHOMEDIR=$ztrnlnm("GNUPGHOMEDIR")
	set ENVFILE=$piece($zcmdline," ",1)
	set OUTFILE=$piece($zcmdline," ",2)
	; Precreate the files for dumping the environment variables and test output.
	open ENVFILE:newversion
	open OUTFILE:newversion
	; Specify the possible options for an environment variable's state.
	set UNDEFINED=0
	set EMPTY=1
	set INVALID=2
	set VALID=3
	set stateCount=3 ; We do not want to consider UNDEFINED an options since it is the default.
	; Obfuscation key should come before password because of the way maskpass works.
	set vars($increment(varCount))=UNDEFINED,vars(varCount,"name")="gtm_obfuscation_key",gtmObfuscationKey=varCount
	set vars($increment(varCount))=UNDEFINED,vars(varCount,"name")="gtm_passwd",gtmPasswd=varCount
	set vars($increment(varCount))=UNDEFINED,vars(varCount,"name")="GNUPGHOME",gnupghome=varCount
	set vars($increment(varCount))=UNDEFINED,vars(varCount,"name")="GTMXC_gpgagent",gtmxcGpgagent=varCount
	set vars($increment(varCount))=UNDEFINED,vars(varCount,"name")="gtm_crypt_plugin",gtmCryptPlugin=varCount
	set vars($increment(varCount))=UNDEFINED,vars(varCount,"name")="gtmcrypt_config",gtmcryptConfig=varCount
	; Choose the variables to play with.
	set numOfVars=$random(varCount+1) ; Allow to run with the defaults (numOfVars=0).
	for i=1:1:numOfVars do
	.	for  set varIndex=$random(varCount)+1 quit:'$get(vars(varIndex,"used"),0)
	.	set vars(varIndex,"used")=1
	.	set varState=$random(stateCount)+1
	.	set vars(varIndex)=varState
	; Error about decryption has changed in later gpg versions.
	set DECRERROR=$select(20100<version:"Decryption failed",1:"Incorrect password or error while obtaining password")
	; Set the chosen variables appropriately.
	use ENVFILE
	for i=1:1:varCount do
	.	set varName=vars(i,"name")
	.	set varState=vars(i)
	.	if (UNDEFINED=varState) do
	.	.	write "unsetenv "_varName,!
	.	else  if (EMPTY=varState) do
	.	.	write "setenv "_varName_" """"",!
	.	else  do
	.	.	if ("gtm_passwd"=varName) do
	.	.	.	set value=$$generateGtmPasswd(varState,.error)
	.	.	else  if ("GTMXC_gpgagent"=varName) do
	.	.	.	set value=$$generateGtmxcGpgagent(varState,.error)
	.	.	else  if ("gtm_obfuscation_key"=varName) do
	.	.	.	set value=$$generateGtmObfuscationKey(varState,.error)
	.	.	else  if ("GNUPGHOME"=varName) do
	.	.	.	set value=$$generateGnupghome(varState,.error)
	.	.	else  if ("gtm_crypt_plugin"=varName) do
	.	.	.	set value=$$generateGtmCryptPlugin(varState,.error)
	.	.	else  if ("gtmcrypt_config"=varName) do
	.	.	.	set value=$$generateGtmcryptConfig(varState,.error)
	.	.	; Some variables may never be invalid.
	.	.	if (""=error) set vars(i)=VALID
	.	.	else  set vars(i,"error")=error
	.	.	set vars(i,"value")=value
	.	.	if (""=value) write "unsetenv "_varName,!
	.	.	else  write "setenv "_varName_" "_value,!
	; Build up the expectations based on the values chosen.
	use OUTFILE
	if (INVALID=vars(gtmCryptPlugin)) write vars(gtmCryptPlugin,"error"),! quit
	if (UNDEFINED=vars(gtmPasswd)) write "Environment variable gtm_passwd not set",! quit
	if (EMPTY=vars(gtmPasswd)) write "Environment variable gtm_passwd set to empty string",! quit
	if (INVALID=vars(gtmPasswd)) write vars(gtmPasswd,"error"),! quit
	if (UNDEFINED=vars(gnupghome)) write "Could not retrieve encryption key corresponding to file",! quit
	if (EMPTY=vars(gnupghome)) write "Environment variable GNUPGHOME set to empty string",! quit
	if (INVALID=vars(gnupghome)) write vars(gnupghome,"error"),! quit
	if (UNDEFINED=vars(gtmcryptConfig)) write "Environment variable gtmcrypt_config not set",! quit
	if (EMPTY=vars(gtmcryptConfig)) write "Environment variable gtmcrypt_config set to empty string",! quit
	if (INVALID=vars(gtmcryptConfig)) write vars(gtmcryptConfig,"error"),! quit
	if ((UNDEFINED=vars(gtmxcGpgagent))!(EMPTY=vars(gtmxcGpgagent)))&USEAGENT write DECRERROR,! quit
	if (INVALID=vars(gtmxcGpgagent)) write vars(gtmxcGpgagent,"error"),! quit
	write "Created file"
	quit

generateGtmPasswd(state,error)
	new case,return,length
	if (VALID=state) do
	.	set case=$random(2)+1
	.	if (1=case) do
	.	.	set return="`echo gtmrocks | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f 3 -d ' '`"
	.	if (2=case) do
	.	.	set return="`echo gtmrocks | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f 3 -d ' ' | tr '[:upper:]' '[:lower:]'`"
	.	set error=""
	else  do
	.	set case=$random(3)+1
	.	if (1=case) do
	.	.	for  set return=$$^%RANDSTR(8,,"P") quit:(return'["'")&(return'["!")&(return'["{")
	.	.	set return="'"_return_"'"
	.	.	set error="is not a valid digit (0-9, a-f, or A-F)"
	.	if (2=case) do
	.	.	set return=$$^%RANDSTR($random(4)*2+1,,"N")
	.	.	set error="Length is odd"
	.	if (3=case) do
	.	.	set length=$random(512)*2+1024
	.	.	set return=$$^%RANDSTR(length,,"N")
	.	.	set error="Length is "_length
	quit return

generateGtmxcGpgagent(state,error)
	new return
	if (VALID=state) do
	.	set return="$gtm_dist/plugin/gpgagent.tab"
	.	set error=""
	else  do
	.	set return=$$^%RANDSTR(20,,"AN")
	.	set error=$select(USEAGENT:DECRERROR,1:"")
	quit return

generateGtmObfuscationKey(state,error)
	new case,file,saveIO,return
	set case=$random(2)+1
	set file=$$^%RANDSTR(8,,"AN")_".obf"
	set return=file
	set error=""
	if (1=case) do
	.	set saveIO=$io
	.	open file:newversion
	.	use file
	.	write $$^%RANDSTR(20,,"AN")
	.	use saveIO
	quit "$PWD/"_return

generateGnupghome(state,error)
	new return
	if (VALID=state) do
	.	set return=GNUPGHOMEDIR
	.	set error=""
	else  do
	.	write "unsetenv HOME",!
	.	set return=""
	.	set error="Environment variable HOME not set"
	quit return

generateGtmCryptPlugin(state,error)
	new case,return
	if (VALID=state) do
	.	set case=$random(3)+1
	.	if (1=case) do
	.	.	set return="libgtmcrypt_gcrypt_AES256CFB.so"
	.	if (2=case) do
	.	.	set return="libgtmcrypt_openssl_AES256CFB.so"
	.	if (3=case) do
	.	.	set return="libgtmcrypt_openssl_BLOWFISHCFB.so"
	.	set error=""
	else  do
	.	set case=$random(3)+1
	.	if (1=case) do
	.	.	set return=$$^%RANDSTR(20,,"AN")
	.	.	set error="Failed to find symbolic link for"
	.	if (2=case) do
	.	.	set return="../_HO.m"
	.	.	set error="must be relative to"
	.	if (3=case) do
	.	.	set return="$gtm_dist/plugin/gpgagent.tab"
	.	.	set error="Failed to find symbolic link for"
	quit return

generateGtmcryptConfig(state,error)
	new return
	if (VALID=state) do
	.	set return="gtmcrypt.cfg"
	.	set error=""
	else  do
	.	set return=$$^%RANDSTR(20,,"AN")
	.	set error="Cannot stat configuration file"
	quit return
