#! /usr/bin/perl
use Modern::Perl;
use MARC::Template;

my $book =
{ title   => 'Perl pour les nuls'
, authors => [qw/ saorge eiro hdl /]
, items   =>
    [ {qw/ cote AZE1 barcode 234324 /}
    , {qw/ cote ZOO2 barcode 111111 /}
    ]
};

my $template = MARC::Template->new(
    { 200 => {qw/ a title f authors /}
    , 995 => [ items => {qw/ k cote h barcode /} ]
    }
);

say $template->build_record( $book )->as_formatted;
