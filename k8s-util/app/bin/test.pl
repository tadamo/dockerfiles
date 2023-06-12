#!/usr/bin/env perl
use Mojo::Base -strict, -signatures, -async_await;
use Number::Format;

my $n = $ARGV[0];

my $cores = $n =~ s/m$// ? $n * .001 : $n;

use Data::Dumper qw(Dumper);
warn Dumper $cores;
