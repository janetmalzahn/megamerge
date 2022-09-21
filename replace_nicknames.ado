capture program drop replace_nicknames
program define replace_nicknames 
	* replace initials for nicknames in using data
	gen fake_first = first
	replace fake_first = "ROBERT" if inlist(first, "ROB", "BOB", "BOBBY", "ROBBIE", "ROBBY", "BOBBIE") // Robert
	replace fake_first = "RICHARD" if inlist(first, "DICK", "RICHIE", "RICH", "RICHY", "RICK") // Richard
	replace fake_first = "WILLIAM" if inlist(first, "WILL", "WILLIE", "BILL", "BILLIE", "LIAM")
	replace fake_first = "ANTHONY" if inlist(first, "TONY", "ANTON", "ANT") // Anthony
	replace fake_first = "EUGENE" if first == "GENE" // Eugene
	replace fake_first = "ELIZABETH" if inlist(first, "LIZ", "LIZZIE", "ELIZA", "BETH", "LIZZY") // Elizabeth
	replace fake_first = "MARGARET" if inlist(first, "PEG", "PEGGY", "MAGGIE", "MEG", "MEGAN") // Margaret
	replace fake_first = "AARON" if first == "RON" // Aaron
	replace fake_first = "EDWARD" if inlist(first, "ED", "EDDY", "EDDIE", "EDWIN", "EDMUND", "TED", "TEDDY","THEODORE", "THEO") // Edward 
	replace fake_first = "ALEX" if inlist(first, "ZANDER", "ALEXANDER", "LEX") // Alex
	replace fake_first = "JOSEPH" if inlist(first, "JOE", "JOEY", "JO", "JOSIAH") // Joseph
	replace fake_first = "JOSHUA" if inlist(first, "JOSH", "JOSHIE") // Joshua
	replace fake_first = "ELEANOR" if inlist(first, "ELANOR", "ELLE", "ELLIE", "NORA") //Eleanor
	replace fake_first = "ABIGAIL" if inlist(first, "ABBY", "ABBIE", "GAIL") // Abigail
	replace fake_first = "ANN" if inlist(first, "ANNA", "ANNE", "ANNABELL", "ANABELL", "ANABEL", "ANABELLE", "BELL", "BELLE") // Ann
	replace fake_first = "REBECCA" if inlist(first, "REBECKA", "BECKY", "BEX", "REBEKAH") // Rebecca
	replace fake_first = "BENJAMIN" if inlist(first, "BEN", "BENNIE", "BENJI") // Ben
	replace fake_first = "CHARLES" if inlist(first, "CHARLIE", "CHARLEY", "CHUCK", "CHAS") // Charles
	replace fake_first = "DANIEL" if inlist(first, "DANNY", "DAN") // Daniel
	replace fake_first = "DAVID" if inlist(first, "DAVE", "DAVEY", "DAVIE") // David
	replace fake_first = "JOHN" if inlist(first, "JON", "JOHNNY", "JONATHAN", "JOHNNIE", "JONNIE")
	replace fake_first = "CHRIS" if inlist(first, "CHRISTY", "CHRISSY", "TINA", "CHRISTINA", "CHRISTOPHER", "CHRISTOPH", "CRIS", "KRIS") // Chris
	replace fake_first = "JAMES" if inlist(first, "JIM", "JIMMY", "JIMBO", "JIMMIE", "JIMI")
	replace fake_first = "KATHERINE" if inlist(first, "CATHERINE", "KATHERINE", "CATIE", "KATH", "KATIE") // Katherine
	replace fake_first = "MICHAEL" if inlist(first, "MIKE", "MICKEY", "MIKEY", "MICKY", "MICK")
	replace fake_first = "NATHAN" if inlist(first, "NATHANIEL", "NAT", "NATALIE", "NATTIE") // Nats
	replace fake_first = "NICK" if inlist(first, "NICOLAS", "NIC", "NICKO", "NIKKO", "NICHOLAS") // Nick
	replace fake_first = "EZEKIEL" if inlist(first, "ZEKE", "EZEKIAL") // Zeke
	replace fake_first = "FRED" if inlist(first, "FEDERICK", "FREDDY", "FREDDIE", "FREDERIK", "FRIEDERIK") // Fred
	replace fake_first = "JILL" if first ==  "JILLIAN" // Jill
	replace fake_first = "MEG" if inlist(first, "MEGHAN", "MEGAN", "MEAGAN", "MEAGHAN") // Meg
	replace fake_first = "JEN" if inlist(first, "JENNIFER", "JENN", "JENNIE", "JENNY", "JENIFER") // Jen
	replace fake_first = "DOUG" if inlist(first, "DOUGLAS", "DOUGGIE", "DOUGLASS", "DOUGIE", "DUGGIE") // Doug
	replace fake_first = "SAM" if inlist(first, "SAMANTHA", "SAMUEL", "SAMWISE") // Sam
	replace fake_first = "KEN" if inlist(first, "KENNETH", "KENAN", "KENDALL", "KENNEDY", "KENSON", "KENDRICK") // Ken
	replace fake_first = "GREG" if inlist(first, "GREGORY", "GREGG", "GREGOR", "GREGGOR") // Greg
	replace fake_first = "JAN" if inlist(first, "JANET", "JANNET", "JANIS") // JAN
	replace fake_first = "PETE" if inlist(first, "PETER", "PETEY", "PIETER") // PETE
	replace fake_first = "PAM" if first == "PAM" // Pam
end
