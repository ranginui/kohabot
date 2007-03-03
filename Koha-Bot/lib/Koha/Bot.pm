package Koha::Bot;

use 5.008008;
use strict;
use warnings;
use Net::OSCAR qw(:standard);
  
require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Koha::Bot ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( run_bot
	
);

our $VERSION = '0.01';


sub run_bot {
    my ($screenname,$password) = @_;
    my $bot = Net::OSCAR->new();
    $bot->set_callback_im_in(\&_im_in);
    $bot->signon($screenname, $password);
    while(1) {
	$bot->do_one_loop();
	# Do stuff
    }
}

sub _im_in {
     my($oscar, $sender, $message, $is_away) = @_;
    print "[AWAY] " if $is_away;
    if ($message =~ /issued items/i){
	$oscar->send_im ($sender, "heres stuff");
	my $info = $oscar->get_info($sender);
	print "$info\n";
    }
#    print "$sender: $message\n";
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
