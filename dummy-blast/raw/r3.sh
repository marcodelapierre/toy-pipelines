#!/bin/bash


# definitions

master="nim1"
worker1="nim2"
worker2="nim3"
worker_list="$worker1 $worker2"
worker_first=1
worker_last=2
ident=$( date +%y%m%d%H%M%S )
inp="/dev/shm/inp$ident"
out="/dev/shm/out$ident"
logs="/home/ubuntu/logs$ident"


# setup

wfirst="worker$worker_first"
wfirst=${!wfirst}
wlast="worker$worker_last"
wlast=${!wlast}

mkdir -p $logs
echo Run $ident started | tee -a $logs/master.log
for w in $worker_list ; do
  ssh $w "mkdir -p $inp $out"
  scp -r pdb $w:$inp/ >/dev/null
done


# stage data

scp query.fa $wfirst:$inp/ >/dev/null
echo data staged | tee -a $logs/master.log


# run

touch $logs/blastp.log
ssh $worker1 "blastp -db $inp/pdb/tiny -query $inp/query.fa -outfmt 6 | head -n 10 | cut -f 2 > $out/top_hits" \
  && echo DONE >$logs/blastp.log &

inotifywait --timeout 30 --event close --quiet $logs/blastp.log >/dev/null
echo blastp completed | tee -a $logs/master.log


ssh $worker1 "scp $out/top_hits $worker2:$inp/" #temporary


touch $logs/dbcmd.log
ssh $worker2 "blastdbcmd -db $inp/pdb/tiny -entry_batch $inp/top_hits | head -n 10 > $out/sequences" \
  && echo DONE >$logs/dbcmd.log &

inotifywait --timeout 30 --event close --quiet $logs/dbcmd.log >/dev/null
echo dbcmd completed | tee -a $logs/master.log


# retrieve results

scp $wlast:$out/sequences ./ >/dev/null
echo results retrieved | tee -a $logs/master.log


# clean up

for w in $worker_list ; do
  ssh $w "rm -rf $inp $out"
done
echo Run $ident completed | tee -a $logs/master.log

