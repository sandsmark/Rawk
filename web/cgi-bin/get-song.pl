#!/usr/bin/perl -w
use strict;
use warnings;

use lib '/srv/http/music/include';

use Rawk;
use CGI;
use JSON;
use Audio::Scrobbler;

my $song_id = CGI::param('id');

my $query;
$query = Rawk::db->prepare(q{
    SELECT path, title, artist.name as artist, length FROM song, artist WHERE artist.id = song.artist AND song.id = ?
    });
$query->execute($song_id) or die("invalid song id");
my $row = $query->fetchrow_hashref();
my $song_path = $row->{'path'};

my $artist = $row->{'artist'};
my $track = $row->{'title'};
my $length = $row->{'length'};

my $relative_path = $song_path;
my $collection_path = Rawk::config('MUSIC_PATH');
$relative_path =~ s/$collection_path/music\//;
print CGI::redirect("/$relative_path");



# Scrobble the song
#if (defined(Rawk::config('AS_USER')) and defined(Rawk::config('AS_PASS')) {
    my $scrobbler = new Audio::Scrobbler(cfg => {
            progname => 'Rawk',
            progver => '0.1',
            username => Rawk::config('AS_USER'),
            password => Rawk::config('AS_PASS')
        });
    $scrobbler->handshake();
    $scrobbler->submit(
        artist => $artist,
        track => $track,
        length => $length
    );
#}

1;

