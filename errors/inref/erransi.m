ansi ; Test that all ANSI standardized error messages do appear
 Set $ET="Do Trap"
 For ansi=1:1:112 Do
 . Quit:ansi=34  ; Not assigned
 . Quit:ansi=37  ; Only execute this step interactively
 . For i=0:1 Do  Quit:x=""
 . . Xecute "Set x=$Text(M"_ansi_"+"_i_")" 
 . . If i>0,$Extract(x,1)="M" Set x="" Quit
 . . Write !,x
 . . Quit
 . Do @("M"_ansi)
 . Quit
 Quit
 ;
Trap ;
 Use $Principal
 Write !,$ZSTATUS,!,$ECode,! Set $ECode=""
 If $TLevel TROllback
 Quit
 ;
M1 ; Naked indicator undefined
 Set x=$Data(^A) ; Make naked indicator undefined
 Write ^(1)
 Set $ECode=",Z1-Error didn't happen,"
 Quit
 ;
M2 ; Invalid combination with P _fncodatom_
 Write $FNumber(-123,"P+")
 Set $ECode=",Z2-Error didn't happen,"
 Quit
 ;
M3 ; $RANDOM seed less than 1
 Write $Random(-3)
 Set $ECode=",Z3-Error didn't happen,"
 Quit
 ;
M4 ; No true condition in $SELECT
 Write $Select(0:1)
 Set $ECode=",Z4-Error didn't happen,"
 Quit
 ;
M5 ; _lineref_ less than zero
 Set off=-4
 Write $Text(call+off)
 Set $ECode=",Z5-Error didn't happen,"
 Quit
 ;
M6 ; Undefined _lvn_
 Write a
 Set $ECode=",Z6-Error didn't happen,"
 Quit
 ;
M7 ; Undefined _gvn_
 Write ^a
 Set $ECode=",Z7-Error didn't happen,"
 Quit
 ;
M8 ; Undefined _svn_
 Write $apple
 Set $ECode=",Z8-Error didn't happen,"
 Quit
 ;
M9 ; Divide by zero
 Write 1/0
 Set $ECode=",Z9-Error didn't happen,"
 Quit
 ;
M10 ; Invalid pattern match range
 If "abc"?3B
 Set $ECode=",Z10-Error didn't happen,"
 Quit
 ;
M11 ; No parameters passed
 Write !,$Text(pass)
 Do pass
 Quit
 ;
M12 ; Invalid _lineref_ (negative offset)
 Set off=-5
 Do call+off
 Set $ECode=",Z12-Error didn't happen,"
 Quit
 ;
M13 ; Invalid _lineref_ (label not found)
 Do unknown
 Set $ECode=",Z13-Error didn't happen,"
 Quit
 ;
M14 ; _line_ level not 1
 Write !,$Text(indent)
 Do indent
 Set $ECode=",Z14-Error didn't happen,"
 Quit
 ;
M15 ; Undefined index variable
 For i=1:1:5 do
 . If i=2 Kill i
 . Quit
 Set $ECode=",Z15-Error didn't happen,"
 Quit
 ;
M16 ; Argumented QUIT not allowed
 Do exfun(1)
 Set $ECode=",Z16-Error didn't happen,"
 Quit
 ;
M17 ; Argumented QUIT required
 Write $$pass(1)
 Set $ECode=",Z17-Error didn't happen,"
 Quit
 ;
M18 ; Fixed length READ not greater than zero
 read x#-1
 Set $ECode=",Z18-Error didn't happen,"
 Quit
 ;
M19 ; Cannot copy a tree or subtree into itself
 New tree
 Set tree(2)=123
 Merge tree(1)=tree
 Set $ECode=",Z19-Error didn't happen,"
 Quit
 ;
M20 ; _line_ must have _formallist_
 Write !,$Text(call)
 Do call(1)
 Set $ECode=",Z20-Error didn't happen,"
 Quit
 ;
M21 ; Algorithm specification invalid -- Duplicate formal parameter
 Write !,$Text(same)
 do same(1,2)
 Set $ECode=",Z21-Error didn't happen,"
 Quit
 ;
M22 ; SET or KILL to ^$GLOBAL when data in global
 ; _ssvn_s not implemented
 Set $ECode=",Z22-Error didn't happen,"
 Quit
 ;
M23 ; SET or KILL to ^$JOB for non-existent job number
 ; _ssvn_s not implemented
 Set $ECode=",Z23-Error didn't happen,"
 Quit
 ;
M24 ; Change to collation algorithm while subscripted local variables defined
 ; _ssvn_s not implemented
 Set $ECode=",Z24-Error didn't happen,"
 Quit
 ;
M25 ; Attempt to modify currently executing routine
 ZCOMPILE "ansi.m"
 Set $ECode=",Z25-Error didn't happen,"
 Quit
 ;
