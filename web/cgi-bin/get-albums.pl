#!/usr/bin/perl -w
use strict;
use warnings;

use lib '/srv/http/music/include';

use Rawk;
use CGI;
use JSON;

my $artist = CGI::param('artist');

if (!defined($artist)) {
    print CGI::header('text/html','400 Bad Request');
    print "Illegal request, please supply an artist id.";
    exit;
}


my $query = Rawk::db->prepare(q{
    SELECT DISTINCT album.id, album.name FROM album LEFT JOIN song ON song.album = album.id WHERE song.artist = ?
});
$query->execute($artist);

print "Content-type: application/json\n\n";
print encode_json $query->fetchall_arrayref();

1;
