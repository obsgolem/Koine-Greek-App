#pragma once

#include "sqlite3.h"

#include "common/common.h"

namespace Dictionary {

const uint8 NO_PERSON = 0;

enum struct Part {
	N, // noun
	A, // adjective
	T, // article
	V, // verb
	P, // personal pronoun
	R, // relative pronoun
	C, // reciprocal pronoun
	D, // demonstrative pronoun
	K, // correlative pronoun
	I, // interrogative pronoun
	X, // indefinite pronoun
	Q, // correlative or interrogative pronoun
	F, // reflexive pronoun
	S, // possessive pronoun
	ADV, // adverb
	CONJ, // conjunction
	COND, // cond
	PRT, // particle
	PREP, // preposition
	INJ, // interjection
	ARAM, // aramaic
	HEB, // hebrew
	N_PRI, // proper noun indeclinable
	A_NUI, // numeral indeclinable
	N_LI, // letter indeclinable
	N_OI, // noun other type indeclinable
};
extern const char *part_names[];

enum struct Case : uint8 {
	X, // no case
	N, // nominative
	V, // vocative
	G, // genitive
	D, // dative
	A, // accusative
};
extern const char *case_names[];

enum struct Number : uint8 {
	X, // No number
	S, // Singular
	P, // Plural
};
extern const char *number_names[];

enum struct Gender : uint8 {
	X, // No gender
	M, // Masculine
	F, // Feminine
	N, // Neuter
};
extern const char *gender_names[];

enum struct Tense : uint8 {
	X,  // no tense
	P,  // present
	I,  // imperfect
	F,  // future
	F2, // second future
	A,  // aorist
	A2, // second aorist
	R,  // perfect
	R2, // second perfect
	L,  // pluperfect
	L2, // second pluperfect
};
extern const char *tense_names[];

enum struct Voice : uint8 {
	X, // no voice
	A, // active
	M, // middle
	P, // passive
	E, // middle or passive
	D, // middle deponent
	O, // passive deponent
	N, // middle or passive deponent
	Q, // impersonal active
};
extern const char *voice_names[];

enum struct Mood : uint8 {
	I, // indicative
	S, // subjunctive
	O, // optative
	M, // imperative
	N, // infinitive
	P, // participle
	R, // imperative participle
};
extern const char *mood_names[];

extern const char *person_names[];

enum struct DeclConj : uint8 {
	O,
	Mi,
	First,
	Second,
	Third,
};
extern const char *declconj_names[];

enum struct Suffix : uint8 {
	X, // None
	S, // Superlative
	C, // Comparative
	ABB, // Abbreviated
	I, // Interrogative
	N, // Negative
	ATT, // Attic
	P, // Particle attached
	K,  // Crasis
};
extern const char *suffix_names[];

enum struct VerbExtra : uint8 {
	X, // None
	M, // middle significance
	C, // contracted form
	T, // transitive
	A, // aeolic
	ATT, // attic
	AP, // apocopated form
	IRR, // irregular or impure form
};
extern const char *verb_extra_names[];

struct Form {
	int id;
	char *str;
};

struct ProForm {
	Form form;

	uint8 person;
	Case case_;
	Number number;
	Gender gender;

	Suffix suffix;
};

struct PossesiveProForm {
	Form form;

	uint8 person_possesor;
	Number number_possesor;
	Case case_possesed;
	Number number_possesed;
	Gender gender_possesed;

	Suffix suffix;
};

struct CNGForm {
	Form form;

	Case case_;
	Number number;
	Gender gender;

	Suffix suffix;
};

struct VerbForm {
	Form form;

	Tense tense;
	Voice voice;
	Mood mood;

	uint8 person;
	Case case_;

	Number number;
	Gender gender; // Optional

	VerbExtra verb_extra;
};

struct OtherForm {
	Form form;

	Suffix suffix;
};

struct Word {
	int id;

	Part part;
	DeclConj declconj;

	int count;

	int strongs;

	char *lemma;
	char *gloss;
	char *definition;
	char *root;
	char *search_string;

	union {
		ProForm *pro_forms;
		PossesiveProForm *pos_pro_forms;
		CNGForm *cng_forms;
		VerbForm *verb_forms;
		OtherForm *other_forms;
		void *forms_pointer;
	};

	bool handle_memory;
};

struct Dictionary {
	sqlite3 *db;

	int word_count;

	sqlite3_stmt *insert_word;
	sqlite3_stmt *insert_form;

	sqlite3_stmt *insert_pro_form;
	sqlite3_stmt *insert_pos_pro_form;
	sqlite3_stmt *insert_cng_form;
	sqlite3_stmt *insert_verb_form;
	sqlite3_stmt *insert_other_form;

	sqlite3_stmt *get_all_words_count;
	sqlite3_stmt *get_all_words_strongs;
	sqlite3_stmt *search_words;

	sqlite3_stmt *get_word_index;
	sqlite3_stmt *get_word_id;
	sqlite3_stmt *get_word_strongs;

	sqlite3_stmt *get_word_search_string;

	sqlite3_stmt *load_all_forms;
	sqlite3_stmt *load_form_pro_form;
	sqlite3_stmt *load_form_pos_pro_form;
	sqlite3_stmt *load_form_cng_form;
	sqlite3_stmt *load_form_verb_form;
	sqlite3_stmt *load_form_other_form;

	sqlite3_stmt *delete_form;
	sqlite3_stmt *delete_form_pro_form;
	sqlite3_stmt *delete_form_pos_pro_form;
	sqlite3_stmt *delete_form_cng_form;
	sqlite3_stmt *delete_form_verb_form;
	sqlite3_stmt *delete_form_other_form;

	sqlite3_stmt *update_word;

	sqlite3_stmt *update_form;
	sqlite3_stmt *update_pro_form;
	sqlite3_stmt *update_pos_pro_form;
	sqlite3_stmt *update_cng_form;
	sqlite3_stmt *update_verb_form;
	sqlite3_stmt *update_other_form;

