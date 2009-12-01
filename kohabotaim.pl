#!/usr/bin/perl

# Copyright 2009 Chris Cormack <chris@bigballofwax.co.nz>
# This file is part of KohaBot.
#
# KohaBot is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA
#

use Koha::Bot::Aim;
use strict;

my $screenname='kohabot';
my $password='wootwoot';
my $opac_url='http://hlt.dev.kohalibrary.com';

run_bot($screenname,$password,$opac_url);