#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw(max sum0);

my @map;
while (<STDIN>) {
    chomp;
    push @map, $1 if /^(.+)$/;
}

my $maximum = 0;
for my $starting_node (
    (map {[$_, 0, 0, 1]} 0..(scalar @map - 1)),
    (map {[$_, (length $map[$_]) - 1, 0, -1]} 0..(scalar @map - 1)),

    (map {[0, $_, 1, 0]} 0..((length $map[0]) - 1)),
    (map {[scalar @map - 1, $_, -1, 0]} 0..((length $map[0]) - 1)),
) {
    my %previous;
    my @queue = ($starting_node);
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

    $maximum = max($maximum, sum0(map {sum0 (values %{$seen{$_}})} keys %seen));
}

print "$maximum\n";
