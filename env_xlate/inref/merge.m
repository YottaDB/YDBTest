merge	;basic test for merge
	s ^a=1
	s ^a(1)=11
	s ^a(2)=12
	s ^a(1,1)=111
	s ^a(1,2)=112
	m ^["/a/b/c","beowulf"]A=^a
	m ^b=^["/a/b/c","beowulf"]A
	;zwr ^["/a/b/c","beowulf"]A ;ZWR does not work with ext.ref.
	zwr ^b
	; if ^b was right, then ^[...]A must have been right
	q
