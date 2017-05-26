per0509	;per0509 - top level $o problems
	;
	W ! K
	S Z=$O(^%)
	S X="^A",Z=$O(@X)
	S X="^A",Y=X?.E,Z=$O(@X)
	S X="^A",Y=X?@".E",Z=$O(@X)
	S X="^A",Y=X?@".E",Z=$O(@X) ZWR
	s X="^A",Y=X?@".E",Z=$O(@X) ZWR
	W "OK from test of $O at the name level"
	Q
