#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Checks the timer state that YottaDB reports (as a %YDB-I-TEXT) with every %YDB-E-SYSCALL for timer_settime().
# The process that ran the white-box test did no "fork", so the state must be that of a process using its own timer.
# Prints one PASS or WRONG line per message, and a WRONG line if a timer_settime() error carried no timer state.

/SYSCALL.*timer_settime\(\)/ {
	nsyscall++
}

/posix_timer_id: / {
	nmsg++
	match($0, /posix_timer_id: [^]]*\]/)
	s = substr($0, RSTART, RLENGTH)
	sub(/time_to_expir: \[/, "", s)
	sub(/\]$/, "", s)
	split("", v)
	n = split(s, kv, "; ")
	for (i = 1; i <= n; i++) {
		split(kv[i], pair, ": ")
		v[pair[1]] = pair[2]
	}
	wrong = ""
	if (1 != v["posix_timer_created"])
		wrong = wrong " posix_timer_created is " v["posix_timer_created"] ", expected 1;"
	if (0 != v["fork_after_ydb_init"])
		wrong = wrong " fork_after_ydb_init is " v["fork_after_ydb_init"] ", expected 0;"
	if (v["process_id"] != v["getpid()"])
		wrong = wrong " process_id is " v["process_id"] ", expected getpid() " v["getpid()"] ";"
	if (v["posix_timer_thread_id"] != v["gettid()"])
		wrong = wrong " posix_timer_thread_id is " v["posix_timer_thread_id"] ", expected gettid() " v["gettid()"] ";"
	if ((0 > v["tv_sec"]) || (0 > v["tv_nsec"]) || (1000000000 <= v["tv_nsec"]))
		wrong = wrong " time_to_expir is [" v["tv_sec"] ", " v["tv_nsec"] "], expected tv_sec >= 0 and 0 <= tv_nsec < 1000000000;"
	if ("" == wrong)
		print "PASS : message " nmsg " : posix_timer_created is 1, fork_after_ydb_init is 0, process_id is getpid(), posix_timer_thread_id is gettid(), time_to_expir is valid"
	else
		print "WRONG : message " nmsg " :" wrong
}

END {
	if (nmsg != nsyscall)
		print "WRONG : " (nsyscall + 0) " timer_settime() errors but " (nmsg + 0) " carried the timer state"
}
