# vim: sw=4 

# I don't test die cases because of a bug un $@ 

# use Test::More tests => 1;
use strict;
use warnings;
use lib qw( lib ../lib );
use YAML;
use Test::More tests => 1;
my @I=('')x2;

BEGIN { use_ok( 'MARC::Template' ); }

diag( "MARC::Template $MARC::Template::VERSION, Perl $], $^X" );
