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
# Reads the gdb log produced by the "jnlwritereserve_order-gtmf228991" subtest and reports whether
# "jnl_write_reserve()" is called BEFORE "grab_lock()" within one invocation of "t_end()".
#
# The gdb breakpoints print one "GTMF228991-ORDER: <function>" line per hit. A "t_end" marker ends
# the previous invocation and starts a new one, so the counters are evaluated and then reset there
# (and once more at end of input for the last invocation). Only the first invocation that called
# both functions is reported, so any "grab_lock()" calls made before the update (for example while
# attaching to the journal pool at process startup) are ignored.
#
function check()
{
	if (found)
		return
	if (jwr && gl)
	{
		found = 1
		before = (jwr < gl)
	}
}
BEGIN				{ found = 0; before = 0; jwr = 0; gl = 0; n = 0 }
/^GTMF228991-ORDER: t_end$/	{ check(); jwr = 0; gl = 0; n = 0; next }
/^GTMF228991-ORDER: jnl_write_reserve$/	{ if (!jwr) jwr = ++n; next }
/^GTMF228991-ORDER: grab_lock$/	{ if (!gl)  gl  = ++n; next }
END				{
	check()
	if (!found)
		print "FAIL : no t_end() invocation called both jnl_write_reserve() and grab_lock()"
	else if (before)
		print "PASS : jnl_write_reserve() is called inside t_end() BEFORE grab_lock()"
	else
		print "FAIL : jnl_write_reserve() is called inside t_end() AFTER grab_lock()"
}
