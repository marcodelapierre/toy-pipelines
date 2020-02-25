#!/bin/bash

master="192.168.1.11"
remote="192.168.1.30"
key="/home/ubuntu/.ssh/nimbus"
work="/home/ubuntu/work"
logs="/home/ubuntu/logs"



touch $logs/blastp.log
ssh $remote "blastp -db $work/pdb/tiny -query $work/query.fa -outfmt 6 | head -n 10 | cut -f 2 > $work/top_hits \
             && ssh -i $key $master \"echo DONE >$logs/blastp.log\" " &


inotifywait --timeout 30 --event close --quiet $logs/blastp.log >/dev/null
echo blastp $?


touch $logs/dbcmd.log
ssh $remote "blastdbcmd -db $work/pdb/tiny -entry_batch $work/top_hits | head -n 10 > $work/sequences \
             && ssh -i $key $master \"echo DONE >$logs/dbcmd.log\" " &


inotifywait --timeout 30 --event close --quiet $logs/dbcmd.log >/dev/null
echo dbcmd $?

