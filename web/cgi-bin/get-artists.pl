#!/usr/bin/perl -w
use strict;
use warnings;

use lib '/srv/http/music/include';

use Rawk;
use CGI;
use JSON;

my $artist = CGI::param('artist');

my $query;
if (defined($artist)) {
    $query = Rawk::db->prepare(q{
        SELECT DISTINCT id, name FROM artist WHERE name ILIKE ? ORDER BY name LIMIT 10
        });
    $query->execute("%$artist%");
} else {
    $query = Rawk::db->prepare(q{
        SELECT DISTINCT artist.id, artist.name, random()
            FROM artist
            JOIN song ON song.artist = artist.id 
            WHERE song.album IS NOT NULL
            ORDER BY random() LIMIT 10
        });
    $query->execute();
}



print "Content-type: application/json\n\n";
print encode_json $query->fetchall_arrayref();

1;
