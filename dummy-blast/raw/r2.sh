#!/bin/bash

touch blastp.log
blastp -db pdb/tiny -query query.fa -outfmt 6 | head -n 10 | cut -f 2 > top_hits && sleep 10 && touch blastp.log &


inotifywait --timeout 500 --event close --quiet blastp.log
echo $?


touch dbcmd.log
blastdbcmd -db pdb/tiny -entry_batch top_hits | head -n 10 > sequences && touch dbcmd.log &



