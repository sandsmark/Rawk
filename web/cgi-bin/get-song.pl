#!/usr/bin/perl -w
use strict;
use warnings;

use lib '/srv/http/music/include';

use Rawk;
use CGI;
use JSON;

my $song_id = CGI::param('id');

my $query;
$query = Rawk::db->prepare(q{
    SELECT path, title FROM song WHERE id = ?
    });
$query->execute($song_id) or die("invalid song id");
my $row = $query->fetchrow_hashref();
my $song_path = $row->{'path'};

my $relative_path = $song_path;
my $collection_path = Rawk::config('MUSIC_PATH');
$relative_path =~ s/$collection_path/music\//;
print CGI::redirect("/$relative_path");
#my $song_title = $row->{'title'};
#
#my @buffer;
#open(FILE, $song_path) or die("unable to open file");
#@buffer = <FILE>;
#close(FILE);
#
#print "Content-type: audio/mpeg3\n\n";
#print "Content-Disposition:attachment;filename=$song_title.mp3\n\n";
#print @buffer;

1;