	sqlite3_stmt *get_form;
	sqlite3_stmt *get_form_pro_form;
	sqlite3_stmt *get_form_pos_pro_form;
	sqlite3_stmt *get_form_cng_form;
	sqlite3_stmt *get_form_verb_form;
	sqlite3_stmt *get_form_other_form;
};

const char * getPersonName(uint8 person);

Dictionary * open(const char *name);
void addWord(Dictionary *dict, Word *word, bool = true);
void prepareStmt(Dictionary *dict, const char *string, sqlite3_stmt **stmt);
void addProForm(Dictionary *dict, Word *word, ProForm *form);
void addPossesiveProForm(Dictionary *dict, Word *word, PossesiveProForm *form);
void addCNGForm(Dictionary *dict, Word *word, CNGForm *form);
void addVerbForm(Dictionary *dict, Word *word, VerbForm *form);
void addOtherForm(Dictionary *dict, Word *word, OtherForm *form);
void tryAddExistingProForm(Dictionary::Dictionary *dict, Word *word, ProForm *form);
void tryAddExistingPossesiveProForm(Dictionary::Dictionary *dict, Word *word, PossesiveProForm *form);
void tryAddExistingCNGForm(Dictionary::Dictionary *dict, Word *word, CNGForm *form);
void tryAddExistingVerbForm(Dictionary::Dictionary *dict, Word *word, VerbForm *form);
void tryAddExistingOtherForm(Dictionary::Dictionary *dict, Word *word, OtherForm *form);
Word * getWordFromResult(sqlite3_stmt *stmt, Word * = 0, bool = false);
Word * getAllWordsByStrongs(Dictionary *dict);
Word * getAllWordsByCount(Dictionary *dict);
Word * getWordSearch(Dictionary *dict, const char *search);
Word * getWordIndex(Dictionary *dict, int index, Word * = 0, bool = false);
Word * getWordID(Dictionary *dict, int strongs, Word * = 0, bool = false);
Word * getWordStrongs(Dictionary *dict, int strongs, Word * = 0, bool = false);
void getWordSearchString(Dictionary *dict, Word *word);
void deleteForm(Dictionary *dict, Word *word, uint64 i);
void loadAllForms(Dictionary *dict, Word *word);
void updateWord(Dictionary *dict, Word *word);
void updateForm(Dictionary *dict, Form *form);
void updateProForm(Dictionary *dict, ProForm *form);
void updatePossesiveProForm(Dictionary *dict, PossesiveProForm *form);
void updateCNGForm(Dictionary *dict, CNGForm *form);
void updateVerbForm(Dictionary *dict, VerbForm *form);
void updateOtherForm(Dictionary *dict, OtherForm *form);
void clearWordMemory(Word *word);
void clearWordFormListMemory(Word *word);
Form * getFormFromForms(Word *word, uint64 i);

#if defined(DICT_IMPL)

const char *insert_word_string = "insert into Word(part, count, declconj, strongs, lemma, definition, search_string) values (?, 1, ?, ?, ?, ?, ?)";
const char *insert_form_string = "insert into Form(word, string) values (?, ?)";
const char *insert_pro_form_string = "insert into ProForm(formid, person, case_, number, gender, suffix) values (?, ?, ?, ?, ?, ?)";
const char *insert_pos_pro_form_string = "insert into PossesiveProForm(formid, person_possesor, number_possesor, case_possesed, number_possesed, gender_possesed, suffix) values (?, ?, ?, ?, ?, ?, ?)";
const char *insert_cng_form_string = "insert into CNGForm(formid, case_, number, gender, suffix) values (?, ?, ?, ?, ?)";
const char *insert_verb_form_string = "insert into VerbForm(formid, tense, voice, mood, person, case_, number, gender, verb_extra) values (?, ?, ?, ?, ?, ?, ?, ?, ?)";
const char *insert_other_form_string = "insert into OtherForm(formid, suffix) values (?, ?)";

const char *get_all_words_count_string = "select * from Word order by count desc;";
const char *get_all_words_strongs_string = "select * from Word order by strongs asc;";
const char *search_words_string = "select * from Word where search_string like ? || '%' order by count desc;";

const char *get_word_index_string = "select * from Word order by count desc limit 1 offset ?";
const char *get_word_id_string = "select * from Word where rowid = ?";
const char *get_word_strongs_string = "select * from Word where strongs = ? limit 1";

const char *get_word_search_string_string = "select search_string from Word where rowid = ?";

const char *load_all_forms_string = "select * from Form where word = ?";
const char *load_form_pro_form_string = "select * from ProForm where rowid = ?";
const char *load_form_pos_pro_form_string = "select * from PossesiveProForm where rowid = ?";
const char *load_form_cng_form_string = "select * from CNGForm where rowid = ?";
const char *load_form_verb_form_string = "select * from VerbForm where rowid = ?";
const char *load_form_other_form_string = "select * from OtherForm where rowid = ?";

const char *delete_form_string = "delete from Form where rowid = ?";
const char *delete_form_pro_form_string = "delete from ProForm where formid = ?";
const char *delete_form_pos_pro_form_string = "delete from PossesiveProForm where formid = ?";
const char *delete_form_cng_form_string = "delete from CNGForm where formid = ?";
const char *delete_form_verb_form_string = "delete from VerbForm where formid = ?";
const char *delete_form_other_form_string = "delete from OtherForm where formid = ?";

const char *update_word_string = "update Word set part = ?, count = ?, declconj = ?, strongs = ?, lemma = ?, definition = ?, root = ?, gloss = ? where rowid = ?";

const char *update_form_string = "update Form set string = ? where rowid = ?";
const char *update_pro_form_string = "update ProForm set person = ?, case_ = ?, number = ?, gender = ?, suffix = ? where formid = ?";
const char *update_pos_pro_form_string = "update PossesiveProForm set person_possesor = ?, number_possesor = ?, case_possesed = ?, number_possesed = ?, gender_possesed = ?, suffix = ? where formid = ?";
const char *update_cng_form_string = "update CNGForm set case_ = ?, number = ?, gender = ?, suffix = ? where formid = ?";
const char *update_verb_form_string = "update VerbForm set tense = ?, voice = ?, mood = ?, person = ?, case_ = ?, number = ?, gender = ?, verb_extra = ? where formid = ?";
const char *update_other_form_string = "update OtherForm set suffix = ? where formid = ?";

const char *get_form_string = "select * from Form where rowid = ?";
const char *get_form_pro_form_string = "select * from ProForm inner join Form on (formid = rowid) where person = ? and case_ = ? and number = ? and gender = ? and suffix = ? and word = ?";
const char *get_form_pos_pro_form_string = "select * from PossesiveProForm inner join Form on (formid = rowid) where person_possesor = ? and number_possesor = ? and case_possesed = ? and number_possesed = ? and gender_possesed = ? and suffix = ? and word = ?";
const char *get_form_cng_form_string = "select * from CNGForm inner join Form on (formid = rowid) where case_ = ? and number = ? and gender = ? and suffix = ? and word = ?";
const char *get_form_verb_form_string = "select * from VerbForm inner join Form on (formid = rowid) where tense = ? and voice = ? and mood = ? and person = ? and case_ = ? and number = ? and gender = ? and verb_extra = ? and word = ?";
const char *get_form_other_form_string = "select * from OtherForm inner join Form on (formid = rowid) where suffix = ? and word = ?";

const char *part_names[] = {
	"Noun",
	"Adjective",
	"Article",
	"Verb",
	"Personal pronoun",
	"Relative pronoun",
	"Reciprocal pronoun",
	"Demonstrative pronoun",
	"Correlative pronoun",
	"Interrogative pronoun",
	"Indefinite pronoun",
	"Correlative or interrogative pronoun",
	"Reflexive pronoun",
	"Possessive pronoun",
	"Adverb",
	"Conjunction",
	"Cond",
	"Particle",
	"Preposition",
	"Interjection",
	"Aramaic",
	"Hebrew",
	"Proper noun indeclinable",
	"Numeral indeclinable",
	"Letter indeclinable",
	"Noun other type indeclinable",
};

const char *case_names[] = {
	"No case",
	"Nominative",
	"Vocative",
	"Genitive",
	"Dative",
	"Accusative",
};

const char *number_names[] {
	"No number",
	"Singular",
	"Plural",
};

const char *gender_names[] {
	"No gender",
	"Masculine",
	"Feminine",
	"Neuter",
};

const char *tense_names[] {
	"No tense",
	"Present",
	"Imperfect",
	"Future",
	"Second future",
	"Aorist",
	"Second aorist",
	"Perfect",
	"Second perfect",
	"Pluperfect",
	"Second pluperfect",
};

const char *voice_names[] = {
	"No voice",
	"Active",
	"Middle",
	"Passive",
	"Middle or passive",
	"Middle deponent",
	"Passive deponent",
	"Middle or passive deponent",
	"Impersonal active",
};

const char *mood_names[] = {
	"Indicative",
	"Subjunctive",
	"Optative",
	"Imperative",
	"Infinitive",
	"Participle",
	"Imperative participle",
};

const char *person_names[] {
	"No Person",
	"1st",
	"2nd",
	"3rd",
};

const char *suffix_names[] = {
	"None",
	"Superlative",
	"Comparative",
	"Abbreviated",
	"Interrogative",
	"Negative",
	"Attic",
	"Particle attached",
	"Crasis",
};

const char *verb_extra_names[] {
	"None",
	"middle significance",
	"contracted form",
	"transitive",
	"aeolic",
	"attic",
	"apocopated form",
	"irregular or impure form",
};

const char *declension_names[] {
	"1st",
	"2nd",
	"3rd",
};

const char *conjugation_names[] {
	"ω",
	"μι",
};

const char *declconj_names[] {
	"ω",
	"μι",
	"1st",
	"2nd",
	"3rd",
};

const char * getPersonName(uint8 person) {
	if(person == 1) {
		return "1st";
	}
	else if(person == 2) {
		return "2nd";
	}
	else {
		return "3rd";
	}
}

Dictionary * open(const char *name) {
	Dictionary *dict = (Dictionary *) calloc(sizeof(Dictionary), 1);
	if(sqlite3_open(name, &dict->db) == SQLITE_OK) {
		sqlite3_stmt *stmt;
		sqlite3_prepare_v2(dict->db, "select count(1) from Word", -1, &stmt, 0);
		sqlite3_step(stmt);
		dict->word_count = sqlite3_column_int64(stmt, 0);
		sqlite3_finalize(stmt);

		return dict;
	}
	else {
		printf("%s\n", sqlite3_errmsg(dict->db));
		abort();
	}
}

void prepareStmt(Dictionary *dict, const char *string, sqlite3_stmt **stmt) {
	if(!(*stmt)) {
		if(sqlite3_prepare_v2(dict->db, string, -1, stmt, 0) != SQLITE_OK) {
			printf("%s\n", sqlite3_errmsg(dict->db));
			abort();
		}
	}
}
#define PREPARE_STMT(dict, stmt) prepareStmt(dict, (stmt##_string), &dict->stmt);

void addWord(Dictionary *dict, Word *word, bool set_declconj) {
	PREPARE_STMT(dict, insert_word);

	if(set_declconj) {
		uint64 length = strlen(word->lemma);

		if(word->part == Part::N) {
			auto two_back = findPreviousUTF8Char(&word->lemma[length], word->lemma, 2);
			auto one_back = findPreviousUTF8Char(&word->lemma[length], word->lemma, 1);

			if(one_back && two_back) {
				if(strcmp(two_back, "ός") == 0 || strcmp(two_back, "ος") == 0 || strcmp(two_back, "ον") == 0 || strcmp(two_back, "όν") == 0) {
					word->declconj = DeclConj::Second;
				}
				else if(strcmp(two_back, "ής") == 0 || strcmp(two_back, "ης") == 0 || strcmp(one_back, "η") == 0 || strcmp(one_back, "ή") == 0 || strcmp(one_back, "α") == 0 || strcmp(one_back, "ά") == 0) {
					word->declconj = DeclConj::First;
				}
				else {
					word->declconj = DeclConj::Third;
				}
			}
		}
		else if(word->part == Part::V) {
			word->declconj = DeclConj::O;
			auto two_back = findPreviousUTF8Char(&word->lemma[length], word->lemma, 2);

			if(two_back) {
				if(strcmp(two_back, "μί") == 0 || strcmp(two_back, "μι") == 0) {
					word->declconj = DeclConj::Mi;
				}
			}
		}
	}

	sqlite3_bind_int64(dict->insert_word, 1, (uint8) word->part);
	sqlite3_bind_int64(dict->insert_word, 2, (uint8) word->declconj);
	sqlite3_bind_int64(dict->insert_word, 3, word->strongs);
	sqlite3_bind_text(dict->insert_word, 4, word->lemma, -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(dict->insert_word, 5, word->definition, -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(dict->insert_word, 6, word->search_string, -1, SQLITE_TRANSIENT);
	sqlite3_step(dict->insert_word);

	word->id = sqlite3_last_insert_rowid(dict->db);

	sqlite3_reset(dict->insert_word);
}

void addProForm(Dictionary *dict, Word *word, ProForm *form) {
	PREPARE_STMT(dict, insert_form);
	PREPARE_STMT(dict, insert_pro_form);

	sqlite3_bind_int64(dict->insert_form, 1, word->id);
	sqlite3_bind_text(dict->insert_form, 2, form->form.str, -1, SQLITE_TRANSIENT);
	sqlite3_step(dict->insert_form);

	sqlite3_int64 rowid = sqlite3_last_insert_rowid(dict->db);
	form->form.id = rowid;
	sqlite3_reset(dict->insert_form);

	sqlite3_bind_int64(dict->insert_pro_form, 1, rowid);
	sqlite3_bind_int64(dict->insert_pro_form, 2, form->person);
	sqlite3_bind_int64(dict->insert_pro_form, 3, (uint8) form->case_);
	sqlite3_bind_int64(dict->insert_pro_form, 4, (uint8) form->number);
	sqlite3_bind_int64(dict->insert_pro_form, 5, (uint8) form->gender);
	sqlite3_bind_int64(dict->insert_pro_form, 6, (uint8) form->suffix);
	sqlite3_step(dict->insert_pro_form);
	sqlite3_reset(dict->insert_pro_form);
}

void tryAddExistingProForm(Dictionary::Dictionary *dict, Word *word, ProForm *form) {
	PREPARE_STMT(dict, get_form_pro_form);

	sqlite3_bind_int64(dict->get_form_pro_form, 1, form->person);
	sqlite3_bind_int64(dict->get_form_pro_form, 2, (uint8) form->case_);
	sqlite3_bind_int64(dict->get_form_pro_form, 3, (uint8) form->number);
	sqlite3_bind_int64(dict->get_form_pro_form, 4, (uint8) form->gender);
	sqlite3_bind_int64(dict->get_form_pro_form, 5, (uint8) form->suffix);
	sqlite3_bind_int64(dict->get_form_pro_form, 6, word->id);

	int out = sqlite3_step(dict->get_form_pro_form);
	if(out != SQLITE_ROW) {
		addProForm(dict, word, form);
	}
	sqlite3_reset(dict->get_form_pro_form);
}

void addPossesiveProForm(Dictionary *dict, Word *word, PossesiveProForm *form) {
	PREPARE_STMT(dict, insert_form);
	PREPARE_STMT(dict, insert_pos_pro_form);

	sqlite3_bind_int64(dict->insert_form, 1, word->id);
	sqlite3_bind_text(dict->insert_form, 2, form->form.str, -1, SQLITE_TRANSIENT);
	sqlite3_step(dict->insert_form);

	sqlite3_int64 rowid = sqlite3_last_insert_rowid(dict->db);
	form->form.id = rowid;
	sqlite3_reset(dict->insert_form);

	sqlite3_bind_int64(dict->insert_pos_pro_form, 1, rowid);
	sqlite3_bind_int64(dict->insert_pos_pro_form, 2, form->person_possesor);
	sqlite3_bind_int64(dict->insert_pos_pro_form, 3, (uint8) form->number_possesor);
	sqlite3_bind_int64(dict->insert_pos_pro_form, 4, (uint8) form->case_possesed);
	sqlite3_bind_int64(dict->insert_pos_pro_form, 5, (uint8) form->number_possesed);
	sqlite3_bind_int64(dict->insert_pos_pro_form, 6, (uint8) form->gender_possesed);
	sqlite3_bind_int64(dict->insert_pos_pro_form, 7, (uint8) form->suffix);
	sqlite3_step(dict->insert_pos_pro_form);
	sqlite3_reset(dict->insert_pos_pro_form);
}

void tryAddExistingPossesiveProForm(Dictionary::Dictionary *dict, Word *word, PossesiveProForm *form) {
	PREPARE_STMT(dict, get_form_pos_pro_form);

	sqlite3_bind_int64(dict->get_form_pos_pro_form, 1, form->person_possesor);
	sqlite3_bind_int64(dict->get_form_pos_pro_form, 2, (uint8) form->number_possesor);
	sqlite3_bind_int64(dict->get_form_pos_pro_form, 3, (uint8) form->case_possesed);
	sqlite3_bind_int64(dict->get_form_pos_pro_form, 4, (uint8) form->number_possesed);
	sqlite3_bind_int64(dict->get_form_pos_pro_form, 5, (uint8) form->gender_possesed);
	sqlite3_bind_int64(dict->get_form_pos_pro_form, 6, (uint8) form->suffix);
	sqlite3_bind_int64(dict->get_form_pos_pro_form, 7, word->id);

	if(sqlite3_step(dict->get_form_pos_pro_form) != SQLITE_ROW) {
		addPossesiveProForm(dict, word, form);
	}
	sqlite3_reset(dict->get_form_pos_pro_form);
}

void addCNGForm(Dictionary *dict, Word *word, CNGForm *form) {
	PREPARE_STMT(dict, insert_form);
	PREPARE_STMT(dict, insert_cng_form);

	sqlite3_bind_int64(dict->insert_form, 1, word->id);
	sqlite3_bind_text(dict->insert_form, 2, form->form.str, -1, SQLITE_TRANSIENT);
	sqlite3_step(dict->insert_form);

	sqlite3_int64 rowid = sqlite3_last_insert_rowid(dict->db);
	form->form.id = rowid;
	sqlite3_reset(dict->insert_form);

	sqlite3_bind_int64(dict->insert_cng_form, 1, rowid);
	sqlite3_bind_int64(dict->insert_cng_form, 2, (uint8) form->case_);
	sqlite3_bind_int64(dict->insert_cng_form, 3, (uint8) form->number);
	sqlite3_bind_int64(dict->insert_cng_form, 4, (uint8) form->gender);
	sqlite3_bind_int64(dict->insert_cng_form, 5, (uint8) form->suffix);
	sqlite3_step(dict->insert_cng_form);
	sqlite3_reset(dict->insert_cng_form);
}

void tryAddExistingCNGForm(Dictionary::Dictionary *dict, Word *word, CNGForm *form) {
	PREPARE_STMT(dict, get_form_cng_form);

	sqlite3_bind_int64(dict->get_form_cng_form, 1, (uint8) form->case_);
	sqlite3_bind_int64(dict->get_form_cng_form, 2, (uint8) form->number);
	sqlite3_bind_int64(dict->get_form_cng_form, 3, (uint8) form->gender);
	sqlite3_bind_int64(dict->get_form_cng_form, 4, (uint8) form->suffix);
	sqlite3_bind_int64(dict->get_form_cng_form, 5, word->id);

	if(sqlite3_step(dict->get_form_cng_form) != SQLITE_ROW) {
		addCNGForm(dict, word, form);
	}
	sqlite3_reset(dict->get_form_cng_form);
}

void addVerbForm(Dictionary *dict, Word *word, VerbForm *form) {
	PREPARE_STMT(dict, insert_form);
	PREPARE_STMT(dict, insert_verb_form);

	sqlite3_bind_int64(dict->insert_form, 1, word->id);
	sqlite3_bind_text(dict->insert_form, 2, form->form.str, -1, SQLITE_TRANSIENT);
	sqlite3_step(dict->insert_form);

	sqlite3_int64 rowid = sqlite3_last_insert_rowid(dict->db);
	form->form.id = rowid;
	sqlite3_reset(dict->insert_form);

	sqlite3_bind_int64(dict->insert_verb_form, 1, rowid);
	sqlite3_bind_int64(dict->insert_verb_form, 2, (uint8) form->tense);
	sqlite3_bind_int64(dict->insert_verb_form, 3, (uint8) form->voice);
	sqlite3_bind_int64(dict->insert_verb_form, 4, (uint8) form->mood);
	sqlite3_bind_int64(dict->insert_verb_form, 5, form->person);
	sqlite3_bind_int64(dict->insert_verb_form, 6, (uint8) form->case_);
	sqlite3_bind_int64(dict->insert_verb_form, 7, (uint8) form->number);
	sqlite3_bind_int64(dict->insert_verb_form, 8, (uint8) form->gender);
	sqlite3_bind_int64(dict->insert_verb_form, 9, (uint8) form->verb_extra);
	sqlite3_step(dict->insert_verb_form);
	sqlite3_reset(dict->insert_verb_form);
}

void tryAddExistingVerbForm(Dictionary::Dictionary *dict, Word *word, VerbForm *form) {
	PREPARE_STMT(dict, get_form_verb_form);

	sqlite3_bind_int64(dict->get_form_verb_form, 1, (uint8) form->tense);
	sqlite3_bind_int64(dict->get_form_verb_form, 2, (uint8) form->voice);
	sqlite3_bind_int64(dict->get_form_verb_form, 3, (uint8) form->mood);
	sqlite3_bind_int64(dict->get_form_verb_form, 4, form->person);
	sqlite3_bind_int64(dict->get_form_verb_form, 5, (uint8) form->case_);
	sqlite3_bind_int64(dict->get_form_verb_form, 6, (uint8) form->number);
	sqlite3_bind_int64(dict->get_form_verb_form, 7, (uint8) form->gender);
	sqlite3_bind_int64(dict->get_form_verb_form, 8, (uint8) form->verb_extra);
	sqlite3_bind_int64(dict->get_form_verb_form, 9, word->id);

	if(sqlite3_step(dict->get_form_verb_form) != SQLITE_ROW) {
		addVerbForm(dict, word, form);
	}
	sqlite3_reset(dict->get_form_verb_form);
}

void addOtherForm(Dictionary *dict, Word *word, OtherForm *form) {
	PREPARE_STMT(dict, insert_form);
	PREPARE_STMT(dict, insert_other_form);

	sqlite3_bind_int64(dict->insert_form, 1, word->id);
	sqlite3_bind_text(dict->insert_form, 2, form->form.str, -1, SQLITE_TRANSIENT);
	sqlite3_step(dict->insert_form);

	sqlite3_int64 rowid = sqlite3_last_insert_rowid(dict->db);
	form->form.id = rowid;
	sqlite3_reset(dict->insert_form);

	sqlite3_bind_int64(dict->insert_other_form, 1, rowid);
	sqlite3_bind_int64(dict->insert_other_form, 2, (uint8) form->suffix);
	sqlite3_step(dict->insert_other_form);
	sqlite3_reset(dict->insert_other_form);
}

void tryAddExistingOtherForm(Dictionary::Dictionary *dict, Word *word, OtherForm *form) {
	PREPARE_STMT(dict, get_form_other_form);

	sqlite3_bind_int64(dict->get_form_other_form, 1, (uint8) form->suffix);
	sqlite3_bind_int64(dict->get_form_other_form, 2, word->id);

	if(sqlite3_step(dict->get_form_other_form) != SQLITE_ROW) {
		addOtherForm(dict, word, form);
	}
	sqlite3_reset(dict->get_form_other_form);
}

Word * getWordFromResult(sqlite3_stmt *stmt, Word *fill, bool load_search_string) {
	Word *word = fill;
	if(!word) {
		word = (Word *) calloc(sizeof(Word), 1);
	}

	word->id = sqlite3_column_int64(stmt, 0);
	word->part = (Part) sqlite3_column_int64(stmt, 1);
	word->count = sqlite3_column_int64(stmt, 2);
	word->declconj = (DeclConj) sqlite3_column_int64(stmt, 3);
	word->strongs = sqlite3_column_int64(stmt, 4);
	word->lemma = allocAndCopyString(sqlite3_column_text(stmt, 5));
	word->definition = allocAndCopyString(sqlite3_column_text(stmt, 6));
	word->gloss = allocAndCopyString(sqlite3_column_text(stmt, 7));
	word->root = allocAndCopyString(sqlite3_column_text(stmt, 8));
	if(load_search_string) {
		word->search_string = allocAndCopyString(sqlite3_column_text(stmt, 9));
	}
	word->handle_memory = true;

	return word;
}

Word * getAllWordsByStrongs(Dictionary *dict) {
	PREPARE_STMT(dict, get_all_words_strongs);

	Word *words = 0;

	while(sqlite3_step(dict->get_all_words_strongs) == SQLITE_ROW) {
		if(!words) {
			words = NARRAY_NEW(Word, dict->word_count);
		}

		Word word = {};
		getWordFromResult(dict->get_all_words_strongs, &word);

		NARRAY_PUSH(words, word);
	}

	sqlite3_reset(dict->get_all_words_strongs);
	return words;
}

Word * getAllWordsByCount(Dictionary *dict) {
	PREPARE_STMT(dict, get_all_words_count);

	Word *words = 0;

	while(sqlite3_step(dict->get_all_words_count) == SQLITE_ROW) {
		if(!words) {
			words = NARRAY_NEW(Word, dict->word_count);
		}

		Word word = {};
		getWordFromResult(dict->get_all_words_count, &word);

		NARRAY_PUSH(words, word);
	}

	sqlite3_reset(dict->get_all_words_count);
	return words;
}

Word * getWordSearch(Dictionary *dict, const char *search) {
	PREPARE_STMT(dict, search_words);

	sqlite3_bind_text(dict->search_words, 1, search, -1, SQLITE_TRANSIENT);

	Word *words = 0;

	while(sqlite3_step(dict->search_words) == SQLITE_ROW) {
		if(!words) {
			words = NARRAY_NEW(Word);
		}

		Word word = {};
		getWordFromResult(dict->search_words, &word);

		NARRAY_PUSH(words, word);
	}

	sqlite3_reset(dict->search_words);
	return words;
}

Word * getWordIndex(Dictionary *dict, int index, Word *fill, bool load_search_string) {
	PREPARE_STMT(dict, get_word_index);

	sqlite3_bind_int64(dict->get_word_index, 1, index);
	Word *word = 0;
	if(sqlite3_step(dict->get_word_index) == SQLITE_ROW) {
		word = getWordFromResult(dict->get_word_index, fill, load_search_string);
	}
	sqlite3_reset(dict->get_word_index);

	return word;
}

Word * getWordID(Dictionary *dict, int id, Word *fill, bool load_search_string) {
	PREPARE_STMT(dict, get_word_id);

	sqlite3_bind_int64(dict->get_word_id, 1, id);
	Word *word = 0;
	if(sqlite3_step(dict->get_word_id) == SQLITE_ROW) {
		word = getWordFromResult(dict->get_word_id, fill, load_search_string);
	}
	sqlite3_reset(dict->get_word_id);

	return word;
}

Word * getWordStrongs(Dictionary *dict, int strongs, Word *fill, bool load_search_string) {
	PREPARE_STMT(dict, get_word_strongs);

	sqlite3_bind_int64(dict->get_word_strongs, 1, strongs);
	Word *word = 0;
	if(sqlite3_step(dict->get_word_strongs) == SQLITE_ROW) {
		word = getWordFromResult(dict->get_word_strongs, fill, load_search_string);
	}
	sqlite3_reset(dict->get_word_strongs);
	return word;
}

void getWordSearchString(Dictionary *dict, Word *word) {
	PREPARE_STMT(dict, get_word_search_string);

	sqlite3_bind_int64(dict->get_word_search_string, 1, word->id);
	sqlite3_step(dict->get_word_search_string);
	word->search_string = allocAndCopyString(sqlite3_column_text(dict->get_word_search_string, 0));
	sqlite3_reset(dict->get_word_search_string);
}

void deleteForm(Dictionary *dict, Word *word, uint64 i) {
	PREPARE_STMT(dict, delete_form);

	Form *form = 0;
	if(word->part == Part::N || word->part == Part::A || word->part == Part::T) {
		PREPARE_STMT(dict, delete_form_cng_form);
		form = &(&NARRAYITEM(word->cng_forms, i))->form;

		sqlite3_bind_int64(dict->delete_form_cng_form, 1, form->id);
		sqlite3_step(dict->delete_form_cng_form);
		sqlite3_reset(dict->delete_form_cng_form);
	}
	else if(word->part == Part::V) {
		PREPARE_STMT(dict, delete_form_verb_form);
		form = &(&NARRAYITEM(word->verb_forms, i))->form;

		sqlite3_bind_int64(dict->delete_form_verb_form, 1, form->id);
		sqlite3_step(dict->delete_form_verb_form);
		sqlite3_reset(dict->delete_form_verb_form);
	}
	else if(word->part == Part::P || word->part == Part::R || word->part == Part::C || word->part == Part::D || word->part == Part::K || word->part == Part::I || word->part == Part::X || word->part == Part::Q || word->part == Part::F) {
		PREPARE_STMT(dict, delete_form_pro_form);
		form = &(&NARRAYITEM(word->pro_forms, i))->form;

		sqlite3_bind_int64(dict->delete_form_pro_form, 1, form->id);
		sqlite3_step(dict->delete_form_pro_form);
		sqlite3_reset(dict->delete_form_pro_form);
	}
	else if(word->part == Part::S) {
		PREPARE_STMT(dict, delete_form_pos_pro_form);
		form = &(&NARRAYITEM(word->pos_pro_forms, i))->form;

		sqlite3_bind_int64(dict->delete_form_pos_pro_form, 1, form->id);
		sqlite3_step(dict->delete_form_pos_pro_form);
		sqlite3_reset(dict->delete_form_pos_pro_form);
	}
	else {
		PREPARE_STMT(dict, delete_form_other_form);
		form = &(&NARRAYITEM(word->other_forms, i))->form;

		sqlite3_bind_int64(dict->delete_form_other_form, 1, form->id);
		sqlite3_step(dict->delete_form_other_form);
		sqlite3_reset(dict->delete_form_other_form);
	}

	sqlite3_bind_int64(dict->delete_form, 1, form->id);
	sqlite3_step(dict->delete_form);
	sqlite3_reset(dict->delete_form);

	free(form->str);
}

void loadAllForms(Dictionary *dict, Word *word) {
	if(word->forms_pointer) {
		return;
	}

	PREPARE_STMT(dict, load_all_forms);

	sqlite3_bind_int64(dict->load_all_forms, 1, word->id);

	if(word->part == Part::N || word->part == Part::A || word->part == Part::T) {
		word->cng_forms = NARRAY_NEW(CNGForm);
	}
	else if(word->part == Part::V) {
		word->verb_forms = NARRAY_NEW(VerbForm);
	}
	else if(word->part == Part::P || word->part == Part::R || word->part == Part::C || word->part == Part::D || word->part == Part::K || word->part == Part::I || word->part == Part::X || word->part == Part::Q || word->part == Part::F) {
		word->pro_forms = NARRAY_NEW(ProForm);
	}
	else if(word->part == Part::S) {
		word->pos_pro_forms = NARRAY_NEW(PossesiveProForm);
	}
	else {
		word->other_forms = NARRAY_NEW(OtherForm);
	}

	while(sqlite3_step(dict->load_all_forms) == SQLITE_ROW) {
		Form form = {
			sqlite3_column_int64(dict->load_all_forms, 0),
			allocAndCopyString(sqlite3_column_text(dict->load_all_forms, 2))
		};

		if(word->part == Part::N || word->part == Part::A || word->part == Part::T) {
			PREPARE_STMT(dict, load_form_cng_form);
			sqlite3_bind_int64(dict->load_form_cng_form, 1, form.id);
			sqlite3_step(dict->load_form_cng_form);
			CNGForm cng_form = {
				form,
				(Case) sqlite3_column_int64(dict->load_form_cng_form, 1),
				(Number) sqlite3_column_int64(dict->load_form_cng_form, 2),
				(Gender) sqlite3_column_int64(dict->load_form_cng_form, 3),
				(Suffix) sqlite3_column_int64(dict->load_form_cng_form, 4),
			};
			NARRAY_PUSH(word->cng_forms, cng_form);
			sqlite3_reset(dict->load_form_cng_form);
		}
		else if(word->part == Part::V) {
			PREPARE_STMT(dict, load_form_verb_form);
			sqlite3_bind_int64(dict->load_form_verb_form, 1, form.id);
			sqlite3_step(dict->load_form_verb_form);
			VerbForm verb_form = {
				form,
				(Tense) sqlite3_column_int64(dict->load_form_verb_form, 1),
				(Voice) sqlite3_column_int64(dict->load_form_verb_form, 2),
				(Mood) sqlite3_column_int64(dict->load_form_verb_form, 3),
				(uint8) sqlite3_column_int64(dict->load_form_verb_form, 4),
				(Case) sqlite3_column_int64(dict->load_form_verb_form, 5),
				(Number) sqlite3_column_int64(dict->load_form_verb_form, 6),
				(Gender) sqlite3_column_int64(dict->load_form_verb_form, 7),
				(VerbExtra) sqlite3_column_int64(dict->load_form_verb_form, 8),
			};
			NARRAY_PUSH(word->verb_forms, verb_form);
			sqlite3_reset(dict->load_form_verb_form);
		}
		else if(word->part == Part::P || word->part == Part::R || word->part == Part::C || word->part == Part::D || word->part == Part::K || word->part == Part::I || word->part == Part::X || word->part == Part::Q || word->part == Part::F) {
			PREPARE_STMT(dict, load_form_pro_form);
			sqlite3_bind_int64(dict->load_form_pro_form, 1, form.id);
			sqlite3_step(dict->load_form_pro_form);
			ProForm pro_form = {
				form,
				(uint8) sqlite3_column_int64(dict->load_form_pro_form, 1),
				(Case) sqlite3_column_int64(dict->load_form_pro_form, 2),
				(Number) sqlite3_column_int64(dict->load_form_pro_form, 3),
				(Gender) sqlite3_column_int64(dict->load_form_pro_form, 4),
				(Suffix) sqlite3_column_int64(dict->load_form_pro_form, 5),
			};
			NARRAY_PUSH(word->pro_forms, pro_form);
			sqlite3_reset(dict->load_form_pro_form);
		}
		else if(word->part == Part::S) {
			PREPARE_STMT(dict, load_form_pos_pro_form);
			sqlite3_bind_int64(dict->load_form_pos_pro_form, 1, form.id);
			sqlite3_step(dict->load_form_pos_pro_form);
			PossesiveProForm pos_pro_form = {
				form,
				(uint8) sqlite3_column_int64(dict->load_form_pos_pro_form, 1),
				(Number) sqlite3_column_int64(dict->load_form_pos_pro_form, 2),
				(Case) sqlite3_column_int64(dict->load_form_pos_pro_form, 3),
				(Number) sqlite3_column_int64(dict->load_form_pos_pro_form, 4),
				(Gender) sqlite3_column_int64(dict->load_form_pos_pro_form, 5),
				(Suffix) sqlite3_column_int64(dict->load_form_pos_pro_form, 6),
			};
			NARRAY_PUSH(word->pos_pro_forms, pos_pro_form);
			sqlite3_reset(dict->load_form_pos_pro_form);
		}
		else {
			PREPARE_STMT(dict, load_form_other_form);
			sqlite3_bind_int64(dict->load_form_other_form, 1, form.id);
			sqlite3_step(dict->load_form_other_form);
			OtherForm other_form = {
				form,
				(Suffix) sqlite3_column_int64(dict->load_form_other_form, 1),
			};
			NARRAY_PUSH(word->other_forms, other_form);
			sqlite3_reset(dict->load_form_other_form);
		}
	}

	sqlite3_reset(dict->load_all_forms);
}

void updateWord(Dictionary *dict, Word *word) {
	PREPARE_STMT(dict, update_word);

	sqlite3_bind_int64(dict->update_word, 1, (uint8) word->part);
	sqlite3_bind_int64(dict->update_word, 2, word->count);
	sqlite3_bind_int64(dict->update_word, 3, (uint8) word->declconj);
	sqlite3_bind_int64(dict->update_word, 4, word->strongs);
	sqlite3_bind_text(dict->update_word, 5, word->lemma, -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(dict->update_word, 6, word->definition, -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(dict->update_word, 7, word->root, -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(dict->update_word, 8, word->gloss, -1, SQLITE_TRANSIENT);
	sqlite3_bind_int64(dict->update_word, 9, word->id);
	sqlite3_step(dict->update_word);
	sqlite3_reset(dict->update_word);
}

void updateForm(Dictionary *dict, Form *form) {
	PREPARE_STMT(dict, update_form);

	sqlite3_bind_text(dict->update_form, 1, form->str, -1, SQLITE_TRANSIENT);
	sqlite3_bind_int64(dict->update_form, 2, form->id);
	sqlite3_step(dict->update_form);
	sqlite3_reset(dict->update_form);
}

void updateProForm(Dictionary *dict, ProForm *form) {
	PREPARE_STMT(dict, update_pro_form);

	sqlite3_bind_int64(dict->update_pro_form, 1, form->person);
	sqlite3_bind_int64(dict->update_pro_form, 2, (uint8) form->case_);
	sqlite3_bind_int64(dict->update_pro_form, 3, (uint8) form->number);
	sqlite3_bind_int64(dict->update_pro_form, 4, (uint8) form->gender);
	sqlite3_bind_int64(dict->update_pro_form, 5, (uint8) form->suffix);
	sqlite3_bind_int64(dict->update_pro_form, 6, form->form.id);
	sqlite3_step(dict->update_pro_form);
	sqlite3_reset(dict->update_pro_form);
}

void updatePossesiveProForm(Dictionary *dict, PossesiveProForm *form) {
	PREPARE_STMT(dict, update_pos_pro_form);

	sqlite3_bind_int64(dict->update_pos_pro_form, 1, form->person_possesor);
	sqlite3_bind_int64(dict->update_pos_pro_form, 2, (uint8) form->number_possesor);
	sqlite3_bind_int64(dict->update_pos_pro_form, 3, (uint8) form->case_possesed);
	sqlite3_bind_int64(dict->update_pos_pro_form, 4, (uint8) form->number_possesed);
	sqlite3_bind_int64(dict->update_pos_pro_form, 5, (uint8) form->gender_possesed);
	sqlite3_bind_int64(dict->update_pos_pro_form, 6, (uint8) form->suffix);
	sqlite3_bind_int64(dict->update_pos_pro_form, 7, form->form.id);
	sqlite3_step(dict->update_pos_pro_form);
	sqlite3_reset(dict->update_pos_pro_form);
}

void updateCNGForm(Dictionary *dict, CNGForm *form) {
	PREPARE_STMT(dict, update_cng_form);

	sqlite3_bind_int64(dict->update_cng_form, 1, (uint8) form->case_);
	sqlite3_bind_int64(dict->update_cng_form, 2, (uint8) form->number);
	sqlite3_bind_int64(dict->update_cng_form, 3, (uint8) form->gender);
	sqlite3_bind_int64(dict->update_cng_form, 4, (uint8) form->suffix);
	sqlite3_bind_int64(dict->update_cng_form, 5, form->form.id);
	sqlite3_step(dict->update_cng_form);
	sqlite3_reset(dict->update_cng_form);
}

void updateVerbForm(Dictionary *dict, VerbForm *form) {
	PREPARE_STMT(dict, update_verb_form);

	sqlite3_bind_int64(dict->update_verb_form, 1, (uint8) form->tense);
	sqlite3_bind_int64(dict->update_verb_form, 2, (uint8) form->voice);
	sqlite3_bind_int64(dict->update_verb_form, 3, (uint8) form->mood);
	sqlite3_bind_int64(dict->update_verb_form, 4, form->person);
	sqlite3_bind_int64(dict->update_verb_form, 5, (uint8) form->case_);
	sqlite3_bind_int64(dict->update_verb_form, 6, (uint8) form->number);
	sqlite3_bind_int64(dict->update_verb_form, 7, (uint8) form->gender);
	sqlite3_bind_int64(dict->update_verb_form, 8, (uint8) form->verb_extra);
	sqlite3_bind_int64(dict->update_verb_form, 9, form->form.id);
	sqlite3_step(dict->update_verb_form);
	sqlite3_reset(dict->update_verb_form);
}

void updateOtherForm(Dictionary *dict, OtherForm *form) {
	PREPARE_STMT(dict, update_other_form);

	sqlite3_bind_int64(dict->update_other_form, 1, (uint8) form->suffix);
	sqlite3_bind_int64(dict->update_other_form, 2, form->form.id);
	sqlite3_step(dict->update_other_form);
	sqlite3_reset(dict->update_other_form);
}

void clearWordMemory(Word *word) {
	if(!word->handle_memory) {
		return;
	}

	free(word->lemma);
	free(word->definition);
	free(word->root);
	free(word->gloss);

	clearWordFormListMemory(word);
}

void clearWordFormListMemory(Word *word) {
	if(word->forms_pointer) {
		if(word->part == Part::N || word->part == Part::A || word->part == Part::T) {
			FOR(i, form, word->cng_forms) {
				free(form->form.str);
			}
		}
		else if(word->part == Part::V) {
			FOR(i, form, word->verb_forms) {
				free(form->form.str);
			}
		}
		else if(word->part == Part::P || word->part == Part::R || word->part == Part::C || word->part == Part::D || word->part == Part::K || word->part == Part::I || word->part == Part::X || word->part == Part::Q || word->part == Part::F) {
			FOR(i, form, word->pro_forms) {
				free(form->form.str);
			}
		}
		else if(word->part == Part::S) {
			FOR(i, form, word->pos_pro_forms) {
				free(form->form.str);
			}
		}
		else {
			FOR(i, form, word->other_forms) {
				free(form->form.str);
			}
		}

		NARRAY_FREE(word->forms_pointer);
	}
}

Form * getFormFromForms(Word *word, uint64 i) {
	if(word->part == Part::N || word->part == Part::A || word->part == Part::T) {
		return &(&NARRAYITEM(word->cng_forms, i))->form;
	}
	else if(word->part == Part::V) {
		return &(&NARRAYITEM(word->verb_forms, i))->form;
	}
	else if(word->part == Part::P || word->part == Part::R || word->part == Part::C || word->part == Part::D || word->part == Part::K || word->part == Part::I || word->part == Part::X || word->part == Part::Q || word->part == Part::F) {
		return &(&NARRAYITEM(word->pro_forms, i))->form;
	}
	else if(word->part == Part::S) {
		return &(&NARRAYITEM(word->pos_pro_forms, i))->form;
	}
	else {
		return &(&NARRAYITEM(word->other_forms, i))->form;
	}
}

#endif

}