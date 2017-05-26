user1 ;
	write "-----------------------------",!
	set unix=$zv'["VMS"
	if unix set zstr1="$gtm_dist/lke show -all"
	else  set zstr1="@lkechk.com"
	for i=1:1:240 quit:$data(^child)  h 1
	if i=240 w "Timed out: ^child not set by remote_user!"
	write "-----------------------------",!
	write "P1, will now lock ^alongnamecheckingforlocks",!
	lock +^alongnamecheckingforlocks
	zsystem zstr1
	set ^parent="Got lock ^alongnamecheckingforlocks by user1"
	for i=1:1:240 q:$data(^donewithchecking)  h 1
	if i=240 w "Timed out: ^alongnamecheckingforlocks not set by remote_user!"
	write "P1, will now release ^alongnamecheckingforlocks",!
	lock -^alongnamecheckingforlocks
	zsystem zstr1
	s ^released="lock ^alongnamecheckingforlocks released by user1"
	for i=1:1:240 q:$data(^child)=0  h 1
	if i=240 w "Timed out: ^child not killed by remote_user!"
	write ^result,!
	write "-----------------------------",!
	quit
