create table Deck (
	rowid integer not null primary key,
	sort_index integer,
	name varchar
);

create table DeckWord (
	rowid integer not null primary key,
	deck integer references Deck(rowid),
	word integer references Word(rowid),
);

create table DeckForm (
	word integer references Word(rowid),
	form integer references Form(rowid),
	deck integer references Deck(rowid)
);