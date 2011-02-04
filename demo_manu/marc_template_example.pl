#! /usr/bin/perl
use 5.10.0;
use strict;
use warnings;
use MARC::Template;

my $template = MARC::Template->new(
    { '010' => 'ISBN'
    , 200   => { a => 'title', f => 'authors' } 
    , 995   => [ Items => { k => 'callnumber', f => 'barcode' } ]
    }
);

my $data =
{ ISBN => '034536676X'
, title => 'The World According to Garp'
, authors => 'J. Irving'
, Items   =>
    [ { qw< callnumber IRV25 barcode 123123213 > }
    , { qw< callnumber IRV25 barcode Z34R34532 > }
    ]
};

say $template->build_record($data)->as_formatted;
