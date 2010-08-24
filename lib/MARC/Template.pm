# vim: sw=4
package MARC::Template;
use 5.10.0;
use warnings;
use strict;
use Carp;
use MARC::Record;
use YAML;
use Scalar::Util qw< reftype >;

=head1 NAME

MARC::Template - The great new MARC::Template!

=head1 VERSION

Version 0.03

=cut

our $VERSION = '0.03';
my @I = ('')x2;


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use MARC::Template;

    my $foo = MARC::Template->new();
    ...

=head1 FUNCTIONS

=head2 new

=cut

sub new { bless { template => pop }, __PACKAGE__ }
our $DEBUG = 0;
sub debug { $DEBUG and say STDERR @_ }

=head2 _subfield

is a private function that returns the subfields according to a template.
$subfield is the template, $data is the hash where values are stored and
@r returns list of subfields. for exemple:

    { a: nom, b: prenom }, { nom: foo, prenom: marc }
returns

    qw( a foo b marc );

=cut

sub _subfields {
    my ($subfield,$data) = @_;
    my @r;
    while ( my ($subfield_name,$key_in_data) = each %$subfield ) {
	debug "subfield $subfield_name: $key_in_data";
	my $val = $$data{$key_in_data} or next;
	if (my $reftype = reftype $val) {
	    $reftype eq 'ARRAY' or confess "$reftype reftype isn't supported", Dump $val;
	    push @r, map { $subfield_name => $_ } @$val;
	} else { push @r, $subfield_name => $val; }
    }
    @r;
}

sub _field {
    my ($fieldname,$ref,$data) = @_;
    if (defined $data) {
	if ( my $rt = reftype $data ) {
	    if ( $rt ne 'HASH' ) {
		die YAML::Dump 
		{ "data isn't hashref for fieldname $fieldname" =>
		    { 'ref' => $ref
		    , data  => $data
		    }
		}
	    }
	} else {
	    die YAML::Dump 
	    { "data [$data] must be a hashref at fieldname $fieldname" =>
		{ 'ref' => $ref
		, data  => $data
		}
	    }
	}
    }


    my @subfield_data = _subfields($ref,$data);
    $DEBUG > 1 and say STDERR join('//',@subfield_data);
    @subfield_data
	? [ $fieldname,@I ,@subfield_data ]
	: ()
    ;
}

=head2 spell

returns ($fields,$label) where

$fields is a array reftype of arrays that can be passed to MARC::Field->new

=cut

sub _spell_mv_subfield { # mv means MultiValued

    # from example:
    # example: 995: [ items, { h: barcode, b: branchcode } ]
    # $key               is 'items'
    # $subfield_template is { h: barcode, b: branchcode }
    my ($subfield, $data) = @_;
    my ($key,$subfield_template) = @$subfield;

    # $subfield_template MUST be a hash!
    my $template_ref = reftype($subfield_template) or return;
    $template_ref eq 'HASH'
	or confess "$template_ref reference not supported",Dump($subfield_template);

    # if the $key exists in data
    my $mv_data = $$data{$key} or return undef;

    debug "multivalued $key";
    $DEBUG > 1 and debug Dump $mv_data;

    # and the value is an ArrayRef
    my $typeof_data = reftype $mv_data
	or confess "data ($mv_data) for repeatable field $key";
    $typeof_data eq 'ARRAY'
	or confess "Trying to build $key,"
	, "$typeof_data reference where ARRAY expected for $key data"
	, Dump($mv_data)
    ;

    # then everything is ok
    { data     => $mv_data
    , template => $subfield_template
    };
}

sub spell {
    my ($self,$data) = @_;
    my $label;
    unless ( 'HASH' eq reftype $data ) {
	confess 'HASH reftype required as data';
    }
    my @r;

    # FIELD: while ( my ($fieldname,$subfield) =
    #     each %{ $$self{template} }
    # ) {

    FIELD: for my $fieldname ( sort keys %{ $$self{template} } ) {
	my $subfield = $$self{template}{$fieldname};
	debug "FIELD: $fieldname";
	if (my $typeof_subfield = reftype $subfield ) {
	    if ( $typeof_subfield eq 'HASH' ) {
		# example: 200: { a: author, b: title }
		push @r, _field($fieldname,$subfield,$data)
	    } elsif ( $typeof_subfield eq 'ARRAY') {
		# example: 995: [ items, { h: barcode, b: branchcode } ]
		# this is for multivalued fields

		# get subfield template and data or next if no data
		my $serialize = _spell_mv_subfield( $subfield, $data )
		    or next FIELD;

		# foreach data, add a new field
		push @r, map {
		    _field(
			$fieldname
			, $$serialize{template}
			, $_
		    )
		} @{ $$serialize{data} };

	    } else { confess "$typeof_subfield reference not supported" }
	} else {
	    my $value = $$data{$subfield} or next FIELD;
	    # print 'adding datafield', Dump [$fieldname, @I, $value];
	    push @r, [$fieldname, @I, $value];
	}
    }
    @r ? \@r : undef;
}

sub build_record {
    my ($self,$data) = @_;
    my $fields = $self->spell($data);
    my $r = MARC::Record->new;
    for ( @$fields ) {
	$r->append_fields(MARC::Field->new(@$_))
    }
    $r;
}

=head1 AUTHOR

Marc Chantreux, C<< <marc.chantreux at biblibre.com >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-marc-template at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MARC-Template>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MARC::Template


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MARC-Template>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MARC-Template>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MARC-Template>

=item * Search CPAN

L<http://search.cpan.org/dist/MARC-Template>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Marc Chantreux, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of MARC::Template
