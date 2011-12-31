#!/usr/bin/perl -w
use strict;
use warnings;

use lib '/srv/http/music/include';

use Rawk;
use CGI;


my $star = CGI::param('star');
my $unstar = CGI::param('unstar');

if (!defined($star) && !defined($unstar)) {
    print CGI::header('text/html','400 Bad Request');
    print "Illegal request, please supply a playlist and a song.";
    exit;
}


if (defined($star)) {
    Rawk::db->do(q{
        INSERT INTO starred(song) VALUES(?)
        }, {}, $star);
} elsif (defined($unstar)) {
    Rawk::db->do(q{
        DELETE FROM starred WHERE song = ?
        }, {}, $unstar);
}

print "Content-type: text/html\n\n";
print "done";
1;
