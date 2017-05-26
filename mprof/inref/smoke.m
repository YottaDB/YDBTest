smoke
	view "TRACE":1:"^TRACE(""BEG"")"
	s dummy=1
	for i=1:1:3 s one=1
	for i=1:1:3 f j=1:1:2 s one=1
end	view "TRACE":0:"^TRACE(""END"")"
	q

