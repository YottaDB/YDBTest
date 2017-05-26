main	; Driver program for speed test
	;
	if ^typestr="LOCKI" do ^lckspeed
	if ^typestr["TP" do ^stf
	if ^typestr="ZDSRTST1" do ^ZDSRTST1
	if ^typestr="ZDSRTST2" do ^ZDSRTST2
	if ^typestr="LCL" do ^speed
	if ^typestr["GBL" do ^speed
	q
