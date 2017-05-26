For each server, three files are kept (in $gtm_test/logs/Txxx/profile_v64):
server.dat
server.csv
server.glo

server.csv and server.glo carry the same information, in different formats.
server.dat is the history. It contains version, image, test name and test result for each run.

How to get new performance numbers for the servers

Get exclusive access to the servers for performance testing.

The performance data gets collected in the directory:  
/gtc/staff/gtm_test/current/logs/T<testsource>/profile_v64  
(e.g., testsource=T990)

Each server will have a file :  <server>.dat (e.g., server=jackal).

Before running the tests delete the existing <server>.dat for 
the servers you are performance testing. This is so only your new 
data will be in there.

Run your tests, e.g., twenty times for each server.

Bring up OpenOffice.org Calc
From the menu:
Insert > Sheet from file
Navigate to 
/gtc/staff/gtm_test/current/logs/T<testsource>/profile_v64/jackal.dat

When the Text Import window comes up, make sure Separated by Comma is 
checked.

The spreadsheet should have repeating rows similar to the one below:
...
V9.9-0,PRO,QUE055,345
V9.9-0,PRO,QUE039,104
V9.9-0,PRO,QUE096,130
...

Select the first two columns by the headings, right click, and delete 
columns.

Select the remaining two columns by the headings.  From the menu select 
Data > Sort. Verify the Sort Criteria are Sort by Column A ascending. 

The data is now sorted by function, e.g., QUE number

Scroll down to the last row for the first function, e.g, QUE039. in the 
column next to it, e.g., C, enter without the quotes 
“=AVERAGE(B1:B<the row number>)”

In the next column, e.g,, D, enter without the quotes 
“=STDEV(B1:B<the row number>)”

This will now give you the average and standard deviation.

Select the cells containing the average and standard deviation, 
and right click to copy them.

Scroll down to the end of the entries for the second function, 
e.g., QUE055. Select the two cells next to it, e.g, where the 
average and standard deviation should be. Right click and paste.

Repeat for the final function.

Replace the appropriate numbers for PRO in com/serverconf.m
v70jackalPRO	;
    s ^zzzavg("QUE039")=56.74 s ^zzzstddev("QUE039")=0.78
    s ^zzzavg("QUE055")=171.78 s ^zzzstddev("QUE055")=1.11
    s ^zzzavg("QUE096")=91 s ^zzzstddev("QUE096")=0.78
v64jackalPRO	;
    s ^zzzavg("QUE039")=45.5 s ^zzzstddev("QUE039")=0.51
    s ^zzzavg("QUE055")=128.45 s ^zzzstddev("QUE055")=1.54
    s ^zzzavg("QUE096")=34.35 s ^zzzstddev("QUE096")=0.49
	q
Repeat for the other servers.
