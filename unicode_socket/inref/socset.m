socset
	; Test long strings, this sets up the ^data array for use with socdev.m
	; write strings of growing length upto 1MB
	; #################################################################################################
	; The loop runs from 13 to 20 and at the end we have 2**20 (1MB) bytes processed in the socket
	; At pow = 16 and 17 we test the  delimiters part.
	; for 16 we give 64 delimiters and pass the 64th delimiter at the end of the written data by client
	; without a bang. The corresponding server read should stop on seeing the delimiter
	; for 17 we give 65 delimiters and send the 65th delimiter as a part of the written data by the client followed by any of the 64 delimiters. The server should read the 65th delimiter as well as a data and NOT terminate.
	; for the rest of the iteration the written data by the client ends with a bang which causes the delimiter to be sent across and recognized by the server.
	;
	; NOTE: The $C(xyz) chosen as delimeter will be a part of the ulongstr generated string, so remove them from the string by $TR with an existing character of the ulongstr string. this is done for pow=17, so in future some other delim is chosen make sure that is $TR'ed as well.
	;;;;
	; #################################################################################################
	; There is an existing TR for this test.
	; C9G12-002810 Socket delimiter limit should be increased from 255 to 64*64
	; Rework the 64 delim -255 byte logic once that is resolved.
	; #################################################################################################
	if '$DATA(count) set count=1
	for pow=13:1:20 do
	. set blen=2**pow-1
	. set dlen=2**(pow-12)-9 ;9 because of padding two unique four byte chars to the delimiter at the beginning and end which might cause pow=20 iteration to exceed 255 bytes.
	. set dlmlong=$$^ulongstr(dlen)
	. set strlong=$$^ulongstr(blen)
	. set dlm=$C(918015)_dlmlong_$C(917760)
	. set clen=$length(strlong)
	. ;lets' test the maximum number of delimiters - 64 in 16th and 17th count iteration
	. if pow=16 do
	. . set dlm=$C(65533)
	. . for ii=1:1:63 set dlm=$C(65440+ii)_":"_dlm
	. . set ^data(count,"read")="u tcpdev:(delimiter=delim:width=1048576) r rx s t=$T  u 0 s x=$LENGTH(rx),longstr=$$^ulongstr($ZLENGTH(rx)) if rx'=longstr s x=x_""BADSTRING""  u 0"
	. . set ^data(count,"write")="h 10  u tcpdev:(delimiter=delim:width=1048576) w $$^ulongstr("_blen_")_$C(65533) s x=$x,y=$y u 0"
	. ;;;
	. if pow=17 do
	. . set dlm=$C(57345)
	. . for ii=1:1:60 set dlm=$C(57345+ii)_":"_dlm
	. . set dlm=$C(1902)_":"_$C(1903)_":"_$C(1904)_":"_$C(1905)_":"_dlm
	. . set ^data(count,"read")="u tcpdev:(delimiter=delim:width=1048576) r rx s t=$T  u 0 s x=$LENGTH(rx),longstr=$TRANSLATE($$^ulongstr($ZLENGTH(rx)-3),$C(1902)_$C(1903)_$C(1904)_$C(1905),$C(1901)_$C(1901)_$C(1901)_$C(1901))_$C(57345) if rx'=longstr s x=x_""BADSTRING""  u 0"
	. . set ^data(count,"write")="h 10  u tcpdev:(delimiter=delim:width=1048576) w $TRANSLATE($$^ulongstr("_blen_"),$C(1902)_$C(1903)_$C(1904)_$C(1905),$C(1901)_$C(1901)_$C(1901)_$C(1901))_$C(57345)_$C(1902) s x=$x,y=$y u 0"
	. . set clen=clen+1
	. . set strlong=strlong_$C(57345)
	. ;;;
	. if (pow'=16)&(pow'=17) do
	. . set ^data(count,"read")="u tcpdev:(delimiter=delim:width=1048576) r rx#"_clen_"  r dummyrd s t=$T  u 0 s x=$LENGTH(rx),longstr=$$^ulongstr($ZLENGTH(rx)) if rx'=longstr s x=x_""BADSTRING""  u 0"
	. . set ^data(count,"write")="h 10  u tcpdev:(delimiter=delim:width=1048576) w $$^ulongstr("_blen_"),! s x=$x,y=$y u 0"
	. ;;;
	. set ^data(count,"read","x","ref")=clen
	. set ^data(count,"read","x","bref")=$zlength(strlong)
	. set ^data(count,"read","x","dref")=$zlength(dlm)
	. set ^delim(count)=dlm
	. set ^data("total")=count
	. set count=count+1
	quit
