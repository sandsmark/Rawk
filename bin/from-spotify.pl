#!/usr/bin/perl -w
use strict;
use warnings;

use lib '/srv/http/music/include';

use Rawk;
use Net::Spotify;
use Time::HiRes;


open IN, "spotify-urls.txt" or die $!;
open OUT, ">playlist.txt" or die $!;

my $spotify = Net::Spotify->new();


while (my $uri = <IN>) {
    $uri =~ s/\s+$//;
    my $metadata = $spotify->lookup(uri => $uri);

    $metadata =~ m/<name>([^<]+)<\/name>/g;
    my $title = $1;
    $metadata =~ m/<name>([^<]+)<\/name>/g;
    my $artist = $1;
    $metadata =~ m/<name>([^<]+)<\/name>/g;
    my $album = $1;
    print "$uri :: title: $title artist: $artist album: $album\n";
    print OUT "$title\t$artist\t$album\n";
    Time::HiRes::usleep(150);
}

close(IN);
close(OUT);
