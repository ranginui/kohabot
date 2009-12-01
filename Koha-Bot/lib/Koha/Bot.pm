package Koha::Bot;

# Copyright 2007 Chris Cormack
# chris@bigballofwax.co.nz

use 5.008008;
use XML::Simple;
use LWP::Simple;
use strict;
use warnings;

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
    my $results;
    my $total;
    return ( $results, $total );
}

# Checks the username and password against the koha site
sub login {
    my ( $username, $password, $opacurl ) = @_;
    my $url = $opacurl."/cgi-bin/koha/ilsdi.pl?service=AuthenticatePatron&username=".$username."&password=".$password;
    my $result = get($url);
    return unless defined $result;
    my $user = XMLin($result);
    if ($user->{AuthenticatePatron}->{id}){
	return $user->{AuthenticatePatron}->{id};
    }
    else {
	return;
    }
}

sub get_borrower {
    my ($username) = @_;
    my $borrower;    
    return ($borrower);
}

sub issued_items {
    my ($username) = @_;
    my @items;
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

This file is part of KohaBot.                                                                                             
                                                                                                                           
KohaBot is free software; you can redistribute it and/or modify it under the                                              
terms of the GNU General Public License as published by the Free Software                                                 
Foundation; either version 3 of the License, or (at your option) any later                                                
version.                                                                                                                  
                                                                                                                           
KohaBot is distributed in the hope that it will be useful, but WITHOUT ANY                                                  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR                                             
A PARTICULAR PURPOSE.  See the GNU General Public License for more details.                                               
                                                                                                                           
You should have received a copy of the GNU General Public License along with                                              
KohaBot; if not, write to the Free Software Foundation, Inc., 59 Temple Place,                                    
Suite 330, Boston, MA  02111-1307 USA                                                                                     


=cut
