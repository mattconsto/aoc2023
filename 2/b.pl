#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw(max);

my %games;
while (<STDIN>) {
    chomp;
    my ($no, $info) = /^\s*Game\s*(\d+):\s*(.*)/;
    $games{$no} = [map {{map {reverse split /\s+/} split /\s*,\s*/}} split /\s*;\s*/, $info];
}

my $sum = 0;
for my $game (sort keys %games) {
    my $min_red   = 0;
    my $min_green = 0;
    my $min_blue  = 0;

    for my $round (@{$games{$game}}) {
        $min_red   = max($min_red,   $round->{red}   // 0);
        $min_green = max($min_green, $round->{green} // 0);
        $min_blue  = max($min_blue,  $round->{blue}  // 0);
    }

    $sum += $min_red * $min_green * $min_blue;
}

print $sum . "\n";
