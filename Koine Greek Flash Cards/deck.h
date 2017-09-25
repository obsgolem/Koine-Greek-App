#pragma once

#include "dictionary/dictionary.h"

struct WordData {
    int id;
    int deck_id;
    int word_id;
    int *form_ids;
};

struct Deck {
    int id;
    int sort_index;
    char *name;
    WordData *word_data;
    Dictionary::Word **words;

    bool handle_memory;
};

Deck * loadAllDecks(Dictionary::Dictionary *dict);
void removeDeck(Dictionary::Dictionary *dict, Deck *deck);
Deck createDeck(Dictionary::Dictionary *dict, NSString *name, int last_sort_index);
void updateDeck(Dictionary::Dictionary *dict, Deck *deck);
void clearDeckMemory(Deck *deck);
void loadAllWordData(Dictionary::Dictionary *dict, Deck *deck);
void updateWordForms(Dictionary::Dictionary *dict, WordData *word);
void getDictWordsForDeck(Dictionary::Dictionary *dict, Deck *deck, Dictionary::Word *words);
// void reloadDeckWords(Dictionary::Dictionary *dict, Deck *deck);

#if defined(DECK_IMPL)

Deck * loadAllDecks(Dictionary::Dictionary *dict) {
    sqlite3_stmt *stmt = 0;
    sqlite3_prepare_v2(dict->db, "select * from Deck order by sort_index asc", -1, &stmt, 0);

    Deck *decks = NARRAY_NEW(Deck);;

    while(sqlite3_step(stmt) == SQLITE_ROW) {
        Deck deck = {};

        deck.id = sqlite3_column_int64(stmt, 0);
        deck.sort_index = sqlite3_column_int64(stmt, 1);
        deck.name = allocAndCopyString(sqlite3_column_text(stmt, 2));
        deck.handle_memory = true;

        NARRAY_PUSH(decks, deck);
    }
    sqlite3_finalize(stmt);

    return decks;
}

void removeDeck(Dictionary::Dictionary *dict, Deck *deck) {
    sqlite3_stmt *stmt = 0;
    sqlite3_prepare_v2(dict->db, "delete from Deck where rowid = ?", -1, &stmt, 0);
    sqlite3_bind_int64(stmt, 1, deck->id);
    sqlite3_step(stmt);
    sqlite3_finalize(stmt);

    sqlite3_prepare_v2(dict->db, "delete from DeckWord where deck = ?", -1, &stmt, 0);
    sqlite3_bind_int64(stmt, 1, deck->id);
    sqlite3_step(stmt);
    sqlite3_finalize(stmt);

    sqlite3_prepare_v2(dict->db, "delete from DeckForm where deck = ?", -1, &stmt, 0);
    sqlite3_bind_int64(stmt, 1, deck->id);
    sqlite3_step(stmt);
    sqlite3_finalize(stmt);

    clearDeckMemory(deck);
}

Deck createDeck(Dictionary::Dictionary *dict, NSString *name, int last_sort_index) {
    Deck deck = {};
    deck.name = allocAndCopyString(name.UTF8String);
    deck.sort_index = last_sort_index;
    deck.handle_memory = true;

    sqlite3_stmt *stmt = 0;
    sqlite3_prepare_v2(dict->db, "insert into Deck(sort_index, name) values (?, ?)", -1, &stmt, 0);
    sqlite3_bind_int64(stmt, 1, last_sort_index);
    sqlite3_bind_text(stmt, 2, deck.name, -1, SQLITE_TRANSIENT);
    sqlite3_step(stmt);

    deck.id = sqlite3_last_insert_rowid(dict->db);

    sqlite3_finalize(stmt);
    return deck;
}

void updateDeck(Dictionary::Dictionary *dict, Deck *deck) {
    sqlite3_stmt *stmt = 0;
    sqlite3_prepare_v2(dict->db, "update Deck set sort_index = ?, name = ? where rowid = ?", -1, &stmt, 0);
    sqlite3_bind_int64(stmt, 1, deck->sort_index);
    sqlite3_bind_text(stmt, 2, deck->name, -1, SQLITE_TRANSIENT);
    sqlite3_bind_int64(stmt, 3, deck->id);
    sqlite3_step(stmt);
    sqlite3_finalize(stmt);
}

// Clears the memory allocated for the deck, it is left to the user to free the actual deck
void clearDeckMemory(Deck *deck) {
    if(!deck->handle_memory) {
        return;
    }

    free(deck->name);

    if(deck->word_data) {
        FOR(i, word, deck->word_data) {
            NARRAY_FREE(word->form_ids);
        }

        NARRAY_FREE(deck->word_data);
    }
}

void loadAllWordData(Dictionary::Dictionary *dict, Deck *deck) {
    if(deck->word_data) {
        return;
    }

    sqlite3_stmt *word_stmt = 0;
    sqlite3_prepare_v2(dict->db, "select * from DeckWord where deck = ?", -1, &word_stmt, 0);
    sqlite3_bind_int64(word_stmt, 1, deck->id);

    sqlite3_stmt *form_stmt = 0;

    while(sqlite3_step(word_stmt) == SQLITE_ROW) {
        if(!deck->word_data) {
            deck->word_data = NARRAY_NEW(WordData);
            sqlite3_prepare_v2(dict->db, "select form from DeckForm where word = ?", -1, &form_stmt, 0);
        }

        WordData word = {};
        word.deck_id = deck->id;
        word.id = sqlite3_column_int64(word_stmt, 0);
        word.word_id = sqlite3_column_int64(word_stmt, 2);

        sqlite3_bind_int64(form_stmt, 1, word.id);

        while(sqlite3_step(form_stmt) == SQLITE_ROW) {
            if(!word.form_ids) {
                word.form_ids = NARRAY_NEW(int);
            }

            int form_id = sqlite3_column_int64(form_stmt, 0);
            NARRAY_PUSH(word.form_ids, form_id);
        }

        NARRAY_PUSH(deck->word_data, word);
        sqlite3_reset(form_stmt);
    }
}

void updateWordForms(Dictionary::Dictionary *dict, WordData *word) {
    sqlite3_stmt *stmt = 0;
    sqlite3_prepare_v2(dict->db, "delete from DeckForm where word = ?", -1, &stmt, 0);
    sqlite3_bind_int64(stmt, 1, word->id);
    sqlite3_step(stmt);
    sqlite3_finalize(stmt);

    sqlite3_prepare_v2(dict->db, "insert into DeckForm(word, form, deck) values (?, ?, ?)", -1, &stmt, 0);

    FOR(i, form_id, word->form_ids) {
        sqlite3_bind_int64(stmt, 1, word->id);
        sqlite3_bind_int64(stmt, 2, *form_id);
        sqlite3_bind_int64(stmt, 3, word->deck_id);
        sqlite3_step(stmt);
        sqlite3_reset(stmt);
    }

    sqlite3_finalize(stmt);
}

void getDictWordsForDeck(Dictionary::Dictionary *dict, Deck *deck, Dictionary::Word *words) {
    NARRAY_FREE(deck->words);

    FOR(i, data, deck->word_data) {
        if(!deck->words) {
            deck->words = NARRAY_NEW(Dictionary::Word *);
        }
        FOR(j, word, words) {
            if(data->word_id == word->id) {
                if(!word->search_string) {
                    getWordSearchString(dict, word);
                }

                NARRAY_PUSH(deck->words, word);
                break;
            }
        }
    }
}

#endif