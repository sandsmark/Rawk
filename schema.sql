CREATE TABLE artist (
    id SERIAL PRIMARY KEY,
    name VARCHAR
);

CREATE TABLE album (
    id SERIAL PRIMARY KEY,
    name VARCHAR
);

CREATE TABLE song (
    id SERIAL PRIMARY KEY,
    title VARCHAR,
    artist INTEGER NOT NULL REFERENCES artist,
    album INTEGER NOT NULL REFERENCES album,
    tracknumber INTEGER,
    length INTEGER,
    path VARCHAR NOT NULL,
    last_modified INTEGER NOT NULL
);

