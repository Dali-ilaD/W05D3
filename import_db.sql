
DROP TABLE IF EXISTS questions_follows;
DROP TABLE IF EXISTS questions_likes;
DROP TABLE IF EXISTS replys;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;
PRAGMA foreign_keys = ON;


CREATE TABLE users (
   id INTEGER PRIMARY KEY,
   fname TEXT NOT NULL,
   lname TEXT NOT NULL
);

CREATE TABLE questions(
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    author TEXT NOT NULL,
    associated_author INTEGER NOT NULL,
    FOREIGN KEY(associated_author)REFERENCES users(id)
);
CREATE TABLE questions_follows (
    id INTEGER PRIMARY KEY,
    questions_id INTEGER NOT NULL,
    users_id INTEGER NOT NULL,
    FOREIGN KEY(questions_id)REFERENCES questions(id),
    FOREIGN KEY(users_id)REFERENCES users(id)
);
CREATE TABLE replys (
    id INTEGER PRIMARY KEY,
    subject TEXT NOT NULL,
    subject_question INTEGER NOT NULL,
    parent_replys INTEGER NOT NULL,
    user_author INTEGER NOT NULL,
    body TEXT NOT NULL,
    FOREIGN KEY(parent_replys)REFERENCES replys(id),
    FOREIGN KEY(user_author)REFERENCES users(id),
    FOREIGN KEY(subject_question)REFERENCES questions(id)
);
CREATE TABLE questions_likes (
    id INTEGER PRIMARY KEY,
    questions_id INTEGER NOT NULL,
    users_id INTEGER NOT NULL,
    FOREIGN KEY(questions_id)REFERENCES questions(id),
    FOREIGN KEY(users_id)REFERENCES users(id)
);

INSERT INTO
users(id, fname,lname)
VALUES 
('NED', 'FLANDERS');

INSERT INTO
questions(title, body, associated_author)
VALUES
('Ned question', 'NEDNEDNED', (SELECT id FROM users WHERE fname = 'NED'));