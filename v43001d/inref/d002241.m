d002241	;
	; to test that patterns containing string literals followed by numbers do work fine. (bug reported in Sourceforge)
	;
	s first="for i=0:1:99999 if "
	s last=" write !,i"
	;
	set pattern="i?.1""0""1n",str=first_pattern_last write !,str,! x str
	set pattern="i?.1""1""1n",str=first_pattern_last write !,str,! x str
	set pattern="i?.1""2""1n",str=first_pattern_last write !,str,! x str
	set pattern="i?1""1""1n",str=first_pattern_last write !,str,! x str
	set pattern="i?1""1"".1n",str=first_pattern_last write !,str,! x str
	set pattern="i?1""1"".2n",str=first_pattern_last write !,str,! x str
	set pattern="i?.""1"".2n",str=first_pattern_last write !,str,! x str
	set pattern="i?.""1""2n",str=first_pattern_last write !,str,! x str
	set pattern="i?.""1""1.2n",str=first_pattern_last write !,str,! x str
	set pattern="i?.""12""1.2n",str=first_pattern_last write !,str,! x str
	set pattern="i?.""12"".2n",str=first_pattern_last write !,str,! x str
	;
	; test a similar case where a string literal consisting of lower case letters is followed by the lower case class
	;
	set str="if ""abcd""?.1""ab"".3L w "" abcd""" write !,str,! x str
	set str="if ""abcd""?.1""ab"".3U w "" abcd""" write !,str,! x str
	set str="if ""abCD""?.1""ab"".3L w "" abcd""" write !,str,! x str
	set str="if ""abCD""?.1""ab"".3U w "" abcd""" write !,str,! x str
	;
	; to test that in .U.2L, the .2 is not considered as a simple . (meaning infinite) but instead as 0.2
	; this was a generic parsing bug in patstr.c that showed up while adding the above test cases where
	; if the previous pattern atom that we parsed was an infinite string atom, we will consider the next one too as infinite
	; if the next pattern atom does not have a min-count but instead has a "." followed by a max-count
	;
	set str="if ""AAAa""?.U.2L w "" AAAa""" write !,str,! x str
	set str="if ""AAAab""?.U.2L w "" AAAab""" write !,str,! x str
	set str="if ""AAAabc""?.U.2L w "" AAAabc""" write !,str,! x str
	set str="if ""AAAabcd""?.U.2L w "" AAAabcd""" write !,str,! x str
	set str="if ""AAAabcde""?.U.2L w "" AAAabcde""" write !,str,! x str
	;
	; this is taking the above one step further in order to make sure the "infinite" is not propagated from the 
	;	first pattern atom to the second AND IN TURN third pattern atom
	;
	set str="if ""AAAabcde;;;;;""?.U.2L.2P w "" AAAabcde;;;;;""" write !,str,! x str
	set str="if ""AAAa;;;""?.U.2L.3P w "" AAAa;;;""" write !,str,! x str
	set str="if ""AAAab;;;;""?.U.2L.3P w "" AAAab;;;;""" write !,str,! x str
	set str="if ""AAAabc;;;""?.U.2L.3P w "" AAAabc;;;""" write !,str,! x str
	set str="if ""AAAab;;;""?.U.2L.3P w "" AAAab;;;""" write !,str,! x str
	;
	quit
