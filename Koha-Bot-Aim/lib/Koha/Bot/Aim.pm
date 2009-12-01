package Koha::Bot::Aim;

# Copyright 2007 Chris Cormack
# chris@bigballofwax.co.nz

# This file is part of KohaBot.
#
# KohaBot is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# KohaBot is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# KohaBot; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA
# 

use 5.008008;
use strict;
use warnings;
use Net::OSCAR qw(:standard);
use Koha::Bot;

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

our $VERSION = '0.03';


# we use this hash to match authenticated users with the IM names
our %users;

# this sub routine sets up the bot and runs it
# Think of it as an event loop, it doesnt do anything until it needs to service
# an interrupt

our $opac_url;

sub run_bot {
    my ( $screenname, $password, $url ) = @_;
    print "url is $url";
    $opac_url = $url;
    print "url is $opac_url";
    my $bot = Net::OSCAR->new();
    $bot->set_callback_im_in( \&_im_in );
    $bot->set_callback_signon_done( \&_signon );
    $bot->set_callback_error( \&_got_error );
    $bot->signon( $screenname, $password );
    while (1) {
        $bot->do_one_loop();
    }
}

# error handler if the bot can't connect this is called
sub _got_error {
    my ( $oscar, $connection, $error, $description, $fatal ) = @_;
    print "cant connect $connection, $error, $description $fatal\n";
}


# called if the bot connects succesfully 
sub _signon {
    print "All signed in\n";
}

# this is called if the bot receives an instant message
# it then parses the messsage and reacts
sub _im_in {
    my ( $oscar, $sender, $message, $is_away) = @_;
    print "[AWAY] " if $is_away;
    print "url is $opac_url\n";
    print "im logged in\n";
    $message =~ s/<(([^ >]|\n)*)>//g;
    if ( $message =~ /issued items/i ) {
        # user is try to check items on issue to them
        if ( $users{$sender} ) {
            # if the have authenticated, give them the info
            my @issued_items = issued_items( $users{$sender} );
            foreach my $item (@issued_items) {
                $oscar->send_im( $sender, "$item->{'title'} / $item->{'author'} : $item->{'date_due'}" );
            }
        }
        else {

            # tell them they have to login
            $oscar->send_im( $sender,
"I'm sorry you need to login first, syntax is login cardnumber:password"
            );
        }
    }
    elsif ( $message =~ /search title (.*)/i ) {
	# user is doing a search of the catalogue using title
        my ( $results, $total ) = search_catalogue( 'title', $1 );
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
	# searching by author
        my ( $results, $total ) = search_catalogue( 'author', $1);
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
	# user authenticating
	# login username:password
	warn "opac url is $opac_url";
        my $result = login( $1, $2 ,$opac_url);
        if ($result) {
	    # if they successfully logged in $result will be 1 for normal user
	    # 2 if they logged in with the superuser login and password
	    
	    # add them to the hash
            $users{$sender} = $1;
	    # get borrower information
            my $borrower = get_borrower($1);
            if ( $result == 2 ) {
		# if they are superuser 
		# we will have to do something more here
                $oscar->send_im( $sender,
                    "Welcome $1, you now have superuser privs" );
            }
            else {
                $oscar->send_im( $sender, "Welcome $borrower->{'firstname'}, you are now logged in" );
            }

        }
        else {
            $oscar->send_im( $sender,
                "Im sorry you entered in an invalid cardnumber or password" );
        }
    }

}


# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__


=head1 NAME

Koha::Bot - Perl extension for Creating a Bot for use on IM networks

=head1 SYNOPSIS

  use Koha::Bot;
  
  my $screenname='kohabot';
  my $password='wootwoot';
  my $opac_url='hlt.dev.kohalibrary.com';

  run_bot($screenname,$password,$opac_url);

=head1 DESCRIPTION

This module can be used to create a IM bot that talks to Koha. Currently it just works
with AIM. 

Currently it can search a catalogue. The user can authenticate and get a list
of books issued to themselves

=head2 EXPORT

run_bot()



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
                                                                                                                           
KohaBot is distributed in the hope that it will be useful, but WITHOUT ANY                                                 
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR                                             
A PARTICULAR PURPOSE.  See the GNU General Public License for more details.                                               
                                                                                                                           
You should have received a copy of the GNU General Public License along with                                              
KohaBot; if not, write to the Free Software Foundation, Inc., 59 Temple Place,                                           
Suite 330, Boston, MA  02111-1307 USA                                                                                     


=cut
