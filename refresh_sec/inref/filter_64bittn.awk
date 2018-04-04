#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

{
################################# scan phase block output filter ###############################
gsub("Total blocks in database  -------[ ]*[0-9]* .0x[0-9a-z]*.","Total blocks in database  -------##SCAN_BLOCKS##",$0)
gsub("Total local bitmap blocks -------[ ]*[0-9]* .0x[0-9a-z]*.","Total local bitmap blocks -------##SCAN_BLOCKS##",$0)
gsub("Blocks bypassed -----------------[ ]*[0-9]* .0x[0-9a-z]*.","Blocks bypassed -----------------##SCAN_BLOCKS##",$0)
gsub("Blocks processed ----------------[ ]*[0-9]* .0x[0-9a-z]*.","Blocks processed ----------------##SCAN_BLOCKS##",$0)
gsub("Blocks needing to be split ------[ ]*[0-9]* .0x[0-9a-z]*.","Blocks needing to be split ------##SCAN_BLOCKS##",$0)
gsub("- DT leaf .data. blocks ---------[ ]*[0-9]* .0x[0-9a-z]*.","- DT leaf (data) blocks ---------##SCAN_BLOCKS##",$0)
gsub("- DT index blocks ---------------[ ]*[0-9]* .0x[0-9a-z]*.","- DT index blocks ---------------##SCAN_BLOCKS##",$0)
gsub("- GVT leaf .data. blocks --------[ ]*[0-9]* .0x[0-9a-z]*.","- GVT leaf (data) blocks --------##SCAN_BLOCKS##",$0)
gsub("- GVT index blocks --------------[ ]*[0-9]* .0x[0-9a-z]*.","- GVT index blocks --------------##SCAN_BLOCKS##",$0)
############################ v4dbprepare random globals,records filter #########################
gsub("^--> Number of globals in directory tree : [0-9]*","--> Number of globals in directory tree : ##V4RAND##",$0)
gsub("^--> Number of records in global variable tree : [0-9]*","--> Number of records in global variable tree : ##V4RAND##",$0)
########################### MUPIP upgrade/downgrade statistics filter ##########################
gsub("%GTM-I-MUINFOUINT4, Old file header size : [0-9]* .0x[0-9A-Z]*.","%GTM-I-MUINFOUINT4, Old file header size : ##UPGRD_DWNGRD_BLKS##",$0)
gsub("%GTM-I-MUINFOUINT8, Old file length : [0-9]* .0x[0-9A-Z]*.","%GTM-I-MUINFOUINT8, Old file length : ##UPGRD_DWNGRD_BLKS##",$0)
gsub("%GTM-I-MUINFOUINT4, Old file start_vbn : [0-9]* .0x[0-9A-Z]*.","%GTM-I-MUINFOUINT4, Old file start_vbn : ##UPGRD_DWNGRD_BLKS##",$0)
gsub("%GTM-I-MUINFOUINT4, Old file gds blk_size : [0-9]* .0x[0-9A-Z]*.","%GTM-I-MUINFOUINT4, Old file gds blk_size : ##UPGRD_DWNGRD_BLKS##",$0)
gsub("%GTM-I-MUINFOUINT4, Old file total_blks : [0-9]* .0x[0-9A-Z]*.","%GTM-I-MUINFOUINT4, Old file total_blks : ##UPGRD_DWNGRD_BLKS##",$0)
########################### MUPIP REORG upgrade/downgrade statistics filter ##########################
gsub("Region[$A-Za-z ]*: Statistics : Blocks Read From Disk .Bitmap.     : 0x[0-9A-Z]*","Region ##REG## : Statistics : Blocks Read From Disk (Bitmap)     : ##REORG_BLOCKS##",$0)
gsub("Region[$A-Za-z ]*: Statistics : Blocks Skipped .Free.              : 0x[0-9A-Z]*","Region ##REG## : Statistics : Blocks Skipped (Free)              : ##REORG_BLOCKS##",$0)
gsub("Region[$A-Za-z ]*: Statistics : Blocks Read From Disk .Non-Bitmap. : 0x[0-9A-Z]*","Region ##REG## : Statistics : Blocks Read From Disk (Non-Bitmap) : ##REORG_BLOCKS##",$0)
gsub("Region[$A-Za-z ]*: Statistics : Blocks Skipped .new fmt in disk.   : 0x[0-9A-Z]*","Region ##REG## : Statistics : Blocks Skipped (new fmt in disk)   : ##REORG_BLOCKS##",$0)
gsub("Region[$A-Za-z ]*: Statistics : Blocks Skipped .new fmt in cache.  : 0x[0-9A-Z]*","Region ##REG## : Statistics : Blocks Skipped (new fmt in cache)  : ##REORG_BLOCKS##",$0)
gsub("Region[$A-Za-z ]*: Statistics : Blocks Converted .Bitmap.          : 0x[0-9A-Z]*","Region ##REG## : Statistics : Blocks Converted (Bitmap)          : ##REORG_BLOCKS##",$0)
gsub("Region[$A-Za-z ]*: Statistics : Blocks Converted .Non-Bitmap.      : 0x[0-9A-Z]*","Region ##REG## : Statistics : Blocks Converted (Non-Bitmap)      : ##REORG_BLOCKS##",$0)
gsub("Region[$A-Za-z ]*: Started processing from block number .0x[0-9A-Z]*.","Region ##REG## : Started processing from block number ##REORG_BLOCKS##",$0)
gsub("Region[$A-Za-z ]*: Stopped processing at block number .0x[0-9A-Z]*.","Region ##REG## : Stopped processing at block number ##REORG_BLOCKS##",$0)
gsub("Region[$A-Za-z ]*: Total Blocks = .0x[0-9A-Z]*. : Free Blocks = .0x[0-9A-Z]*. : Blocks to upgrade = .0x[0-9A-Z]*.","Region ##REG## : Total Blocks = ##TOT_BLKS## : Free Blocks = ##FREE_BLKS## : Blocks to upgrade = ##UPG_BLKS##",$0)
gsub("Region[$A-Za-z ]*: MUPIP REORG UPGRADE finished","Region ##REG## : MUPIP REORG UPGRADE finished",$0)
gsub("Region[$A-Za-z ]*: Database is now FULLY UPGRADED","Region ##REG## : Database is now FULLY UPGRADED",$0)
gsub("upgrade[d ]*to GT.M.*","upgrade to GT.M ##MACHTYPE##",$0)
########################### MUPIP upgrade/downgrade dbcertify issues filter ###########################
gsub("%YDB-E-DBMAXREC2BIG, Maximum record size .[0-9][0-9][0-9]. is too large","%YDB-E-DBMAXREC2BIG, Maximum record size ##MAX_REC_SIZE## is too large",$0)
gsub("%YDB-E-DBCMODBLK2BIG, Block 0x[0-9A-Z]*","%YDB-E-DBCMODBLK2BIG, Block ##BLK_NO##",$0)
gsub("%YDB-E-DBCREC2BIG, Record with key .biggbl.[0-9]*. is length [0-9]* in block 0x[0-9A-Z]*","%YDB-E-DBCREC2BIG, Record with key ^biggbl(##KEY##) is length ##SIZE## in block ##BLOCK##",$0)
gsub("%YDB-E-MUDWNGRDTN, Transaction number 0x[0-9A-Z]* in database [A-Za-z. ]*is too big for MUPIP ","%YDB-E-MUDWNGRDTN, Transaction number ##TN## in database ##DATAFILE## is too big for MUPIP ",$0)
gsub("[%-]YDB-E-DYNUPGRDFAIL, Unable to dynamically upgrade block 0x[0-9A-Z]*","%YDB-E-DYNUPGRDFAIL, Unable to dynamically upgrade block ##TN##",$0)
########################### random V4 version chosen filter ###################
gsub("/usr/library/V4[0-9A-Z]*/[a-z][a-z][a-z]","##V4VER##",$0)
###########################  VMS specific filiter for mumps.gld versions ###################
gsub("GTM$TEST_OUT_DIR_C:.TMP.MUMPS.GLD;[0-9]*","GTM$TEST_OUT_DIR_C:[TMP]MUMPS.GLD;##NO##",$0)
########################### integ output ###################
gsub("Directory[ ]*[0-9][0-9]*[ ]*[0-9AN][0-9AN]*[ ]*[0-9.AN][0-9.AN]*[ ]*[0-9AN][0-9AN]*","Directory##INTEG_INFO##")
gsub("Index[ ]*[0-9][0-9]*[ ]*[0-9AN][0-9AN]*[ ]*[0-9.AN][0-9.AN]*[ ]*[0-9AN][0-9AN]*","Index##INTEG_INFO##")
gsub("Data[ ]*[0-9][0-9]*[ ]*[0-9AN][0-9AN]*[ ]*[0-9.AN][0-9.AN]*[ ]*[0-9AN][0-9AN]*","Data##INTEG_INFO##")
gsub("Free[ ]*[0-9][0-9]*[ ]*[0-9AN][0-9AN]*[ ]*[0-9.AN][0-9.AN]*[ ]*[0-9AN][0-9AN]*","Free##INTEG_INFO##")
gsub("Total[ ]*[0-9][0-9]*[ ]*[0-9AN][0-9AN]*[ ]*[0-9.AN][0-9.AN]*[ ]*[0-9AN][0-9AN]*","Total##INTEG_INFO##")
########################### load output ###################
gsub("LOAD TOTAL[:]*[	]*[ ]*Key [Cc]nt:[ ]*[0-9][0-9]*[ ]*[Mm]ax [Ss]ubsc [Ll]en:[ ]*[0-9][0-9]*[ ]*[Mm]ax [Dd]ata [Ll]en:[ ]*[0-9][0-9]*","LOAD TOTAL:         Key cnt: ##KEYCOUNT## max subsc len: ##MAX_SUBSC_LEN## max data len: ##MAX_DATA_LEN##")
}
{print}
