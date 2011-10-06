use strict;
use warnings;

package Rawk;

use CGI;
use CGI::Cookie;
use DBI;
use Config::File qw(read_config_file);

my $cf_dbh;
my $config_hash;

sub config {
    my $key = shift;
    return if not defined($key);

    if (!defined($config_hash)) {
        $config_hash = read_config_file("/srv/http/music/config");
    }
    return $config_hash->{$key};
}

sub username {
    my $username = $ENV{'REMOTE_USER'};
#    $username =~ s/\@SAMFUNDET\.NO$//;
    return $username;
}

sub db {
    if (!defined($cf_dbh)) {
        my @settings = (
            config('DB_DSN'),
            config('DB_USER'),
            config('DB_PASS'),
        );
        $cf_dbh = DBI->connect(@settings)
            or die "Unable to connect to database!";
    }
    return $cf_dbh;
}

$SIG{__DIE__} = sub {
    # TODO: maybe do the error handling here, send a stacktrace?
    print STDERR "LOL DEADED\n";
};

END {
    if (defined($cf_dbh)) {
        $cf_dbh->disconnect();
    }
}

1;
