#!/usr/bin/perl -w
use strict;
use warnings;

use lib '/srv/http/music/include';

use Rawk;
use CGI;


my $playlistname = CGI::param('name');

if (!defined($playlistname) || $playlistname eq '') {
    print CGI::header('text/html','400 Bad Request');
    print "Illegal request, please supply a playlist name.";
    exit;
}


my $query = Rawk::db->do(q{
    INSERT INTO playlist(name) VALUES(?)
}, {}, $playlistname);

print "Content-type: text/html\n\n";
print "done";
1;
