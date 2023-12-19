#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw(min);

my @dirs = qw(R D L U);
my @ins;
while (<STDIN>) {
    chomp;
    my ($len, $dir) = /^\s*[URDL]\s*\d+\s*\(\s*#\s*([0-9a-f]+)([0123])\s*\)\s*$/;
    push @ins, [$dirs[$dir], hex $len];
}

my $total = 1;
while (@ins) {
    # Collapse nodes
    for (my $i = 0; $i < scalar @ins; $i++) {
        if (index("URDLURDL", "$ins[$i-2][0]$ins[$i-1][0]$ins[$i][0]") != -1) {
            # Clockwise nodes
            my $delta      = min($ins[$i-2][1], $ins[$i][1]);
            $total        += ($ins[$i-1][1] + 1) * $delta;
            $ins[$i-2][1] -= $delta;
            $ins[$i][1]   -= $delta;
        } elsif (index("LDRULDRU", "$ins[$i-2][0]$ins[$i-1][0]$ins[$i][0]") != -1) {
            # Anticlockwise nodes
            my $delta      = min($ins[$i-2][1], $ins[$i][1]);
            $total        -= ($ins[$i-1][1] - 1) * $delta;
            $ins[$i-2][1] -= $delta;
            $ins[$i][1]   -= $delta;
        }
    }

    # Cleanup
    for (my $i = 0; $i < scalar @ins; $i++) {
        if ($ins[$i][1] == 0) {
            # Empty nodes
            splice @ins, $i--, 1;
        } elsif ($ins[$i][0] eq $ins[$i-1][0]) {
            # Identical directions
            $ins[$i-1][1] += $ins[$i][1];
            splice @ins, $i--, 1;
        } elsif (
            index("LRLR", "$ins[$i-1][0]$ins[$i][0]") != -1 ||
            index("UDUD", "$ins[$i-1][0]$ins[$i][0]") != -1
        ) {
            # Nodes which go back on themselves
            my $delta      = min($ins[$i-1][1], $ins[$i][1]);
            $total        += $delta;
            $ins[$i-1][1] -= $delta;
            $ins[$i][1]   -= $delta;
        }
    }
}
print "$total\n";
