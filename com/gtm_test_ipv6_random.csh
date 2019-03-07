#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Add v46/v6 randomly to hostname if supported
# do_random_settings.csh could randomly define gtm_ipv4_only or ydb_ipv4_only
if ($?ydb_ipv4_only) then
	set ipv4_only = $ydb_ipv4_only
else if ($?gtm_ipv4_only) then
	set ipv4_only = $gtm_ipv4_only
else
	set ipv4_only = 0
endif

if ($ipv4_only) then
	alias host_ipv6_supported '/bin/true \!{:1} ; echo 0'		# Reference !:1 to consume arguments; /bin/true discards arguments
else
	alias host_ipv6_supported '(set rout=`$rsh \!{:1}.v6 /bin/echo ok |& cat` ; set res=0 ; if ("$rout" == "ok") set res=1 ; echo "$rout" >& ipv6_support_\!{:1}.outx ; echo $res)'
endif
set v6_checked=""
if !($?host_suffix_if_ipv6) setenv host_suffix_if_ipv6 ""
foreach hostvar (tst_org_host tst_now_primary tst_remote_host tst_remote_host_{1,2} tst_remote_host_ms_{1,2,3,4,5,6,7,8,9} tst_now_secondary tst_other_servers_list tst_gtcm_server_list tst_other_servers_list_ms)
	if (`eval 'echo $?'${hostvar}`) then
		eval 'set hostval="$'${hostvar}'"'
		set newhostval=()
		foreach hostval_host ($hostval)
			if ($hostval_host != $hostval_host:r:r:r:r) continue				# host suffix already provided
			if ($hostval_host !~ {$v6_checked}) then
				echo "# IPv6 settings for $hostval_host"
				set ipv6_support=`host_ipv6_supported $hostval_host`
				eval setenv host_ipv6_support_$hostval_host $ipv6_support
				if (`eval echo '$?host_suffix_'${hostval_host}`) then 		# host suffix already defined
					eval 'set suffix=$host_suffix_'$hostval_host
				else
					if ($ipv6_support) then
						set suffix=$host_suffix_if_ipv6
					else
						set suffix=''
					endif
				endif
				eval "setenv host_suffix_$hostval_host '$suffix'"
				set v6_checked="$v6_checked,$hostval_host"
			else
				eval 'set suffix=$host_suffix_'$hostval_host
			endif
			set newhostval=(${newhostval} "${hostval_host}${suffix}")
		end
		if ("$hostval" != "$newhostval") then
			eval "setenv ${hostvar} '${newhostval}'"
		endif
	endif
end
unset v6_checked newhostval ipv6_support hostvar hostval_host
