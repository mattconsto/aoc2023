#!/usr/bin/env perl

use strict;
use warnings;

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
        my $found = 1;
        for (my $delta = 0; $found && $delta <= min($y, (scalar @$map - 1) - $y - 1); $delta++) {
            $found = 0 unless $map->[$y - $delta] eq $map->[$y + $delta + 1];
        }
        $total += ($y + 1) * 100 if $found;
    }

    for (my $x = 0; $x < (length $map->[0]) - 1; $x++) {
        my $found = 1;
        for (my $delta = 0; $found && $delta <= min($x, ((length $map->[0]) - 1) - $x - 1); $delta++) {
            $found = 0 unless (join '', map {substr $_, $x - $delta, 1} @$map) eq (join '', map {substr $_, $x + $delta + 1, 1} @$map);
        }
        $total += $x + 1 if $found;
    }
}
print "$total\n";
