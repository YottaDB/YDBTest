#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

cat << CAT_EOF | sed 's/^/# /;' | sed 's/ $//;'
*****************************************************************
GTM-F171004 - Test the following release note
*****************************************************************

Release note http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-005_Release_Notes.html#GTM-F171004 says:

> GT.M audit logging facilities use tty to label the standard
> input of the process. GT.M places tty=ttyname before the
> command field in all audit log messages. If the standard input
> at process startup is not terminal device, GT.M logs tty=0. In
> addition, the audit facilities check for errors at the time of
> closing a socket / terminating a connection and report them
> with a GTM-E-SOCKCLOSE message to the operator log. The audit
> logger/listener sample programs (downloadable from the A&O
> Guide) switch their log files after receiving a SIGHUP signal.
> The switched log file has a suffix "_%Y%j%H%M%S"
> (yearjuliendayhoursminutesseconds) and the naming convention
> is similar to what GT.M uses for switching journal files. FIS
> recommends periodically switching logger files. Deleting an
> active audit log file makes it lost to new processes, while
> existing processes continue to use it, so FIS recommends
> taking such a step. The sample programs have a Makefile.
>
> Previously, the audit log facilities did not provide tty
> information, did not check and report on errors during socket
> close, the logger/listener programs did not implement a log
> file switching mechanism, and those programs had no Makefile.
> (GTM-F171004)

Originally, there were separate sample programs for different
connection methods: TCP, TCP+TLS and Unix Socket. At YottaDB,
we've merged them into a single one. The differences are:
- connection method can now be selected using a CLI arg,
- as it's a single C source file, no Makefile is needed,
- removed redundant code (signal handling).

Besides these trivial changes, we've added a small feature: the
program now saves a text file including own PID, filename can
be specified as CLI arg.

All other behaviours and the rest of the program code are
unchanged. The modified code is available at
com/audit_listener.c in the YDBTest repository. Compile
and usage documentation can be found at com/audit_listener.md.

Notice:
 Modified com/auditlogfilter.m, the tty (field 7) is now not
 completely masked out:
 - if it's "0" (means STDIN is not a terminal), it's masked as
   other fields
 - else only numbers are masked (pty device index)

GTM-E-SOCKCLOSE is not tested, it needs to interrupt the
client exactly when it sends the log message, which is not
reasonably feasible without white-box testing.

CAT_EOF

echo "# ---- startup ----"

# set prefixes
setenv ydb_msgprefix "GTM"
setenv ydb_prompt "GTM> "

echo '# prepare read-write $gtm_dist directory'
source $gtm_tst/com/copy_ydb_dist_dir.csh ydb_temp_dist
setenv gtm_dist $ydb_dist
chmod -R +wX ydb_temp_dist

# prepare files, and set constants for filenames
set aulogfile=log.txt
set aupidfile=pid.txt
set certfile=$gtm_tst/com/tls/certs/CA/ydbCA.crt
set keyfile=$gtm_tst/com/tls/certs/CA/ydbCA.key

echo "# compile audit_listener utility"
$gt_cc_compiler \
	$gtm_tst/com/audit_listener.c \
	-o $gtm_dist/audit_listener \
	-lssl -lcrypto
if ( ! -x $gtm_dist/audit_listener ) then
	echo "TEST-E-ERROR: failed to compile audit listener utility"
	exit
endif

echo "# allocate port number for TCP and TLS connections"
source $gtm_tst/com/portno_acquire.csh >& portno.out

# set Unix socket filename
#
# Notice on why we use $portno in Unix socket filename:
#   - It's recommended to use full path for socket filenames, they
#     are in a "global namespace": if two programs have different
#     current directory, "my.sock" will point to the _same_ socket.
#     Using absolute paths prevents using the same name. But...
#   - Socket file full path lenght limit is around 100 characters,
#     so we can't use test directory path for this purpose, they
#     contains test version, name, date, random numner, it's a
#     good chance that it will exceed the limit.
# See also:
#   https://unix.stackexchange.com/questions/367008/why-is-socket-path-length-limited-to-a-hundred-chars
#
set uxsock=auditlistener-${portno}.sock

# set crypt config file path and name
if (! $?gtmcrypt_config) then
	setenv gtmcrypt_config `pwd`/gtm_crypt_config.libconfig
endif

echo "# set-up crypt config file for section clicert"
cat >> $gtmcrypt_config << EOF_CLICERT
tls: {
	clicert: {
		CAfile: "$certfile";
	};
}
EOF_CLICERT

