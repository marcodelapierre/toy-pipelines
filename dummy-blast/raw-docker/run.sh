#!/bin/bash

./blastp -db pdb/tiny -query query.fa -outfmt 6 2>/dev/null | head -n 10 | cut -f 2 > top_hits

./blastdbcmd -db pdb/tiny -entry_batch top_hits 2>/dev/null | head -n 10 > sequences
