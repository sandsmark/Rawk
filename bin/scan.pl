#!/usr/bin/perl -w
use strict;
use warnings;

use lib '/srv/http/music/include';

use Rawk;
use File::Find;
use Data::UUID;
use MP3::Tag;
use Encode;
require Encode::Detect;

my $ug = new Data::UUID;
sub getUuid {
    my $file_path = shift;
    return $ug->create_from_name('Rawk', $file_path);
}

my ($comment, $year, $genre);
sub handle_file {
    my $filename = $_;
    my $full_path = $File::Find::name;
    my $mtime = ( stat $filename )[9];
    if (!($filename =~ m/.+\.mp3/)) {
        return;
    }

    # Check if we already have it
    my $query = Rawk::db->prepare(q{
        SELECT id, last_modified FROM song WHERE path = ?
    });

    $query->execute($full_path) or die("unable to check $full_path");
    my $row = $query->fetchrow_hashref();
    if (defined($row)) {
        if ($row->{'last_modified'} != $mtime) { # it has been updated, remove it so we can re-add it
            Rawk::db->do(q{
                DELETE FROM song WHERE id = ?
                }, {}, $row->{'id'});
        } else {
#            print "skipping $full_path\n";
            return;
        }
    }

    my ($title, $tracknumber, $artist, $album, $length);
    if ($filename =~ m/.+\.mp3/) {
         my $mp3 = MP3::Tag->new($filename);
         ($title, $tracknumber, $artist, $album, $comment, $year, $genre) = $mp3->autoinfo();
         $length = $mp3->total_secs_int();
    }  elsif ($filename =~ m/.+\.ogg/) {
        #TODO
        return;
    } else {
        return;
    }
    if (!defined($title) or !defined($artist) or !defined($length)) {
        return;
    }
    print "Scanning file $full_path\n";
    
    $artist = decode("Detect", $artist);
    $album = decode("Detect", $album);
    $title = decode("Detect", $title);

    if ($tracknumber eq '') {
        $tracknumber = 0;
    }
    if ($tracknumber =~ m/\//) {
        $tracknumber =~ s/\/.*//;
    }

    # Get or create artist
    my $artist_id;
    $query = Rawk::db->prepare(q{
        SELECT id FROM artist WHERE LOWER(name) = LOWER(?)
        });

    $query->execute($artist);
    $row = $query->fetchrow_hashref();
    if (defined($row)) {
        $artist_id = $row->{'id'};
    } else {
        $query = Rawk::db->prepare(q{
            INSERT INTO artist(name) VALUES(?) RETURNING id
            });
        $query->execute($artist);
        $artist_id = $query->fetchrow_hashref()->{'id'};
    }

    # Get or create album
    my $album_id;
    if (defined($album) and $album ne '') {
        $query = Rawk::db->prepare(q{
            SELECT id FROM album WHERE LOWER(name) = LOWER(?)
        });
        $query->execute($album);
        $row = $query->fetchrow_hashref();
        if (!defined($row)) {
            $query = Rawk::db->prepare(q{
                INSERT INTO album(name) VALUES(?) RETURNING id
            });
            $query->execute($album);
            $row = $query->fetchrow_hashref();
        }
        $album_id = $row->{'id'};
    }

    if (defined($album_id)) {
        Rawk::db->do(q{
            INSERT INTO song(
                title, 
                artist, 
                album, 
                tracknumber, 
                length, 
                path, 
                last_modified
            )
            VALUES (?, ?, ?, ?, ?, ?, ?)
        }, {},
            $title,
            $artist_id,
            $album_id,
            $tracknumber,
            $length,
            $full_path,
            $mtime
        ) or die("invalid db stuff\n");
    } else {
        Rawk::db->do(q{
            INSERT INTO song(
                title, 
                artist, 
                tracknumber, 
                length, 
                path, 
                last_modified
            )
            VALUES (?, ?, ?, ?, ?, ?)
        }, {},
            $title,
            $artist_id,
            $tracknumber,
            $length,
            $full_path,
            $mtime
        );
    }
}

my @directories;
push(@directories, Rawk::config('MUSIC_PATH'));
find(\&handle_file, @directories);

exit(0);
