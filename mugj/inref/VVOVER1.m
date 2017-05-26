VVOVER1	;Overview V.7.1 -1-;TS,OVERVIEW,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;Overview of the ANSI/MDC X11.1-1984 Validation Suite Version 7.1
	;
	;                                                           August 31, 1987
	;                                           Copyright: MUMPS System Laboratory
	;
	;1. Introduction 
	;
	;   The  version 7.1 of ANSI/MDC X11.1-1984 Validation Suite is  a complete 
	;revision of the version 6 (October, 1986) to meet the need of FIPS PUB125 for 
	;a conformance test method. The revision was made to endow the validation suite
	;such features as computer detection of passing and failing of each test and  
	;capability of tabulating a result reports. Provision of such features has 
	;greatly facilitated evaluation of the validation result, liberating the work 
	;of evaluation and report writing from the fixed job to a few experienced staffs.
	;
	;   The current Validation Suite V 7.1 composed of Part-I, -II, and -III, has 
	;the total of 2,236 tests. The validation courses of Part-I and Part-II  
	;have their flows controlled by the drivers. In Part-I the course initially 
	;tests very basic functionalities, then incorporats the tested functions for
	;higher levels of functionalities in the manner of bootstrapping. 
	;
	;   The Part-I, having been developed for validating the ANS X11.1-1977 standard
	;specifications after being revised in X11.1-1984, contains 1,946 tests in 192 
	;routines which include a driver (VV1), a report writer, and those which are 
	;externally referenced during main tests. 
	;
	;   The Part-II, which contains 210 tests in 22 routines including a driver (VV2)
	;and a report writer, is targeted for testing the conformance only to the revised
	;and/or extended part of specifications in ANSI/MDC X11.1-1984. 
	;
	;   The Part-III, containing 80 tests in 20 test routines, has the tests for 
	;specific syntaxes as defined to produce errors in ANSI/MDC X11.1-1984. These 
	;tests, requiring series of manual invoking and visual detection one by one
	;being guided by the instruction driver (VVE), are not fully automated. 
	;
	;
	;
	;2. Supply media of the Validation Suite
	;
	;2.1 Floppy disk content: 
	;
	;   OVERVIEW.DOC:  "WordStar" processed documents for this Overview. 
	;   INSTRUCT.DOC:  "WordStar" processed Validation Instructions with Structure 
	;                Tables and Samples of Automated Report Forms for Part-I, II, 
	;                and III. 
	;   VV1DOC.DOC:   "WordStar" processed Content of Validation Items of Part-I,
	;   VV2DOC.DOC:   "WordStar" processed Content of Validation Items of Part-II, 
