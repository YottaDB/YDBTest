<!---
.. ##############################################################
.. #								#
.. # Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
.. # All rights reserved.					#
.. #								#
.. #	 This document contains the intellectual property	#
.. #	 of its copyright holder(s), and is made available	#
.. #	 under a license.  If you do not know the terms of	#
.. #	 the license, please stop and do not read further.	#
.. #								#
.. ##############################################################
-->

Journaled update throughput
---------------------------

Reports nanoseconds per update, so two builds can be compared directly.

Written for YottaDB/DB/YDB#1258, which changed `SET_GBL_JREC_TIME` to read
`clock_gettime(CLOCK_REALTIME)` in place of `time()`. That is one extra clock read per transaction
commit, about 26 nanoseconds standalone, and this measures what it is worth against the cost of a
commit.

How to run
----------

```
./jnlupdatetime.csh <ydb_dist> [updates per trial] [trials]
```

Once per build, then compare:

```
./jnlupdatetime.csh /usr/library/<build-without-the-change>/pro
./jnlupdatetime.csh /usr/library/<build-with-the-change>/pro
```

Defaults are 200000 updates per trial and 10 trials. It creates its own database under a temporary
directory and removes it on the way out, so it needs no test framework and disturbs nothing.

What it reports
---------------

```
workload   journaling      ns/update
--------   ----------      ---------
point      ON                  477.1
tree       ON                  485.5
point      OFF                 272.8
tree       OFF                 315.6
```

`point` updates the same node over and over. That is the cheapest committed update there is, so a
fixed per commit cost is the largest fraction of it that it can be, which is what makes it the
sensitive workload. `tree` grows a subscripted tree, which is more representative and dilutes the
effect.

Journaling OFF is the CONTROL. `SET_GBL_JREC_TIME` sits inside `if (JNL_ENABLED(csa))` in
`sr_port/t_end.c`, so a change to it cannot move those two rows. Whatever they differ by between
two builds is the noise floor, and a difference in the ON rows has to beat it to mean anything.

Reading the result
------------------

The figure reported is the MINIMUM over the trials, not the mean. The minimum is the trial least
disturbed by whatever else the machine was doing, which is what is wanted when the effect being
looked for is a few percent.

Run this on an IDLE machine. Numbers taken while a test suite was running were wrong by more than
the effect being measured, and were wrong in a way that looked plausible.

Watch the control rows, and believe them over the ON rows. Comparing two builds that differ by more
than the change under test produced this:

```
workload   journaling    before    after     delta
point      ON             462.1    477.1     +15.0
tree       ON             511.1    485.5     -25.6
point      OFF            269.9    272.8      +2.9
tree       OFF            321.8    315.6      -6.2
```

The ON rows disagree about the sign, and the OFF rows, which the change cannot touch, moved as
well. Both are saying the same thing: the two builds differed by something else too, and no
conclusion about the change can be drawn from them. That is the normal case when comparing builds
cut days apart, and it is why a clean measurement needs two builds differing ONLY by the commit
under test, or a within-process method that measures one binary against itself.
