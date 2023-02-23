capture program drop replace_nicknames
program define replace_nicknames 
	* replace initials for nicknames in using data
	gen fake_first = first
	replace fake_first = "ROBERT" if inlist(first, "ROB", "BOB", "BOBBY", "ROBBIE", "ROBBY", "BOBBIE", "ROBERTA", "BERT") // Robert
	replace fake_first = "RICHARD" if inlist(first, "DICK", "RICHIE", "RICH", "RICHY", "RICK") // Richard
	replace fake_first = "WILLIAM" if inlist(first, "WILL", "WILLIE", "BILL", "BILLIE", "LIAM")
	replace fake_first = "ANTHONY" if inlist(first, "TONY", "ANTON", "ANT") // Anthony
	replace fake_first = "EUGENE" if first == "GENE" // Eugene
	replace fake_first = "ELIZABETH" if inlist(first, "LIZ", "LIZZIE", "ELIZA", "BETH", "LIZZY") // Elizabeth
	replace fake_first = "MARGARET" if inlist(first, "PEG", "PEGGY", "MAGGIE", "MEG", "MEGAN", "MARGE", "MARGIE", "MEAGHAN") // Margaret
	replace fake_first = "RON" if inlist(first, "AARON", "RONALD", "RONNIE", "VERONICA") // Ron
	replace fake_first = "ED" if inlist(first, "EDWARD", "EDDY", "EDDIE", "EDWIN", "EDMUND", "TED", "TEDDY","THEODORE", "THEO") // Edward 
	replace fake_first = "ALEX" if inlist(first, "ZANDER", "ALEXANDER", "LEX") // Alex
	replace fake_first = "JOSEPH" if inlist(first, "JOE", "JOEY", "JO", "JOSIAH") // Joseph
	replace fake_first = "JOSHUA" if inlist(first, "JOSH", "JOSHIE") // Joshua
	replace fake_first = "ELEANOR" if inlist(first, "ELANOR", "ELLE", "ELLIE", "NORA") //Eleanor
	replace fake_first = "ABIGAIL" if inlist(first, "ABBY", "ABBIE", "GAIL") // Abigail
	replace fake_first = "ANN" if inlist(first, "ANNA", "ANNE", "ANNABELL", "ANABELL", "ANABEL", "ANABELLE", "BELL", "BELLE") // Ann
	replace fake_first = "REBECCA" if inlist(first, "REBECKA", "BECKY", "BEX", "REBEKAH") // Rebecca
	replace fake_first = "BEN" if inlist(first, "BENJAMIN", "BENNIE", "BENJI", "BENNY") // Ben
	replace fake_first = "CHARLIE" if inlist(first, "CHARLES", "CHARLEY", "CHUCK", "CHAS", "CHAZ", "CHARLOTTE") // Charlie
	replace fake_first = "DAN" if inlist(first, "DANNY", "DANIEL", "DANI", "DANIELLE") // Daniel
	replace fake_first = "DAVID" if inlist(first, "DAVE", "DAVEY", "DAVIE") // David
	replace fake_first = "JOHN" if inlist(first, "JON", "JOHNNY", "JONATHAN", "JOHNNIE", "JONNIE")
	replace fake_first = "CHRIS" if inlist(first, "CHRISTY", "CHRISSY", "TINA", "CHRISTINA", "CHRISTOPHER", "CHRISTOPH", "CRIS", "KRIS", "CHRISTOPHE") // Chris
	replace fake_first = "JAMES" if inlist(first, "JIM", "JIMMY", "JIMBO", "JIMMIE", "JIMI", "JIMMI") // James
	replace fake_first = "KATHERINE" if inlist(first, "CATHERINE", "KATHERINE", "CATIE", "KATH", "KATIE", "KAT", "CAT", "KATARINA") // Katherine
	replace fake_first = "MICHAEL" if inlist(first, "MIKE", "MICKEY", "MIKEY", "MICKY", "MICK")
	replace fake_first = "NAT" if inlist(first, "NATHANIEL", "NATHAN", "NATALIE", "NATTIE") // Nats
	replace fake_first = "NICK" if inlist(first, "NICOLAS", "NIC", "NICKO", "NIKKO", "NICHOLAS", "NICKOLAS") // Nick
	replace fake_first = "ZEKE" if inlist(first, "EZEKIEL", "EZEKIAL") // Zeke
	replace fake_first = "FRED" if inlist(first, "FEDERICK", "FREDDY", "FREDDIE", "FREDERIK", "FRIEDERIK", "FREDERICA") // Fred
	replace fake_first = "JILL" if first ==  "JILLIAN" // Jill
	replace fake_first = "JEN" if inlist(first, "JENNIFER", "JENN", "JENNIE", "JENNY", "JENIFER") // Jen
	replace fake_first = "DOUG" if inlist(first, "DOUGLAS", "DOUGGIE", "DOUGLASS", "DOUGIE", "DUGGIE") // Doug
	replace fake_first = "SAM" if inlist(first, "SAMANTHA", "SAMUEL", "SAMWISE") // Sam
	replace fake_first = "KEN" if inlist(first, "KENNETH", "KENAN", "KENDALL", "KENNEDY", "KENSON", "KENDRICK") // Ken
	replace fake_first = "GREG" if inlist(first, "GREGORY", "GREGG", "GREGOR", "GREGGOR", "GRIGORY") // Greg
	replace fake_first = "JAN" if inlist(first, "JANET", "JANNET", "JANIS", "JANICE") // JAN
	replace fake_first = "PETE" if inlist(first, "PETER", "PETEY", "PIETER") // PETE
	replace fake_first = "PAM" if first == "PAMELA" // Pam
	replace fake_first = "PAT" if inlist(first, "PATRICK", "PATRICIA", "TRISHA", "TRISH") // Pat
	replace fake_first = "BERNIE" if inlist(first, "BERNADETTE", "BERNARD") // Bernie
	replace fake_first = "NEWT" if first == "NEWTON" // Newt
	replace fake_first = "BETH" if inlist(first, "BETHANNY", "BETHANY")
	replace fake_first = "MATT" if inlist(first, "MATTHEW", "MATTY", "MATTHIAS", "MATIAS", "MATTIE")
	replace fake_first = "JEFF" if inlist(first, "JEFFREY", "JEFFERRY", "GEOFF", "GEOFFREY", "GEOFREY", "GEOFFRY")
	replace fake_first = "HANK" if inlist(first, "HENRY", "HAL")
	replace fake_first = "RAY" if first == "RAYMOND"
	replace fake_first = "NORM" if first == "NORMAN"
	replace fake_first = "HERB" if first == "HERBERT"
	replace fake_first = "KIM" if first == "KIMBERLY"
	replace fake_first = "ANDY" if inlist(first, "ANDREW", "ANDRE", "ANDERS", "ANDREAS")
	replace fake_first = "PHIL" if inlist(first, "PHILLIP", "PHILIP", "PHILL")
	replace fake_first = "STAN" if first == "STANLEY"
	replace fake_first = "JERRY" if inlist(first, "JERROD", "JERALD", "JERY", "GERARD", "GERALD", "GARY", "GERRY", "JEROME", "GEROME")
	replace fake_first = "JERRY" if inlist(first, "JERI", "JARED", "JARE", "JERROLD", "GERROLD")
	replace fake_first = "ZACH" if inlist(first, "ZACHARY", "ZACK", "ZACKARY", "ZACK", "ZAC", "ZACHARIAH")
	replace fake_first = "DEB" if inlist(first, "DEBBIE", "DEBBY", "DEBORA", "DEBORAH", "DEBRA")
	replace fake_first = "ROD" if inlist(first, "RODNEY", "RODDY")
	replace fake_first = "DEN" if inlist(first, "DENNIS", "DENNY", "DENISE", "DENNIE", "DENISSE", "DENNISE", "DENIS")
	replace fake_first = "LOU" if inlist(first, "LOUIS", "LOUIE", "LOU")
	
	
	
	
end
