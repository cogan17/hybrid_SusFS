# Pembaca sus_kstat_statically.json: array berisi objek dengan 13 field (string atau angka).
# Paham string JSON (termasuk { } " \ di dalamnya) dan escape; tidak memecah per baris.
# Keluaran: satu baris per objek, 13 nilai dipisah TAB, urutan sesuai FIELDS. Keluaran baru dicetak
# setelah SELURUH file sah sampai akhir; ada satu saja kesalahan -> tidak ada keluaran, exit 1.
# path harus absolut; field lain "default" atau bilangan bulat >= 0.
BEGIN {
	for (j = 1; j < 32; j++) CTRL = CTRL sprintf("%c", j) # karakter kontrol mentah tidak sah di string JSON
	nf = split("path ino dev nlink size atime atime_nsec mtime mtime_nsec ctime ctime_nsec blocks blksize", FIELDS, " ")
}
{ s = s $0 "\n" }
function err(m) { printf "kstat json: %s\n", m > "/dev/stderr" }
function ws() { while (i <= n && index(" \t\r\n", substr(s, i, 1))) i++ }
function hexval(h,   j, d, v) {
	v = 0
	for (j = 1; j <= 4; j++) { d = index("0123456789abcdef", tolower(substr(h, j, 1))); if (!d) return -1; v = v * 16 + d - 1 }
	return v
}
function jstr(   c, out, code) { # i di tanda kutip pembuka
	i++; out = ""
	while (i <= n) {
		c = substr(s, i, 1)
		if (c == "\"") { i++; return out }
		if (c == "\\") {
			i++; c = substr(s, i, 1)
			if (c == "n") c = "\n"; else if (c == "t") c = "\t"; else if (c == "r") c = "\r"
			else if (c == "b") c = "\b"; else if (c == "f") c = "\f"
			else if (c == "u") {
				code = hexval(substr(s, i + 1, 4)); i += 4
				# JSON.stringify hanya meng-escape karakter kontrol; selain ASCII tidak didukung di path
				if (code < 1 || code > 126) { badval = 1; c = "" } else c = sprintf("%c", code)
			} else if (c != "\"" && c != "\\" && c != "/") { fatal = "escape tidak sah"; return out }
		}
		else if (index(CTRL, c)) { fatal = "karakter kontrol mentah di dalam string"; return out }
		out = out c; i++
	}
	fatal = "string tidak ditutup"; return out
}
function obj(   k, v, c, j, line) {
	i++; split("", val); badval = 0
	ws()
	if (substr(s, i, 1) == "}") { fatal = "objek kosong"; return }
	while (i <= n) {
		ws(); if (substr(s, i, 1) != "\"") { fatal = "key harus string"; return }
		k = jstr(); if (fatal != "") return
		ws(); if (substr(s, i, 1) != ":") { fatal = "tanda : hilang setelah key " k; return }
		i++; ws(); c = substr(s, i, 1)
		if (c == "\"") { v = jstr(); if (fatal != "") return }
		else if (match(substr(s, i), /^-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][-+]?[0-9]+)?/)) { v = substr(s, i, RLENGTH); i += RLENGTH }
		else { fatal = "nilai field " k " harus string atau angka"; return }
		if (k in val) { fatal = "key ganda: " k; return }
		val[k] = v
		ws(); c = substr(s, i, 1); i++
		if (c == "}") break
		if (c != ",") { fatal = "tanda , atau } hilang"; return }
	}
	line = ""
	for (j = 1; j <= nf; j++) {
		k = FIELDS[j]
		if (!(k in val) || val[k] == "") { fatal = "field " k " hilang/kosong"; return }
		if (index(val[k], "\t") || index(val[k], "\n") || badval) { fatal = "nilai " k " berisi karakter yang tidak didukung"; return }
		if (k == "path" && substr(val[k], 1, 1) != "/") { fatal = "path harus absolut: " val[k]; return }
		if (k != "path" && val[k] != "default" && val[k] !~ /^[0-9]+$/) { fatal = "nilai " k " harus default atau angka: " val[k]; return }
		line = line (j > 1 ? "\t" : "") val[k]
	}
	out[++nout] = line
}
END {
	n = length(s); i = 1; fatal = ""; nout = 0
	ws()
	if (i > n) exit 0 # file kosong: tidak ada aturan
	if (substr(s, i, 1) != "[") { fatal = "JSON harus berupa array" }
	else {
		i++; ws()
		if (substr(s, i, 1) == "]") i++
		else while (1) {
			ws(); if (substr(s, i, 1) != "{") { fatal = "elemen array harus objek"; break }
			obj(); if (fatal != "") break
			ws(); c = substr(s, i, 1); i++
			if (c == "]") break
			if (c != ",") { fatal = "tanda , atau ] hilang"; break }
		}
		if (fatal == "") { ws(); if (i <= n) fatal = "ada isi setelah akhir array" }
	}
	if (fatal != "") { err("JSON tidak sah (" fatal "), tidak ada aturan yang diterapkan"); exit 1 }
	for (j = 1; j <= nout; j++) print out[j]
}
