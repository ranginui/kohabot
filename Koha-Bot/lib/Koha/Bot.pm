package Koha::Bot;

use 5.008008;
use strict;
use warnings;
use Net::OSCAR qw(:standard);

use lib '/usr/local/koha/intranet/modules';
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

our @EXPORT = qw( run_bot

);

our $VERSION = '0.01';

our $opac_url = "http://opac";
our %users;

sub run_bot {
    my ( $screenname, $password ) = @_;
    my $bot = Net::OSCAR->new();
    $bot->set_callback_im_in( \&_im_in );
    $bot->set_callback_signon_done( \&_signon );
    $bot->set_callback_error( \&_got_error );
    $bot->signon( $screenname, $password );
    print "Signed on\n";
    while (1) {
        $bot->do_one_loop();

        # Do stuff
    }
}

sub _got_error {
    my ( $oscar, $connection, $error, $description, $fatal ) = @_;
    print "cant connect $connection, $error, $description $fatal\n";
}

sub _signon {
    print "All signed in\n";
}

sub _im_in {
    my ( $oscar, $sender, $message, $is_away ) = @_;
    print "[AWAY] " if $is_away;
    $message =~ s/<(([^ >]|\n)*)>//g;
    if ( $message =~ /issued items/i ) {
	# user is try to check items on issue to them
	if ($users{$sender}){
	    # if the have authenticated, give them the info
	    my @issued_items = issued_items($users{$sender});
	    foreach my $item (@issued_items){
		$oscar->send_im( $sender, $item->{'title'} );
	    }
	}
	else {
	    # tell them they have to login
	    $oscar->send_im( $sender, "I'm sorry you need to login first, syntax is login cardnumber:password" );
	}
    }
    elsif ( $message =~ /search title (.*)/i ) {
        my ( $results, $total ) = title_search( $1, 0 );
        if ( $total > 0 ) {
            $oscar->send_im( $sender, "$total results found" );
            foreach my $result (@$results) {
                $oscar->send_im( $sender,
"<a href=\"$opac_url/cgi-bin/koha/opac-detail.pl?bib=$result->{'biblionumber'}\">$result->{'title'} $result->{'subititle'} by $result->{'author'}</a>"
                );
            }
        }
        else {
            $oscar->send_im( $sender, "Nothing found for $1" );
        }
    }
    elsif ( $message =~ /search author (.*)/i ) {
        my ( $results, $total ) = author_search( $1, 0 );
        if ( $total > 0 ) {
            $oscar->send_im( $sender, "$total results found" );
            foreach my $result (@$results) {
                $oscar->send_im( $sender,
"<a href=\"$opac_url/cgi-bin/koha/opac-detail.pl?bib=$result->{'biblionumber'}\">$result->{'title'} $result->{'subititle'} by $result->{'author'}</a>"
                );
            }
        }
        else {
            $oscar->send_im( $sender, "Nothing found for $1" );
        }
    }
    elsif ( $message =~ /login (.*)\:(.*)/ ) {
        my $result = login( $1, $2 );
        if ($result) {
	    $users{$sender} = $1;
	    my $borrower = get_borrower($1);
            if ( $result == 2 ) {
                $oscar->send_im( $sender,
                    "Welcome $1, you now have superuser privs" );
            }
            else {
                $oscar->send_im( $sender, "Welcome $1, you are now logged in" );
            }

        }
        else {
            $oscar->send_im( $sender,
                "Im sorry you entered in an invalid cardnumber or password" );
        }
    }

}

## these 2 subroutines could be factored

sub title_search {
    my ( $title, $startfrom ) = @_;
    my $dbh = C4::Context->dbh();
    my ( $tag, $subfield ) =
      MARCfind_marc_from_kohafield( $dbh, 'biblio.title', '' );
    my @tags;
    my @value;
    push @value, $title;
    my $desc_or_asc    = 'ASC';
    my $resultsperpage = 5;
    my @and_or;
    my @excluding;
    my @operator = 'contains';
    my $orderby  = 'biblio.title';
    my ( $results, $total ) =
      catalogsearch( $dbh, \@tags, \@and_or, \@excluding, \@operator, \@value,
        $startfrom * $resultsperpage,
        $resultsperpage, $orderby, $desc_or_asc );
    return ( $results, $total );
}

sub author_search {
    my ( $author, $startfrom ) = @_;
    my $dbh = C4::Context->dbh();
    my ( $tag, $subfield ) =
      MARCfind_marc_from_kohafield( $dbh, 'biblio.author', '' );
    my @tags;
    my @value;
    push @value, $author;
    my $desc_or_asc    = 'ASC';
    my $resultsperpage = 5;
    my @and_or;
    my @excluding;
    my @operator = 'contains';
    my $orderby  = 'biblio.author';
    my ( $results, $total ) =
      catalogsearch( $dbh, \@tags, \@and_or, \@excluding, \@operator, \@value,
        $startfrom * $resultsperpage,
        $resultsperpage, $orderby, $desc_or_asc );
    return ( $results, $total );
}

sub login {
    my ( $username, $password ) = @_;
    my $dbh = C4::Context->dbh;
    my $checked = C4::Auth::checkpw( $dbh, $username, $password );
    return $checked;
}

sub get_borrower {
    my ($username)=@_;
    my $env;
    my $borrower = getpatroninformation($env, '',$username);
    return($borrower);
}

sub issued_items {
    my ($username)=@_;
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
my $dbh=C4::Context->dbh();

        my $sth=$dbh->prepare($select);
my @items;
while (my $data = $sth->fetchrow_hashref()){
    push @items,$data;
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

Koha::Bot - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Koha::Bot;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Koha::Bot, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Chris Cormack, E<lt>chris@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Chris Cormack

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
