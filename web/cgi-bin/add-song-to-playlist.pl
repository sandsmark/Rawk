#!/usr/bin/perl -w
use strict;
use warnings;

use lib '/srv/http/music/include';

use Rawk;
use CGI;


my $playlist = CGI::param('playlist');
my $song = CGI::param('song');

if (!defined($playlist) || !defined($song)) {
    print CGI::header('text/html','400 Bad Request');
    print "Illegal request, please supply a playlist and a song.";
    exit;
}


my $query = Rawk::db->do(q{
    INSERT INTO playlistitem(song, playlist) VALUES(?, ?)
}, {}, $song, $playlist);

print "Content-type: text/html\n\n";
print "done";
1;
