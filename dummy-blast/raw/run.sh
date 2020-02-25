#!/bin/bash

blastp -db pdb/tiny -query query.fa -outfmt 6 | head -n 10 | cut -f 2 > top_hits

blastdbcmd -db pdb/tiny -entry_batch top_hits | head -n 10 > sequences