echo "# get group ID for restrict.txt"
set gid=`id -gn`

# reset unique filename counter
set unifile_counter = 1

foreach param ( \
	"tcp;#FACILITY#_ENABLE::127.0.0.1:${portno}" \
	"tls;#FACILITY#_ENABLE:TLS:127.0.0.1:${portno}:clicert" \
	"unix_socket;#FACILITY#_ENABLE::${uxsock}" \
	)

	set mode=`echo $param | cut -d';' -f1`
	set restriction=`echo $param | cut -d';' -f2`

	echo "# launch $mode audit_listener"
	rm -f $aulogfile
	if ("$mode" == "tcp") then
		($gtm_dist/audit_listener tcp $aupidfile $aulogfile \
			$portno &) >& audit_listener_${mode}.log
		$gtm_tst/com/wait_for_port_to_be_listening.csh $portno
	endif
	if ("$mode" == "tls") then
		($gtm_dist/audit_listener tls $aupidfile $aulogfile \
			$portno $certfile $keyfile ydbrocks &) >& audit_listener_${mode}.log
		$gtm_tst/com/wait_for_port_to_be_listening.csh $portno
	endif
	if ("$mode" == "unix_socket") then
		($gtm_dist/audit_listener unix $aupidfile $aulogfile \
			$uxsock &) >& audit_listener_${mode}.log
		$gtm_tst/com/wait_for_unix_domain_socket_to_be_listening.csh $uxsock
	endif

	echo "# wait for pidfile"
	# delete restrict.txt, avoid any effect on M script
	rm -f $gtm_dist/restrict.txt
	$gtm_dist/mumps -run waitforfilecreate $aupidfile
	set pid=`cat $aupidfile`

	foreach resetlog ( 0 1 )

		if ($resetlog) then
			set presetlog="yes"
		else
			set presetlog="no"
		endif

		foreach execmode ( "pipe" "terminal" )

			echo
			echo "# ---- connection: $mode, reset_log: $presetlog, input: $execmode ----"

			foreach message ( "DSM" "ISM" "MSM")

				# create a unique message, it will be logged
				set unique_message = "the_message_is_${mode}_${resetlog}_${execmode}_${message}"

				# preserve a timestamp for debugging purposes, see:
				#   https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2106#note_2129635313
				touch audit_${mode}_${resetlog}_${execmode}_${message}.txt

				echo "# setup restrict.txt: audit logging with $mode"
				rm -f $gtm_dist/restrict.txt
				foreach facility ( "AD" "AZA" )
					set restfac = `echo $restriction | sed "s/#FACILITY#/$facility/g"`
					echo $restfac >> $gtm_dist/restrict.txt
				end  # facility
				chmod a-w $gtm_dist/restrict.txt

				if ($resetlog) then

					echo "# delete previous archived log files"
					# actually don't delete, just move out of the way
					set num_rot=`ls -1 | grep ${aulogfile}_ | wc -l`
					if ($num_rot > 0) then
						mkdir -p archived_logs
						set file_list=`ls -1 ${aulogfile}_*`
						foreach file ( $file_list )
							set unifile_postfix=`printf "%05d" $unifile_counter`
							@ unifile_counter++
							mv $file archived_logs/${file}_${unifile_postfix}
						end
					endif

					echo "# reset log by sending SIGHUP to the audit listener"
					set before_epoch=`date -u +"%s"`
					kill -HUP $pid
					set after_epoch=`date -u +"%s"`

					# wait for rotated file, with ~60 sec timeout
					#
					# Notice:
					#   We cannot use "waitforfilecreate" because we don't know the
					#   name of the file to search for, as it contains timestamp.
					#
					@ timeout = 60 * 3
					while (1)
						set num_rot=`ls -1 | grep ${aulogfile}_ | wc -l`
						if ($num_rot > 0) then
							break
						endif
						@ timeout--
						if ($timeout == 0) then
							break
						endif
						sleep 0.3333
					end

					# process rotated file's name
					if ($num_rot == 1) then
						echo "log rotate done"
						echo "# check rotated log filename"

						# cut "%Y%j%H%M%S"-format stamp from filename, then convert to epoch
						# - %j is for Julian, 3-digit day number of the year
						# - if there's more rotation within 1 second, the logger adds extra
						#   _1, _2 etc. prefix from 2nd file, which will not happen now
						#   (as we keep only one archive log file)
						#
						set name_stamp=`ls -1 ${aulogfile}_* | cut -d'_' -f2`
						set name_ye=`echo $name_stamp | cut -c 1-4`
						set name_ju=`echo $name_stamp | cut -c 5-7`
						set name_ho=`echo $name_stamp | cut -c 8-9`
						set name_mi=`echo $name_stamp | cut -c 10-11`
						set name_se=`echo $name_stamp | cut -c 12-13`
						set name_mo=`date -d "${name_ye}-01-01 +${name_ju} days -1 day" "+%m"`
						set name_da=`date -d "${name_ye}-01-01 +${name_ju} days -1 day" "+%d"`
						set name_norm="${name_mo}/${name_da}/${name_ye} ${name_ho}:${name_mi}:${name_se}"
						set name_epoch=`date --date="$name_norm" -u +"%s"`

						# Adjusting BEFORE value - see https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2086
						@ before_epoch -= 2

						if (($before_epoch <= $name_epoch) && ($name_epoch <= $after_epoch)) then
							echo "filename check: pass"
						else
							echo "log filename check failed, BEFORE <= FILENAME_STAMP <= AFTER is not true: $before_epoch <= $name_epoch <= $after_epoch"
						endif

					else
						echo "log rotate failed"
					endif
				else
					echo "# no log reset, append result to existing file"
				endif

				echo "# log message: $unique_message"

				# checkpoint: before
				set before_epoch=`date -u +"%s"`

				if ($execmode == "pipe") then

					# wrap `$unique_message` in `set result=$zauditlog("$unique_message")`
					echo "set result="'$'"zauditlog("'"'"$unique_message"'"'")" \
						| $gtm_dist/mumps -dir \
						|& grep -v '^$' | grep -v '^GTM' | grep -v '^YDB'

                                        echo "# wait for message to be appended to the audit log file"
					# for more information see: https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2086
					$gtm_tst/com/wait_for_log.csh -log ${aulogfile} \
						-message "$unique_message" -duration 600 -waitcreation

					echo "# display audit log file (last entry should include: tty=0 - means STDIN is not a terminal)"
					rm -f $gtm_dist/restrict.txt
					# arg "7" means that 7th field (tty) should NOT be masked
					cat $aulogfile | $gtm_dist/mumps -run "filter^auditlogfilter" 7

				else

					expect -d $gtm_tst/$tst/u_inref/audit_logging-gtmf171004.exp "$unique_message" \
						>>& expect.log
					# preserve expect output for debugging, append a small separator
					echo "--" >> expect.log

                                        echo "# wait for message to be appended to the audit log file"
					$gtm_tst/com/wait_for_log.csh -log ${aulogfile} \
						-message "$unique_message" -duration 600 -waitcreation

					echo "# display audit log file (last entry should include: tty=/dev/pty/<masked>)"
					rm -f $gtm_dist/restrict.txt
					cat $aulogfile | $gtm_dist/mumps -run "filter^auditlogfilter"

				endif

				# checkpoint: after
				set after_epoch=`date -u +"%s"`

				echo "# check if log timestamp falls between before-after checkpoints"
				set log_stamp=`cat $aulogfile | tail -n1 | cut -d';' -f1`
				set log_epoch=`date -u --date="$log_stamp" +%s`

				# Adjusting BEFORE value - see https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2086
				@ before_epoch -= 2
				if (($before_epoch <= $log_epoch) && ($log_epoch <= $after_epoch)) then
					echo "stamp check: pass"
				else
					echo "stamp check failed, BEFORE <= LOG_STAMP <= AFTER is not true: $before_epoch <= $log_epoch <= $after_epoch"
					echo "log stamp: $log_stamp"
					echo "contents of $aulogfile follow:"
    					cat $aulogfile
					# save $aulogfile contents for later debugging
					mv $aulogfile ${aulogfile}_${mode}_${resetlog}_${execmode}.save
				endif

			end  # message
		end  # execmode
	end  # resetlog

	echo "# stop audit_listener and wait for finish"
	kill -TERM $pid >>& waitforproc.log
	$gtm_tst/com/wait_for_proc_to_die.csh $pid >>& waitforproc.log
	rm -f $aupidfile
	rm -f $aulogfile

end  # param (mode and restriction)

echo
echo "# ---- cleanup ----"

echo "# release port number"
$gtm_tst/com/portno_release.csh
