#!/usr/bin/env perl

use strict;
use warnings;

my @map;
while (<STDIN>) {
    chomp;
    push @map, $1 if /^\s*([\.#\^>v<]+)\s*$/;
}

my $max_path = 0;
my @queue = ([0, 1, 0, '']);
while (@queue) {
    my ($y, $x, $length, $seen) = @{shift @queue};
    next if vec($seen, $y * length($map[$y]) + $x, 1);
    vec($seen, $y * length($map[$y]) + $x, 1) = 1;

    if ($length > $max_path && $y == scalar @map - 1 && $x == length($map[$y]) - 2) {
        $max_path = $length;
        next;
    }

    push @queue, [$y - 1, $x, $length + 1, $seen]
        if $y > 0 && index('.^', substr($map[$y - 1], $x, 1)) != -1;
    push @queue, [$y, $x + 1, $length + 1, $seen]
        if $x < length($map[$y]) - 1 && index('.>', substr($map[$y], $x + 1, 1)) != -1;
    push @queue, [$y + 1, $x, $length + 1, $seen]
        if $y < scalar @map - 1 && index('.v', substr($map[$y + 1], $x, 1)) != -1;
    push @queue, [$y, $x - 1, $length + 1, $seen]
        if $x > 0 && index('.<', substr($map[$y], $x - 1, 1)) != -1;
}
print "$max_path\n";
