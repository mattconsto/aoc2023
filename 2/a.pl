#!/usr/bin/env perl

use strict;
use warnings;

my $max_red   = 12;
my $max_green = 13;
my $max_blue  = 14;

my %games;
while (<STDIN>) {
    chomp;
    my ($no, $info) = /^\s*Game\s*(\d+):\s*(.*)/;
    $games{$no} = [map {{map {reverse split /\s+/} split /\s*,\s*/}} split /\s*;\s*/, $info];
}

my $sum = 0;
for my $game (sort keys %games) {
    my $possible = 1;
    for my $round (@{$games{$game}}) {
        if (
            ($round->{red}   // 0) > $max_red   ||
            ($round->{green} // 0) > $max_green ||
            ($round->{blue}  // 0) > $max_blue
        ) {
            $possible = 0;
            last;
        }
    }
    $sum += $game if $possible;
}

print "$sum\n";
