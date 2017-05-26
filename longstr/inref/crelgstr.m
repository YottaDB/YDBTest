crelgstr;;
	s str1=$$^longstr(32768)
	s str2=$$^longstr(65500)
	s str3=$$^longstr(131072)
	s str4=$$^longstr(1048575)
	s str5=$$^longstr(1048576)
	s str6=$$^longstr(1048574)_"BB"
	w $l(str1)," ",$l(str2)," ",$l(str3)," ",$l(str4)," ",$l(str5)," ",$l(str6),!