M26 ; Non-existent _environment_
 Write ^|"nono"|abc
 Set $ECode=",Z26-Error didn't happen,"
 Quit
 ;
M27 ; Attempt to rollback a transaction that is not restartable
 Set ^edm="Before"
 TStart
 Set ^edm="After"
 TREstart
 Set $ECode=",Z27-Error didn't happen,"
 Quit
 ;
M28 ; Mathematical function, parameter out of range
 ; library functions not implemented
 Set $ECode=",Z28-Error didn't happen,"
 Quit
 ;
M29 ; SET or KILL on _ssvn_ not allowed by implementation
 ; _ssvn_s not implemented
 Set $ECode=",Z29-Error didn't happen,"
 Quit
 ;
M30 ; Reference to _glvn_ with different collating sequence within a collating algorithm
 ; ???
 Set $ECode=",Z30-Error didn't happen,"
 Quit
 ;
M31 ; _controlmnemonic_ used for device without a _mnemonicspace_ selected
 Write /CUP(10,10)
 Set $ECode=",Z31-Error didn't happen,"
 Quit
 ;
M32 ; _controlmnemonic_ used in user-defined _mnemonicspace_ which has no associated line
 ; ???
 Set $ECode=",Z32-Error didn't happen,"
 Quit
 ;
M33 ; SET or KILL to ^$ROUTINE when _routine_ exists
 ; _ssvn_s not implemented
 Set $ECode=",Z33-Error didn't happen,"
 Quit
 ;
M34 ; --- currently unassigned ---
 ; n/a
 Set $ECode=",Z34-Error didn't happen,"
 Quit
 ;
M35 ; Device does not support _mnemonicspace_
 Open $Principal:::"UnKnown"
 Set $ECode=",Z35-Error didn't happen,"
 Quit
 ;
M36 ; Incompatible _mnemonicspace_s
 ; ???
 Set $ECode=",Z36-Error didn't happen,"
 Quit
 ;
M37 ; READ from device identified by the empty string
 Use $Principal Write !,"Reading from device <empty>: "
 Use "" Read x
 Set $ECode=",Z37-Error didn't happen,"
 Quit
 ;
M38 ; Invalid _ssvn_ subscript
 Write ^$Routine($Text(+0),"SantaClaus")
 Set $ECode=",Z38-Error didn't happen,"
 Quit
 ;
M39 ; Invalid $NAME argument -- Name of variable expected
 Write $Name(12345)
 Set $ECode=",Z39-Error didn't happen,"
 Quit
 ;
M40 ; Call-by-reference in JOB _actual_
 Job pass(.x)
 Set $ECode=",Z40-Error didn't happen,"
 Quit
 ;
M41 ; Invalid LOCK argument within a TRANSACTION
 Lock +^edm
 TStart
 Lock -^edm
 Set $ECode=",Z41-Error didn't happen,"
 Quit
 ;
M42 ; Invalid QUIT within a TRANSACTION
 Do
 . TStart
 . Quit
 Set $ECode=",Z42-Error didn't happen,"
 Quit
 ;
M43 ; Invalid range ($X, $Y)
 Set $X=-5
 Set $ECode=",Z43-Error didn't happen,"
 Quit
 ;
M44 ; Invalid _command_ outside of a TRANSACTION
 TCOMMIT
 Set $ECode=",Z44-Error didn't happen,"
 Quit
 ;
M45 ; Invalid GOTO reference
 Do
 . Goto call
 . Quit
 Set $ECode=",Z45-Error didn't happen,"
 Quit
 ;
M46 ; Invalid attribute name -- Cannot modify reserved attribute
 ; MWAPI not implemented
 Set $ECode=",Z46-Error didn't happen,"
 Quit
 ;
M47 ; Invalid attribute name -- Cannot modify tied attribute
 ; MWAPI not implemented
 Set $ECode=",Z47-Error didn't happen,"
 Quit
 ;
M48 ; Nonexistent window, element or choice
 ; MWAPI not implemented
 Set $ECode=",Z48-Error didn't happen,"
 Quit
 ;
M49 ; Invalid attempt to set focus
 ; MWAPI not implemented
 Set $ECode=",Z49-Error didn't happen,"
 Quit
 ;
M50 ; Attempt to reference a non M-Term window in an OPEN command
 ; MWAPI not implemented
 Set $ECode=",Z50-Error didn't happen,"
 Quit
 ;
M51 ; Attempt to destroy M-Term window prior to CLOSE
 ; MWAPI not implemented
 Set $ECode=",Z51-Error didn't happen,"
 Quit
 ;
M52 ; Required attribute missing
 ; MWAPI not implemented
 Set $ECode=",Z52-Error didn't happen,"
 Quit
 ;
M53 ; Invalid argument for font function
 ; MWAPI not implemented
 Set $ECode=",Z53-Error didn't happen,"
 Quit
 ;
