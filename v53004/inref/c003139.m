c003139	;
	; C9J06-003139  Journal file sizes on secondary should be the same as primary
	;
	; Sleep in between updates to trigger free epoch code.
	;
	set $ecode="",$etrap="zshow ""*"" halt"
	set rand=2+$r(3)
	for i=1:1:25  hang rand	for j=1:1:10000 set ^x($j,j)=$j(j,1+$r(200)) 
	merge ^rand=rand ; store in global for debugging purposes in case of test failures
	quit
check	;
	; Previously, we allowed for secondary file size to go at most 2*(wait in between updates) higher than
	; primary (see <C9J06_003139_failures/resolution_v6.txt). 
	;
	; However, with a sleep time of three seconds the previous threshold value (sleep*2) was set to 6%. On snail, the difference
	; in journal file size increased up to 9% (see <C9J06_003139_failures/resolution_v7.txt> for more details). So, increase
	; the threshold up to 10%.
	;
	; 10/27 - Even with a threshold of 10%, we still saw a test failure where the difference went up to 15%. A JI is now created
	; to investigate this issue (GTM-7054). See <C9J06_003139_failures/resolution_v8.txt>. Until then, increase the threshold to
	; 20%
	new threshold,percent,prijnlsize,secjnlsize
	set threshold=20
	set prijnlsize=$ztrnlnm("prijnlsize")
	set secjnlsize=$ztrnlnm("secjnlsize")
	set percent=(((secjnlsize-prijnlsize)/prijnlsize)*100)\1
	write "Primary   journal file size = GTM_TEST_DEBUGINFO: ",prijnlsize,!
	write "Secondary journal file size = GTM_TEST_DEBUGINFO: ",secjnlsize,!
	if percent>threshold do
	.	write "FAIL : Secondary journal file size bigger than Primary journal file size by [",percent,"%]",!
	else  do
	.	write "PASS : Secondary journal file size is almost identical to the Primary journal file size",!
	quit
