	Set output="srntp.mjo0",error="srntp.mje0"
        Open output:newversion,error:newversion
        Use output
        W "PID: ",$J
        Close output
	;
	Set unix=$zv'["VMS"
	For I=1:1:2 do
	. If unix J @("in^lrntp(""set""):(output=""lrntp.mjo"_I_""":error=""lrntp.mje"_I_""")")
	;
	Quit
