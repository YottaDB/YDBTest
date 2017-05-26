	Set output="srntp.mjo0",error="srntp.mje0"
        Open output:newversion,error:newversion
        Use output
        W "PID: ",$J
        Close output
	;
	Set unix=$zv'["VMS"
	For I=1:1:10 do
	. If unix J @("in^srntp(""set""):(output=""srntp.mjo"_I_""":error=""srntp.mje"_I_""")")
	;
	Quit
