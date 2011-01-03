# vim: sw=4 

# I don't test die cases because of a bug un $@ 

# use Test::More tests => 1;
use strict;
use warnings;
use lib qw( lib ../lib );
use YAML;
use MARC::Template;
use Test::More 'no_plan';
my @I=('')x2;

my ($template,$r,$v,$label);
my $usecase = 0;

sub usecase { "usecase $usecase: @_" }
sub new_usecase {
    $usecase++;
    @_ or return;
    $template = MARC::Template->new(YAML::Load shift);
    ok(( 'MARC::Template' eq ref $template ), usecase('constructor'));
    # diag(Dump $template);
}

new_usecase(' 
    009: noticeID
');

($r,$label) = $template->spell( { noticeID => 1515 } );
$v = [[ '009',@I, 1515 ]];

is_deeply ( $r, $v, usecase('simple datafield') ) or diag(Dump $r);

new_usecase('
    610: { a: lastname, b: firstname }
');

($r,$label) = $template->spell({ qw( lastname Dabluez firstname Agathe ) });
$v = [[ '610', @I, qw( a Dabluez b Agathe ) ]];

is_deeply( $r, $v, usecase('subfields datafield') )
    or diag(Dump $r);

new_usecase('610: [ authors, { a: lastname, b: firstname } ]
');

($r,$label) = $template->spell(
    { authors =>
	[ { lastname => 'Santori' , firstname => ['Jean','André'] }
	, { qw( lastname Mandelbrot firstname Benoit ) }
	]
    }
);

$v =
[ [ 610 => @I, qw( a Santori b Jean b André )]
, [ 610 => @I, qw( a Mandelbrot b Benoit )]
];


is_deeply( $r, $v, usecase('MValued subfield') )
    or diag(Dump $r);

my $good_label = 'foo';
