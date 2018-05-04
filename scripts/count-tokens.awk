#!/usr/bin/gawk -f 
# to get an ordered and sorted list use e.g.
# ./scripts/count-tokens.awk experiments/all_es.tab |sort -k2,2 -k1,1nr > experiments/all_tokens_es.tab

@include "scripts/util.awk"

BEGIN {
	if (lang == "") lang = "en"

	FS = "\t"
}

{
	role = $5
	split($6, a, " ")
	for (i in a) {
		tokens[role, a[i]]++
	}
}

END {
	for (i in tokens) {
		split(i, a, SUBSEP)
		print tokens[i] "\t" a[1] "\t" a[2]
	}
}
