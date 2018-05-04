#!/usr/bin/gawk -f

BEGIN {
  FS = "\t"
}

$5 == "CHI" {
  corpus = $1
  file = $2
  name = $3
  code = $4
  role = $5
  utterance = $6

  names[corpus, file, name] += split(utterance, a, /\w+/) - 1
}

END {
	print "corpus\tfile\tchild.name\twords"
	
	for (i in names) {
		split(i, a, SUBSEP)
		print a[1] "\t" a[2] "\t" a[3] "\t" names[i]
	}
}
