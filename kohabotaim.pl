#!/usr/bin/perl

use Koha::Bot::Aim;
use strict;

my $screenname='kohabot';
my $password='wootwoot';
my $opac_url='http://hlt.dev.kohalibrary.com';

run_bot($screenname,$password,$opac_url);