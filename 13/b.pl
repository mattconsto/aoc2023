#!/usr/bin/env perl

use strict;
use warnings;

use Text::Levenshtein qw(distance);
use List::Util qw(min);

my @maps = ([]);
while (<STDIN>) {
    chomp;
    push @maps, [] if /^$/;
    push @{$maps[-1]}, $_ if /^[#\.]+$/;
}

my $total = 0;
for my $map (@maps) {
    next unless @$map;

    for (my $y = 0; $y < scalar @$map - 1; $y++) {
        my $distance = 0;
        for (my $delta = 0; $distance <= 1 && $delta <= min($y, (scalar @$map - 1) - $y - 1); $delta++) {
            $distance += distance($map->[$y - $delta], $map->[$y + $delta + 1]);
        }
        $total += ($y + 1) * 100 if $distance == 1;
    }

    for (my $x = 0; $x < (length $map->[0]) - 1; $x++) {
        my $distance = 0;
        for (my $delta = 0; $distance <= 1 && $delta <= min($x, ((length $map->[0]) - 1) - $x - 1); $delta++) {
            $distance += distance(
                (join '', map {substr $_, $x - $delta, 1} @$map),
                (join '', map {substr $_, $x + $delta + 1, 1} @$map),
            );
        }
        $total += $x + 1 if $distance == 1;
    }
}
print "$total\n";
