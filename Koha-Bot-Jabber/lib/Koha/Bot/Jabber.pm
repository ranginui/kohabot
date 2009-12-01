package Koha::Bot::Jabber;

use 5.008008;
use Net::Jabber qw( Client );
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Koha::Bot::Jabber ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';


# Preloaded methods go here.


sub connect {
    my ($hostname) = @_;
    my $Con = new Net::Jabber::Client();                
    my $status = $Con->Connect(hostname=>"jabber.org"); 

}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Koha::Bot::Jabber - Perl extension for getting a Koha bot up on a Jabber network

=head1 SYNOPSIS

  use Koha::Bot::Jabber;
  

=head1 DESCRIPTION



=head2 EXPORT

connect()



=head1 SEE ALSO

=head1 AUTHOR

Chris Cormack, E<lt>chris@bigballofwax.co.nzE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Chris Cormack


=cut
