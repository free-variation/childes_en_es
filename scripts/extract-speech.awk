#!/opt/local/bin/gawk -f 

@include "scripts/util.awk"

function fix_errors(s) {
	return gensub(/(\S*) \[: (\S*)\]/,"\\2", "g", s)
}	


function output_utterance(speaker) {
	gsub(/"/, "", u)
	gsub(/~/, " ", u)

	if (speaker in children) 
		role = "CHI"
	else if (speaker == participants["Mother"] ||
		 speaker == participants["Father"] ||
		 speaker == participants["Investigator"]) {
       role = "MOT"
     }
  else return
  
	sub("*" speaker ":\t", "", u)
	# replace sequences of "word1 [: word2]" with word2
	u = gensub(/(\S+\s+)\[: (\S+)\]/, "\\2", "g", u)
	gsub(/\[[^\]]*\]/, "", u)
	gsub(/[<(]|[>)]/, "", u)
	gsub(/&=\w+/, "", u)
	gsub(/(&|\+)\w*/, "", u)
	gsub(/@\w+/, "", u)
	gsub(/\.\.+/, ".", u)
	gsub(/[^[[:alpha:]].?!' ]/, "", u)
	gsub(/gonna/, "going to", u)
	gsub(/wanna/, "want to", u)
	gsub(/gotta/, "have to", u)
	gsub(/dunno/, "don't know", u)
	gsub(/.[0-9]+_[0-9]+./, "", u)
	gsub(/\x15/, "", u)
	gsub(/[\t]+/, " ", u)
	# weird semi-brackets in Spanish data
	gsub(/[⌈⌉]/, "", u)
	# weird little hack for freeling's analyzer
	u = gensub(/([a-zA-Z])\./, "\\1 .", 1, u)
	

	if (u ~ /[[:alpha:]]/&& u !~ /^ +(((xxx)|(yyy))[[:space:]]+)+\./)
		printf("%s\t%s\t%s\t%s\t%s\t%s\n", corpus, file, name, speaker, role, trim(u))
	in_utterance = 0
}

BEGIN {
	in_utterance = 0
	speaker = ""
}

/@Participants/ {
	nf = split(FILENAME, f, "/") 
	split(f[nf], f1, ".")
	file = f1[1]

	# the brown73/allison and weist/benjamin transcripts don't specify a target child
	if (file ~ /allison[1-6]/ || file ~ /ben[0-9][0-9]/) {
		match($0, /([A-Z0-9]{3})[[:space:]]*([^[:space:]]+)?[[:space:]]*Child/, y)
    children[y[1]] = 1
    name = y[2]
	} else {
    patsplit($0, y, /([A-Z0-9]{3})[[:space:]]*([^[:space:]]+)?[[:space:]]*Target_Child/)
    for (i in y) {
       split(y[i], yy)
       children[yy[1]] = i
       if (i == 1)
         name = yy[2]
    }
	}	

	if (match($0, /([A-Z0-9]{3}) *[^ ]* *Mother/, y))
		participants["Mother"] = y[1]
	if (match($0, /([A-Z0-9]{3}) *[^ ]* *Father/, y))
		participants["Father"] = y[1]
	if (match($0, /([A-Z0-9]{3}) *[^ ]* *Investigator/, y))
		participants["Investigator"] = y[1]

}

/@ID/ {
	split($0, id, "|")
	corpus = id[2]
	
	# the valian and gia corpora don't specify a name.
	if (name == "" || name=="Target_Child") {
		if (corpus == "valian") name = "valian-" substr(file, 1, 2)
		else if (corpus == "Bloom70") name = "Gia"
		else if (corpus == "peters") name = "Seth"
    else if (corpus ~ /change_me_later/) name = "Laura"
		else name = corpus "-" file
	}

  # the weist, aguirre  and Providence corpora is a mess with names.  We'll use the filenames as clues.
  if (corpus == "weist" || corpus == "providence" || corpus == "aguirre") name = substr(file, 1, 3)

  # the irene corpus has no names, but it' all one child
  if (corpus == "lgo") name = "Irene"

  # typo in Snow
  if (corpus == "snow" || name == "Nathanaiel") name = "Nathaniel"
}

/^\*/ {
	if (u != "") {
		output_utterance(speaker)
	} 

	speaker = substr($1, 2, 3)
	
	$1 = ""
	u = fix_errors($0)
	in_utterance = 1
}

$1 ~ /^[^%*@]/ && in_utterance {
	u = u " " fix_errors($0)
}

/^%err/ {
	$1 = ""
	num_errors = split ($0, errors, / ;/)
	
	for (i = 1; i <= num_errors; i++) {
		n = split(errors[i], e)
		if (e[n] ~ /PHO/ || e[n] ~ /MOR/) {
			split(errors[i], f, / = /)
			#print f[1] " -> " f[2]
			gsub(/\$.../, "", f[2])
			gsub(trim(f[1]), trim(f[2]), u)
		}
	}	
}

/^%/ && in_utterance {
	in_utterance = 0
}

END {
	output_utterance(speaker)
}
