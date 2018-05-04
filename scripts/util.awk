function trim(s) {
	gsub(/^[ \t]+/, "", s)
	gsub(/[ ]+$/, "", s)
	return s
}

function alpha_only(s) {
	gsub(/[^a-zA-Z ]+/, "", s)
	return s
}
