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
        SELECT id, name FROM artist WHERE name LIKE ?
        });
    $query->execute("%$artist%");
} else {
    $query = Rawk::db->prepare(q{
        SELECT id, name FROM artist
        });
    $query->execute();
}



print "Content-type: application/json\n\n";
print encode_json $query->fetchall_arrayref();

1;
