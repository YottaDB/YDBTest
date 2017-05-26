errsmoke
	s $ZTRAP="d err"
	view "TRACE":1:"^TRACE(""BEG"")"
	s dummy=1
	for i=1:1:3 s one=1
	for i=1:1:3 f j=1:1:2 s one=1
	s nowtheerr thiserr
end	view "TRACE":0:"^TRACE(""END"")"
	q
err	w "Wellcome to my world",!
	f i=1:1:5 s errori=i
	h

