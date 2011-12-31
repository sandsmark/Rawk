#!/usr/bin/perl -w
use strict;
use warnings;

use lib '/srv/http/music/include';

use Rawk;
use CGI;
use JSON;

my $album = CGI::param('album');
my $artist = CGI::param('artist');
my $search_query = CGI::param('search');
my $playlist = CGI::param('playlist');

my $query;
#song.id, artist.name || ' - ' ||  song.title || ' (' || song.length || ')', song.tracknumber
if (defined($album)) {
    $query = Rawk::db->prepare(q{
        SELECT DISTINCT
            EXISTS (SELECT * FROM starred WHERE song = song.id) AS starred,
            song.id,
            song.title as title,
            artist.name as artist,
            artist.id as artistid,
            album.name as album,
            album.id as albumid,
            song.tracknumber
        FROM song, artist, album
        WHERE
            album = ?
            AND song.album = album.id
            AND song.artist = artist.id
        ORDER BY album.name, artist.name, song.tracknumber
        });
    $query->execute($album);
} elsif (defined($artist)) {
    $query = Rawk::db->prepare(q{
        SELECT DISTINCT
            EXISTS (SELECT * FROM starred WHERE song = song.id) AS starred,
            song.id,
            song.title as title,
            artist.name as artist,
            artist.id as artistid,
            album.name as album,
            album.id as albumid,
            song.tracknumber
        FROM song, artist, album
        WHERE
            artist = ?
            AND song.album = album.id
            AND song.artist = artist.id
        ORDER BY album.name, artist.name, song.tracknumber
        });
    $query->execute($artist);
} elsif (defined($playlist)) {
    $query = Rawk::db->prepare(q{
        SELECT DISTINCT
            song.id,
            song.title as title,
            artist.name as artist,
            artist.id as artistid,
            album.name as album,
            album.id as albumid,
            song.tracknumber
        FROM song, artist, album, playlistitem
        WHERE
            playlistitem.playlist = ?
            AND playlistitem.song = song.id
            AND song.album = album.id
            AND song.artist = artist.id
        ORDER BY album.name, artist.name, song.tracknumber
        });
    $query->execute($playlist);
} elsif (defined($search_query)) {
    $query = Rawk::db->prepare(q{
        SELECT DISTINCT
            song.id,
            song.title as title,
            artist.name as artist,
            artist.id as artistid,
            album.name as album,
            album.id as albumid,
            song.tracknumber
        FROM song, artist, album
        WHERE
            (album.name ILIKE ?
             OR song.title ILIKE ?
             OR artist.name ILIKE ?)
            AND song.album = album.id
            AND song.artist = artist.id
        ORDER BY song.tracknumber
        LIMIT 25
        });
    $query->execute("%$search_query%", "%$search_query%", "%$search_query%");
} else {
    $query = Rawk::db->prepare(q{
        SELECT DISTINCT
            True AS starred,
            song.id,
            song.title as title,
            artist.name as artist,
            artist.id as artistid,
            album.name as album,
            album.id as albumid,
            song.tracknumber
        FROM song, artist, album, starred
        WHERE
            starred.song = song.id
            AND song.album = album.id
            AND song.artist = artist.id
        ORDER BY album.name, artist.name, song.tracknumber
        });
    $query->execute();
}


my @results;
while (my $row = $query->fetchrow_hashref()) {
    push @results, $row;
}

print "Content-type: application/json\n\n";
print encode_json \@results;

1;
