# vim: sw=4 

# I don't test die cases because of a bug un $@ 

# use Test::More tests => 1;
use Data::Compare;
use strict;
use warnings;
use lib qw( lib ../lib );
use YAML;
use Test::More 'no_plan';
my @I=('')x2;

BEGIN {
    use_ok( 'MARC::Template' );
}

diag( "MARC::Template $MARC::Template::VERSION, Perl $], $^X" );

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

new_usecase('009: noticeID
');

($r,$label) = $template->spell(
    {noticeID => 1515 }
);
$v = [[ '009',@I, 1515 ]];
ok(Compare($r,$v),usecase('simple datafield'))
    or diag(Dump $r)
;

new_usecase('610: { a: lastname, b: firstname }
');

($r,$label) = $template->spell({ qw( lastname Dabluez firstname Agathe ) });
$v = [[ '610', @I, qw( a Dabluez b Agathe ) ]];

ok(Compare($r,$v),usecase('subfields datafield'))
    or diag(Dump $r)
;


new_usecase('610: [ authors, { a: lastname, b: firstname } ]
');

($r,$label) = $template->spell({
	authors => [
	{
	    lastname => 'Santori'
	    , firstname => ['Jean','André']
	}
	, { qw( lastname Mandelbrot firstname Benoit ) }
	]
    });
$v = [
    [ '610',@I,qw( a Santori b Jean b André )]
    , [ '610',@I,qw( a Mandelbrot b Benoit )]
];
ok(Compare($r,$v),usecase('MValued subfield'))
    or diag(Dump $r)
;

my $good_label = 'foo';

# REMOVED: do not forge the leader :-)
# for my $leader (qw< leader 000 LDR >) {
#     new_usecase("$leader: $good_label
# ");
#     ($r,$label) = $template->spell( { label => 'foo'});
#     is($r,undef,"no field for leader $leader");
#     is($label, $good_label ,"LDR correctly set for $leader");
# }
