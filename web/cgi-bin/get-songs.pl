#!/usr/bin/perl -w
use strict;
use warnings;

use lib '/srv/http/music/include';

use Rawk;
use CGI;
use JSON;

my $album = CGI::param('album');
my $playlist = CGI::param('playlist');

my $query;
if (defined($album)) {
    $query = Rawk::db->prepare(q{
        SELECT DISTINCT
            song.title, artist.name, album.name, song.tracknumber, song.length
        FROM song, artist, album
        WHERE
            album = ?
            AND song.album = album.id
            AND song.artist = artist.id
        ORDER BY song.tracknumber
        });
    $query->execute($album);
} elsif (defined($playlist)) {
    # TODO
}



print "Content-type: application/json\n\n";
print encode_json $query->fetchall_arrayref();

1;
