	Set output="srtp.mjo0",error="srtp.mje0"
        Open output:newversion,error:newversion
        Use output
        W "PID: ",$J
        Close output
	;
	Set unix=$zv'["VMS"
	For I=1:1:10 do
	. If unix J @("in^srtp(""set""):(output=""srtp.mjo"_I_""":error=""srtp.mje"_I_""")")
	;
	Quit
