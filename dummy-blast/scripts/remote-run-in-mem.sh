#!/bin/bash
SSHCMD="ssh -i $HOME/key"
LOGDIR="$HOME/tmp/logs"
touch $LOGDIR/blastp.log
$SSHCMD ubuntu@uvdev-3 "pipelines/blastp -db pipelines/pdb/tiny -query pipelines/query.fa \
	-outfmt 6 | head -n 10 | cut -f 2 > pipelines/top_hits \
	&& echo $? > pipelines/logs/blastp.log \
	&& scp -i $HOME/.ssh/key pipelines/logs/blastp.log ubuntu@uvdev-1:./tmp/logs" &
inotifywait -e close $LOGDIR/blastp.log
echo $?
echo "blastp executed"
touch $LOGDIR/blastdbcmd.log
$SSHCMD ubuntu@uvdev-3 "pipelines/blastdbcmd -db pipelines/pdb/tiny -entry_batch pipelines/top_hits \
       	| head -n 10 > pipelines/out/sequences \
	&& echo $? > pipelines/logs/blastdbcmd.log \
	&& scp -i $HOME/.ssh/key pipelines/logs/blastdbcmd.log ubuntu@uvdev-1:./tmp/logs" &
inotifywait -e close $LOGDIR/blastdbcmd.log
echo $?
echo "blastdbcmd executed"
