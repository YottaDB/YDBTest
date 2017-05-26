; helper script used in wc_blocked subtest to write an update (and thus cause wc_blocked
; to be set if a specific white-box is enabled) and commit a suicide
setWcBlockedAndKillSelf
	zsystem "echo "_$job_" > pid.outx"
	set ^a=1
	zsystem "kill -9 "_$job
	hang 30 ; in case the kill is delivered asynchronously
	write "TEST-E-FAIL The process did not kill itself in 30 seconds",!
	quit
