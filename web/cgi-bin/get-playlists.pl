#!/usr/bin/perl -w
use strict;
use warnings;

use lib '/srv/http/music/include';

use Rawk;
use CGI;
use JSON;

my $query = Rawk::db->prepare(q{
    SELECT id, name FROM playlist
});
$query->execute();

print "Content-type: application/json\n\n";
print encode_json $query->fetchall_arrayref();

1;