M54 ; Attempt to create non-modal child of a modal parent
 ; MWAPI not implemented
 Set $ECode=",Z54-Error didn't happen,"
 Quit
 ;
M55 ; Invalid nested ESTART command
 ; MWAPI not implemented
 Set $ECode=",Z55-Error didn't happen,"
 Quit
 ;
M56 ; Name length exceeds implementation's limit
 Set supercalifragilistixexpialidocious=1
 Write ! ZWRITE
 Set $ECode=",Z56-Error didn't happen,"
 Quit
 ;
M57 ; More than one defining occurrence of label in routine
 Do double
 Set $ECode=",Z57-Error didn't happen,"
 Quit
 ;
M58 ; Too few formal parameters
 Do pass(1,2,3,4,5)
 Set $ECode=",Z58-Error didn't happen,"
 Quit
 ;
M59 ; Environment reference not permitted for this _ssvn_
 ; _ssvn_s not implemented
 Set $ECode=",Z59-Error didn't happen,"
 Quit
 ;
M60 ; Undefined _ssvn_
 ; _ssvn_s not implemented
 Set $ECode=",Z60-Error didn't happen,"
 Quit
 ;
M61 ; Attempt to OPEN file with conflicting ACCESS parameters
 ; ???
 Set $ECode=",Z61-Error didn't happen,"
 Quit
 ;
M62 ; Illegal value for ACCESS parameter while attempting to OPEN file
 ; ???
 Set $ECode=",Z62-Error didn't happen,"
 Quit
 ;
M63 ; Illegal value for DISPOSITION parameter while attempting to CLOSE file
 ; ???
 Set $ECode=",Z63-Error didn't happen,"
 Quit
 ;
M64 ; Illegal value for RENAME parameter while attempting to CLOSE file
 ; ???
 Set $ECode=",Z64-Error didn't happen,"
 Quit
 ;
M65 ; Illegal value for VOLUME label
 ; ???
 Set $ECode=",Z65-Error didn't happen,"
 Quit
 ;
M66 ; Illegal value for DENSITY parameter
 ; ???
 Set $ECode=",Z66-Error didn't happen,"
 Quit
 ;
M67 ; Illegal value for ACCESS parameter
 ; ???
 Set $ECode=",Z67-Error didn't happen,"
 Quit
 ;
M68 ; Illegal value for MOUNT parameter
 ; ???
 Set $ECode=",Z68-Error didn't happen,"
 Quit
 ;
M69 ; Attempted tape I/O while no tape mounted
 ; ???
 Set $ECode=",Z69-Error didn't happen,"
 Quit
 ;
M70 ; Illegal value for BLOCKSIZE parameter
 ; ???
 Set $ECode=",Z70-Error didn't happen,"
 Quit
 ;
M71 ; Attempt to read data block larger than buffer size
 ; ???
 Set $ECode=",Z71-Error didn't happen,"
 Quit
 ;
M72 ; Illegal value for recordsize parameter
 ; ???
 Set $ECode=",Z72-Error didn't happen,"
 Quit
 ;
M73 ; Invalid usage of _devicekeyword_ NEWFILE
 ; ???
 Set $ECode=",Z73-Error didn't happen,"
 Quit
 ;
M74 ; Illegal value for TRANSLATION parameter
 ; ???
 Set $ECode=",Z74-Error didn't happen,"
 Quit
 ;
M75 ; String length exceeds implementation's limit
 Set x="" For  Set x=x_"x"
 Set $ECode=",Z75-Error didn't happen,"
 Quit
 ;
M76 ; TCP socket state incorrect for CONNECT or LISTEN
 ; ???
 Set $ECode=",Z76-Error didn't happen,"
 Quit
 ;
M77 ; TCP _deviceattribute_ missing
 ; ???
 Set $ECode=",Z77-Error didn't happen,"
 Quit
 ;
M78 ; TCP _devicekeyword_ missing
 ; ???
 Set $ECode=",Z78-Error didn't happen,"
 Quit
 ;
M79 ; TCP socket allocated to another device
 ; ???
 Set $ECode=",Z79-Error didn't happen,"
 Quit
 ;
M80 ; Network error not otherwise specified
 ; ???
 Set $ECode=",Z80-Error didn't happen,"
 Quit
 ;
M81 ; Unable to establish network connection
 ; ???
 Set $ECode=",Z81-Error didn't happen,"
 Quit
 ;
M82 ; Network connection suspended: wait to resume
 ; ???
 Set $ECode=",Z82-Error didn't happen,"
 Quit
 ;
M83 ; Network connection lost
 ; ???
 Set $ECode=",Z83-Error didn't happen,"
 Quit
 ;
M84 ; Network protocol error: invalid client message
 ; ???
 Set $ECode=",Z84-Error didn't happen,"
 Quit
 ;
