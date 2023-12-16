#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw(sum0);

my @map;
while (<STDIN>) {
    chomp;
    push @map, $1 if /^(.+)$/;
}

my %previous;
my @queue = ([0, 0, 0, 1]);
my %seen;
while (@queue) {
    my ($y, $x, $dy, $dx) = @{shift @queue};
    next unless $y >= 0 && $y < scalar @map && $x >= 0 && $x < length $map[$y];
    next if $previous{"$y, $x, $dy, $dx"};

    my $node = substr($map[$y], $x, 1);
    next unless $node;

    if ($node eq '.' || ($node eq '|' && !$dx) || ($node eq '-' && !$dy)) {
        push @queue, [$y + $dy, $x + $dx, $dy, $dx];
    } elsif ($node eq '|') {
        push @queue, [$y - 1, $x, -1, 0];
        push @queue, [$y + 1, $x, +1, 0];
    } elsif ($node eq '-') {
        push @queue, [$y, $x - 1, 0, -1];
        push @queue, [$y, $x + 1, 0, +1];
    } elsif ($node eq '\\') {
        push @queue, [$y + $dx, $x + $dy, $dx, $dy];
    } elsif ($node eq '/') {
        push @queue, [$y - $dx, $x - $dy, -$dx, -$dy];
    } else {
        die "Unimplemented!";
    }

    $seen{$y}{$x} = 1;
    $previous{"$y, $x, $dy, $dx"} = 1;
}

print sum0(map {sum0 (values %{$seen{$_}})} keys %seen) . "\n";
