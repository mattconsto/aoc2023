#!/usr/bin/env perl

use strict;
use warnings;

my @map;
my @queue;
for (my $y = 0; <STDIN>; $y++) {
    chomp;
    push @queue, [$y, $-[1], 0] if /(S)/;
    push @map, $1 =~ s/S/./gr if /^\s*([\.#S]+)\s*$/;
}

my %seen;
while (my $pos = shift @queue) {
    my ($y, $x, $depth) = @$pos;

    next if defined $seen{$y}{$x};
    $seen{$y}{$x} = $depth;

    next if $depth >= 64;
    push @queue, [$y + 1, $x, $depth + 1] if $y < scalar @map - 1 && substr($map[$y + 1], $x, 1) eq '.';
    push @queue, [$y - 1, $x, $depth + 1] if $y > 0 && substr($map[$y - 1], $x, 1) eq '.';
    push @queue, [$y, $x + 1, $depth + 1] if $x < length($map[$y]) - 1 && substr($map[$y], $x + 1, 1) eq '.';
    push @queue, [$y, $x - 1, $depth + 1] if $x > 0 && substr($map[$y], $x - 1, 1) eq '.';
}

print((scalar grep {$_ % 2 == 0} map {values %$_} values %seen) . "\n");
