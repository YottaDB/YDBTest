#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

touch moustache.q
ln -s moustache.q comb
set linkfile = 'comb'
echo '# Tests for symbolically linked file called moustache.q and link file (comb linked to moustache.q)'
echo '# Tesing write $zparse("comb","","","","SYMLINK"): Expecting full details of file moustache.q in the order DIRECTORY, NAME, TYPE ALL'
$ydb_dist/yottadb -run testzparse^ydb581 $linkfile
echo ""

touch notfound.q
ln -s notfound.q deadlink.l
rm notfound.q
set linkfile = 'deadlink.l'

echo '# Tests for a link file which does not link to any file (notfound.q linked to no file)'
echo '# Testing for write $zparse("deadlink.l","","","","SYMLINK"): Expecting details of link file deadlink.l in the order DIRECTORY, NAME, TYPE, ALL'
$ydb_dist/yottadb -run testzparse^ydb581 $linkfile
echo ""

mkdir surge
touch surge/x.ro
ln -s surge/x.ro y.go
set linkfile = 'y.go'
echo '# Tests for a link file inside another folder (y.go linked to surge/x.ro)'
echo '# Testing for write $zparse("y.go","","","","SYMLINK"): Expecting full details of link file surge/x.ro in the order DIRECTORY, NAME, TYPE, ALL'
$ydb_dist/yottadb -run testzparse^ydb581 $linkfile
echo ""

mkdir -p tp/abcd
touch tp/abcd/x.ro
ln -s abcd/x.ro tp/y.go
set linkfile = 'tp/y.go'
echo '# Tests for a link file inside another folder (tp/y.go linked to tp/abcd/x.ro)'
echo '# Testing for write $zparse("tp/y.go","","","","SYMLINK"): Expecting full details of link file tp/abcd/x.ro in the order DIRECTORY, NAME, TYPE, ALL'
$ydb_dist/yottadb -run testzparse^ydb581 $linkfile
echo ""

mkdir ff
touch ch.ro
ln -s ../ch.ro ff/l.go
set linkfile = 'ff/l.go'
echo '# Tests for a link file inside parent folder (ff/l.go linked to ch.ro)'
echo '# Testing for write $zparse("ff/l.go","","","","SYMLINK"): Expecting full details of link file ch.ro in the order DIRECTORY, NAME, TYPE, ALL'
$ydb_dist/yottadb -run testzparse^ydb581 $linkfile
echo ""

touch noread.ro
ln -s noread.ro nn.go
chmod a-rwx noread.ro
set linkfile = 'nn.go'
echo '# Tests for a link file with no read permission (nn.go linked to noread.ro)'
echo '# Testing for write $zparse("nn.go","","","","SYMLINK"): Expecting full details of link file noread.ro in the order DIRECTORY, NAME, TYPE, ALL'
$ydb_dist/yottadb -run testzparse^ydb581 $linkfile
echo ""

echo '# Tests for a link file with no read permission (nn.go linked to noread.ro) without SYMLINK parameter'
echo '# Testing for write $zparse("nn.go",""): Expecting full details of file nn.go in the order DIRECTORY, NAME, TYPE, ALL'
$ydb_dist/yottadb -run nosymlink^ydb581 $linkfile
echo ""

mkdir noreaddir
touch noreaddir/q.ro
ln -s noreaddir/q.ro np.go
chmod a-x noreaddir
set linkfile = 'np.go'
echo '# Tests for a linked file inside a folder without execute permission (np.go linked to noreaddir/q.ro)'
echo '# Testing for write $zparse("np.go","","","","SYMLINK"): Expecting details of the file np.go in the order DIRECTORY, NAME, TYPE, ALL'
$ydb_dist/yottadb -run testzparse^ydb581 $linkfile
echo ""

echo '# Tests for a linked file inside a folder without execute permission (np.go linked to noreaddir/q.ro) without SYMLINK parameter'
echo '# Testing for write $zparse("np.go",""): Expecting full details of file np.go in the order DIRECTORY, NAME, TYPE, ALL'
$ydb_dist/yottadb -run nosymlink^ydb581 $linkfile
chmod a+rwx noreaddir
echo ""

touch nn.go
mkdir noperm
ln -s ../nn.go noperm/nn.go
chmod a-x noperm
set linkfile = 'noperm/nn.go'
echo '# Tests for a link file inside a folder without execute permission(noperm/nn.go linked to me.ro)'
echo '# Testing for write $zparse("noperm/nn.go","","","","SYMLINK"): Expecting details of the file noperm/nn.go in the order DIRECTORY, NAME, TYPE, ALL'
$ydb_dist/yottadb -run testzparse^ydb581 $linkfile
echo ""

echo '# Tests for a link file inside a folder without execute permission(noperm/nn.go linked to me.ro) without SYMLINK parameter'
echo '# Testing for write $zparse("noperm/nn.go",""): Expecting details of the file noperm/nn.go in the order DIRECTORY, NAME, TYPE, ALL'
$ydb_dist/yottadb -run nosymlink^ydb581 $linkfile
chmod a+x noperm
