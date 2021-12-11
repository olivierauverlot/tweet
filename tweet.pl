#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
use utf8;

use Getopt::Long;
use File::HomeDir;
use Pod::Usage;

use Config::Tiny;
use Net::Twitter;

use constant VERSION => '0.1';

my %history;
my $conf_file = File::HomeDir->my_home . "/.tweet.ini";
my $history_file = File::HomeDir->my_home . "/.tweet.db";

sub init {
    my $content = <<EOF;
[authenticate]
api_key=
api_secret=
access_token=
access_token_secret=
EOF
    if(! -e $conf_file) {
        open(my $fh, '>', $conf_file) or die "Can't create configuration file in home directory";
        print $fh $content;
        close($fh);
        say "Configuration file created in home directory";
    } else {
        say "Configuration file already exists";
    }
}

sub list {
    my @keys = sort keys %history;
    foreach my $key (@keys) {
        say $key . "\t" . $history{$key};
    }
}

sub delete {
    my @keys = sort keys %history;
    if(scalar(@keys) > 0) {
        my $datetime = $keys[-1];
        delete( $history{$datetime} );
    }
}

sub clear {
    %history = ();
}

sub version {
    say VERSION;
}

sub post {
    my ($url) = @_;
    my $curTime = localtime();
    # send url to Twitter
    $history{$curTime} = $url;
}

if(! -e $history_file) {
    dbmopen(%history, $history_file, 0644) or die "Can't create history file : $!";
}

GetOptions(
    'init' => \&init,
    'post=s' => sub { 
        my ($cmd,$url) = @_; 
        post $url 
    },
    'list' => \&list,
    'delete' => \&delete,
    'clear' => \&clear,
    'help' => sub { pod2usage(1) },
    'version' => \&version
) or pod2usage(2);

dbmclose(%history);

__END__

=head1 Tweet

Tweet an url to a Twitter account. The ressource must contain a Twitter card.

=head1 SYNOPSIS

tweet [OPTIONS] URL

 Options:
    -i, --init        create configuration file in home directory and exit
    -p, --post        post the url on Twitter and exit
    -l, --list        display history of posted urls and exit
    -d, --delete      delete last posted url in history and exit
    -c, --clear       clear history and exit      
    -h, --help        display this help and exit
    -v, --version     output version information and exit

=head1 VERSION

0.1

=head1 OPTIONS

=over 8

=item B<-init>

Print a brief help message and exits.

api_key
api_secret
access_token
access_token_secret

=item B<-list>

Prints the manual page and exits.

=item B<-man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION

B<This program> will read the given input file(s) and do something
useful with the contents thereof.

=cut
