#!/bin/bash
touch blastp.log
../blastp -db pdb/tiny -query query.fa -outfmt 6 | head -n 10 | cut -f 2 > top_hits \
	&& sleep 10 && echo $? > blastp.log &
inotifywait  -e close  -t 5 blastp.log
echo $?
echo "blastp executed"

../blastdbcmd -db pdb/tiny -entry_batch top_hits | head -n 10 > sequences
