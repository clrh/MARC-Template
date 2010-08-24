use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    qw<
	module_name        MARC::Template
	license            perl
	dist_version_from  lib/MARC/Template.pm
	create_makefile_pl traditional
    >
    , dist_author         => 'Marc Chantreux <marc.chantreux@biblibre.com>'
    , add_to_cleanup      => [ 'MARC-Template-*' ]
    , requires => {qw<
	Scalar::Util 0
	MARC::Record 0
    >}
    , build_requires => {qw<
	Test::More 0
	Data::Compare 0
	YAML 0
    >}
);

$builder->create_build_script();
