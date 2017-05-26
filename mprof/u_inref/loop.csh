#!/usr/local/bin/tcsh

# This is a helper script that runs a simple loop with iterations for
# at least 5 seconds. It is used by D9L06002815 test.

alias date_s "echo '' | $tst_awk '{print systime()}'"
@ time1 = `date_s`
@ time2 = 0

while ($time2 - $time1 < 5)
	@ i = 0
	while ($i < 100000)
		@ i = $i + 1
	end
	@ time2 = `date_s`
end
