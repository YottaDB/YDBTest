;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; less_log test utility routine to filter a source log. Keep only the 'soft connection attempt failed' messages
; as well as the 'YDB-W-REPLALERT' messages but only the first of these in each cluster for reasons described
; in v60000/less_log.csh test script. This filter is used in both 'Test#2' and 'Test#3' in the less_log script.
;
; Note Tests #2/3 specifically has a problem that since the notification interval (interval that REPLALERTs are sent)
; is so short (only 2 seconds), any system load can affect whether or not the last REPLALERT that Test#2 sends
; out ends up in Test#3's log. There is a similar problem when a REPLALERT shows up inbetween the first two soft
; connection attempt failure messages when it normally doesn't. So this filter will ignore any REPLALERT prior
; to seeing TWO of the soft connection attempt failed messages.
;
; Note, each REPLALERT message we process (unless ignored per the rule above) should have a time value that is
; approximately 2 seconds later than the last (we allow up to maxmsgdiff seconds for slow machines). If this
; progression fails, an error is noted.
;
; Because source servers are not shutdown immediately after the final message we want to see is generated (no messages
; after '64 soft connection attempt failed' should be in the reference file), we look for this. We still check the time
; value on each line bypassed in this manner with the exception of the very first REPLALERT in the Test#3 log which
; errantly may be from Test#2's run and which we ignore if we haven't yet seen a soft connection attempt failed message.
;
; Example REPLALERT line (sans timestamp info):
; %YDB-W-REPLALERT, Source Server could not connect to replicating instance [INSTANCE2] for 33 seconds
;
filterSRClog
	set softconntext="soft connection attempt failed"
	set softconndonetext="64 soft"
	set replalerttext="YDB-W-REPLALERT"
	set maxmsgdiff=10			; Max number of seconds between REPLALERT messages
	set minsoftconn=2			; Ignore any REPLALERTs prior to see 2 soft connect attempt warnings
	set cmdline=$zcmdline
	set fname=$zpiece(cmdline," ",1)	; File name to process
	open fname:readonly
	set (softconnmsgcnt,ignorereplalert)=0
	;
	; We will be examining each REPLALERT related line in the output to make sure that the time specified is
	; approximately 2 seconds later than the last (we allow up to maxmsgdiff seconds for slow systems). The
	; hard spin loops are set up to end such that the first REPLALERT message will have a value of either 4
	; or 5 seconds. So we initialize our 'last value for seconds' to 3 because 3+2 gives the expected 5
	; seconds the first message will have.
	;
	set lastsecs=$zpiece(cmdline," ",2)	; Inital seconds to compare to next REPLALERT we see
	set:""=lastsecs lastsecs=3
	;
	set lastWasREPLALERT=0
	for  use fname read line quit:$zeof  do
	. set line=$zextract(line,28,$zlength(line))		; Trim the timestamp off the front of the line
	. if line[softconntext do  quit
	. . set lastWasREPLALERT=0				; The last line was NOT a REPLALERT line
	. . set softconnmsgcnt=softconnmsgcnt+1
	. . use $p
	. . write line,!
	. . set:$zextract(line,1,$zlength(softconndonetext))=softconndonetext ignorereplalert=1
	. if (line[replalerttext) do  quit			; Line contains REPLALERT
	. . if (('lastWasREPLALERT)&('ignorereplalert)) do		; .. and the last line was not a REPLALERT
	. . . ;
	. . . ; This line was a REPLALERT that followed a previous REPLALERT line. Suppress it and other REPLALERT
	. . . ; messages that follow without an intervening soft connection attempt failed message.
	. . . ;
	. . . set lastWasREPLALERT=1
        . . . ;
        . . . ; The beginning of each of our reports should have two soft connect attempt failure messages in it
	. . . ; before we see (or at least pay attention to) any REPLALERT messages. Sometimes, when the soft
	. . . ; connect and alert intervals are 1 and 2 respectively, a small delay can have us putting out both
	. . . ; messages (REPLALERT first) in a single loop in gtmsource_est_conn(). So ignore all REPLALERTs
	. . . ; before we see both soft connect attempt failure messages.
        . . . ;
        . . . if (2<=softconnmsgcnt)&'ignorereplalert do
	. . . . use $p
	. . . . write line,!
        . . if 0<softconnmsgcnt do
	. . . ;
	. . . ; For each REPLALERT we see, it should have a time value approximately 2 seconds later than the previous
	. . . ; REPLALERT. By 'approximately', we'll give it a margin of up to maxmsgdiff seconds. The expected
	. . . ; interval is minsoftconn seconds but system load can cause the actual interval to spread out quite
	. . . ; significantly.
	. . . ;
	. . . set cursecs=$zpiece(line," ",12)			; Grab the seconds field of the REPLALERT line
	. . . if (lastsecs+maxmsgdiff)<cursecs do			; Raise error
	. . . . use $p
	. . . . write "FAILURE - File ",fname," has last REPLALERT time as ",lastsecs," but next one is ",cursecs
	. . . . write " which exceeds the max next time of ",lastsecs+maxmsgdiff," - Fatal error",!
	. . . . close fname
	. . . . zhalt 1
	. . . set lastsecs=cursecs
	close fname
	quit