M85 ; Network protocol error: invalid server message
 ; ???
 Set $ECode=",Z85-Error didn't happen,"
 Quit
 ;
M86 ; Cannot relinquish device with I/O pending
 ; ???
 Set $ECode=",Z86-Error didn't happen,"
 Quit
 ;
M87 ; Network buffer overflow
 ; ???
 Set $ECode=",Z87-Error didn't happen,"
 Quit
 ;
M88 ; Non-existent _routine_
 ; ???
 Set $ECode=",Z88-Error didn't happen,"
 Quit
 ;
M89 ; Specified pattern is not a _subpattern_
 ; ???
 Set $ECode=",Z89-Error didn't happen,"
 Quit
 ;
M90 ; Invalid _namevalue_
 Write $QLength(123456)
 Set $ECode=",Z90-Error didn't happen,"
 Quit
 ;
M91 ; Routine source is not available
 ; ???
 Set $ECode=",Z91-Error didn't happen,"
 Quit
 ;
M92 ; Mathematical overflow
 Set x=1 For i=1:1:1E6 Set x=x*10
 Set $ECode=",Z92-Error didn't happen,"
 Quit
 ;
M93 ; Mathematical underflow
 Set x=1 For i=1:1:1E6 Set x=x/10
 Write 0.1**2000
 Set $ECode=",Z93-Error didn't happen,"
 Quit
 ;
M94 ; Attempt to compute zero to the zero-th power
 Write 0**0
 Set $ECode=",Z94-Error didn't happen,"
 Quit
 ;
M95 ; Exponentiation returns complex number with non-zero imaginary part
 Write -2**.5
 Set $ECode=",Z95-Error didn't happen,"
 Quit
 ;
M96 ; Attempt to assign value to already valued write-once _ssvn_
 ; _ssvn_s not implemented
 Set $ECode=",Z96-Error didn't happen,"
 Quit
 ;
M97 ; Routine associated with user-defined _ssvn_ does not exist
 ; _ssvn_s not implemented
 Set $ECode=",Z97-Error didn't happen,"
 Quit
 ;
M98 ; Resource unavailable
 ; ???
 Set $ECode=",Z98-Error didn't happen,"
 Quit
 ;
M99 ; Invalid operation for context
 ; ???
 Set $ECode=",Z99-Error didn't happen,"
 Quit
 ;
M100 ; Output time-out expired
 ; ???
 Set $ECode=",Z100-Error didn't happen,"
 Quit
 ;
M101 ; Attempt to assign incorrect value to $ECODE
 Set $ECode="erroneous value"
 Set $ECode=",Z101-Error didn't happen,"
 Quit
 ;
M102 ; Simultaneous synchronous and asynchronous event class
 ; ???
 Set $ECode=",Z102-Error didn't happen,"
 Quit
 ;
M103 ; Invalid event identifier
 ; ???
 Set $ECode=",Z103-Error didn't happen,"
 Quit
 ;
M104 ; IPC event identifier is not a valid job-number
 ; ???
 Set $ECode=",Z104-Error didn't happen,"
 Quit
 ;
M105 ; Object not currently accessible
 ; ???
 Set $ECode=",Z105-Error didn't happen,"
 Quit
 ;
M106 ; Object does not support requested method or property
 ; ???
 Set $ECode=",Z106-Error didn't happen,"
 Quit
 ;
M107 ; Object has no default value
 ; ???
 Set $ECode=",Z107-Error didn't happen,"
 Quit
 ;
M108 ; Value if not of data type OREF
 ; ???
 Set $ECode=",Z108-Error didn't happen,"
 Quit
 ;
M109 ; Undefined _devicekeyword_
 ; ???
 Set $ECode=",Z109-Error didn't happen,"
 Quit
 ;
M110 ; Event identifier not available
 ; ???
 Set $ECode=",Z110-Error didn't happen,"
 Quit
 ;
M111 ; Invalid number of days for date
 ; ???
 Set $ECode=",Z111-Error didn't happen,"
 Quit
 ;
M112 ; Invalid number of seconds for time
 ; ???
 Set $ECode=",Z112-Error didn't happen,"
 Quit
 ;
Mend ;
 ;
 Write !,"At line call - 5"
 Write !,"At line call - 4"
 Write !,"at line call - 3"
 Write !,"At line call - 2"
 Write !,"At line call - 1"
call ; This entry can be called without parameters
 Quit
 ;
pass(a,b,c) ; This entry must be called with parameters
 Quit
 ;
exfun(a,b,c) ; This entry must be called as an extrinsic function
 Quit 1
 ;
indent . Write "This should be an error"
 Quit
 l
same(a,a) ; Does this generate an M21?
 Quit
 ;
double ; first
double ; second
 Quit
 ;
