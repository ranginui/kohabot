package Koha::Bot;

# Copyright 2007 Chris Cormack
# chris@bigballofwax.co.nz

use 5.008008;
use strict;
use warnings;

# set this to the path to your Koha moudules
use lib '/nzkoha/intranet/modules/';

use C4::Context;
use C4::SearchMarc;
use C4::Biblio;
use C4::Auth;
use C4::Circulation::Circ2;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Koha::Bot ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = (
    'all' => [
        qw(

          )
    ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( search_catalogue login get_borrower issued_items

);

our $VERSION = '0.03';


# module to search the catalogue

sub search_catalogue {
    my ( $type, $term ) = @_;
    my $dbh = C4::Context->dbh();
    if ($type eq 'title'){
	$type = 'biblio.title';
    }
    elsif ($type eq 'author'){
	$type = 'biblio.author';
    }
    my ( $tag, $subfield ) =
      MARCfind_marc_from_kohafield( $dbh, $type, '' );    
    my @tags;
    my @value;
    push @value, $term;
    my $desc_or_asc    = 'ASC';
    my $resultsperpage = 5;
    my @and_or;
    my @excluding;
    my @operator = ('contains');
    my $orderby = $type;
    my $startfrom = 0;
    my ( $results, $total ) =
      catalogsearch( $dbh, \@tags, \@and_or, \@excluding, \@operator, \@value,
        $startfrom * $resultsperpage,
        $resultsperpage, $orderby, $desc_or_asc );
    return ( $results, $total );
}

# Checks the usernamae and password against the database
sub login {
    my ( $username, $password ) = @_;
    my $dbh = C4::Context->dbh;
    my $checked = C4::Auth::checkpw( $dbh, $username, $password );
    return $checked;
}

sub get_borrower {
    my ($username) = @_;
    my $env;
    my $borrower = getpatroninformation( $env, '', $username );
    return ($borrower);
}

sub issued_items {
    my ($username) = @_;
    my $borrower = get_borrower($username);

    #    my $issues = getissues($borrower->{'borrowernumber'});
    # the getissues routine in Koha is currently retarded
    # so im doing it here, until I get round to fixing circulation
    my $select = "SELECT items.*,issues.timestamp      AS timestamp,
                                  issues.date_due       AS date_due,
                                  items.barcode         AS barcode,
                                  biblio.title          AS title,
                                  biblio.author         AS author,
                                  biblioitems.dewey     AS dewey,
                                  itemtypes.description AS itemtype,
                                  biblioitems.subclass  AS subclass,
                                  biblioitems.classification AS classification
                          FROM issues,items,biblioitems,biblio, itemtypes
                          WHERE issues.borrowernumber  = ?
                          AND issues.itemnumber      = items.itemnumber
                          AND items.biblionumber     = biblio.biblionumber
                          AND items.biblioitemnumber = biblioitems.biblioitemnumber
                          AND itemtypes.itemtype     = biblioitems.itemtype
                          AND issues.returndate      IS NULL
                          ORDER BY issues.date_due";
    my $dbh = C4::Context->dbh();

    my $sth = $dbh->prepare($select);
    $sth->execute($borrower->{'borrowernumber'});
    my @items;
    while ( my $data = $sth->fetchrow_hashref() ) {
        push @items, $data;
    }
    $sth->finish();
    return @items;

}

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Koha::Bot - Perl extension for Creating a Bot for use on IM networks

=head1 SYNOPSIS

  use Koha::Bot;
  
=head1 DESCRIPTION

This module can be used to create a IM bot that talks to Koha. Currently it just works
with AIM. 

Currently it can search a catalogue. The user can authenticate and get a list
of books issued to themselves

=head2 EXPORT

search_catalogue



=head1 SEE ALSO

koha@lists.katipo.co.nz

www.koha.org

=head1 AUTHOR

Chris Cormack, E<lt>chris@bigballofwax.co.nzE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Chris Cormack

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
