#!/usr/bin/env perl

use strict;
use warnings;

my @bounds;
my @lines;
while (<STDIN>) {
    chomp;
    if (/^\s*(\d+)\s*,\s*(\d+)\s*$/) {
        @bounds = ($1, $2);
    }
    if (/^\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*@\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*$/) {
        push @lines, [$1, $2, $4, $5, $5 / $4, $2 - ($5 / $4) * $1]; # x, y, dx, dy, m, c
    }
}

my $intersections = 0;
for (my $i = 0; $i < scalar @lines; $i++) {
    my ($x_i, $y_i, $dx_i, $dy_i, $m_i, $c_i) = @{$lines[$i]};
    for (my $j = $i + 1; $j < scalar @lines; $j++) {
        my ($x_j, $y_j, $dx_j, $dy_j, $m_j, $c_j) = @{$lines[$j]};
        next if $m_j == $m_i;

        my $x = ($c_i - $c_j) / ($m_j - $m_i);
        my $y = $m_i * $x + $c_i;

        $intersections++ if (
            $x >= $bounds[0] && $x <= $bounds[1] &&
            $y >= $bounds[0] && $y <= $bounds[1] &&
            ($x > $x_i xor $dx_i < 0) &&
            ($y > $y_i xor $dy_i < 0) &&
            ($x > $x_j xor $dx_j < 0) &&
            ($y > $y_j xor $dy_j < 0)
        );
    }
}
print "$intersections\n";
