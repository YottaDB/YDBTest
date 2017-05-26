discr 	; A part of mprof's D9L03002804 and D9L06002815 tests. Determines whether the absolute ratio of two given
	; numbers is within a specified threshold range. Expects the following input parameters: total time measured
	; by OS, total time reported by MPROF, and an expected threshold. If the calculated ratio value is safe, a
	; 'PASS' message is printed; 'FAILURE' is logged otherwise.
	;
	R input
        S totaltime=$P(input," ",$I(index))
        S totalmprof=$P(input," ",$I(index))
	S threshold=$P(input," ",$I(index))
	S discrepancy=(totaltime-totalmprof)/totaltime
	S:discrepancy<0 discrepancy=-discrepancy
	I discrepancy<threshold W "PASSED: time discrepancy is tolerable",!
	E  W "FAILED: time discrepancy "_discrepancy_" > threshold "_threshold,!
	Q
	;
