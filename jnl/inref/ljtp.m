	Set output="srtp.mjo0",error="srtp.mje0"
        Open output:newversion,error:newversion
        Use output
        W "PID: ",$J
        Close output
	;
	Set unix=$zv'["VMS"
	For I=1:1:2 do
	. If unix J @("in^lrtp(""set""):(output=""lrtp.mjo"_I_""":error=""lrtp.mje"_I_""")")
	;
	Quit
