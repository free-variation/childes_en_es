#!/opt/local/bin/gawk -f

BEGIN {
  FS = "\t"
}

{
  corpus = $1
  file = $2
  name = $3
  code = $4
  role = $5
  utterance = $6

  corpora[corpus] += 1
  if (role == "CHI") {
    if (corpus == "fernaguado" || corpus == "becasesno")
      children[corpus, code] += 1
    else
      children[corpus, name ":" code] += 1
  }
  utterances[corpus, role] += 1
  sessions[corpus, file] += 1
  n = split(utterance, a, / +/)
  tokens[corpus, role] += n
  
}

END {
  for (i in children) {
    split(i, a, SUBSEP)
    children_in_corpora[a[1]] += 1
  }
  for (i in sessions) {
    split(i, a, SUBSEP)
    sessions_in_corpora[a[1]] += 1
  }


  print "corpus\tchildren\tsessions\tutt_child\tutt_adult\ttokens_child\ttokens_adult"
  for (corpus in corpora) {
    printf "%s\t%d\t%d\t%d\t%d\t%d\t%d\n", corpus, children_in_corpora[corpus], sessions_in_corpora[corpus],\
              utterances[corpus, "CHI"], utterances[corpus, "MOT"], tokens[corpus, "CHI"], tokens[corpus, "MOT"]
  }
}
