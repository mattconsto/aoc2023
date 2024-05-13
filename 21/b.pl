#!/usr/bin/env perl

use strict;
use warnings;

use Const::Fast;

const my $GROUND => '.';
const my $STEPS  => 26_501_365;

my @map;
my @queue;
for (my $y = 0; <STDIN>; $y++) {
    chomp;
    push @queue, [0, 0, $y, $-[1], 0] if /(S)/;
    push @map, $1 =~ s/S/./gr if /^\s*([\.#S]+)\s*$/;
}
my $full_width = length $map[0];
my $half_width = int $full_width / 2;

my %seen;
my %total;
my %totals;
while (my $position = shift @queue) {
    my ($gy, $gx, $y, $x, $depth) = @$position;
    next if substr($map[$y], $x, 1) ne $GROUND;

    $seen{$gy}{$gx}{$y} //= '';
    next if vec($seen{$gy}{$gx}{$y}, $x, 1);
    vec($seen{$gy}{$gx}{$y}, $x, 1) = 1;
    ++$total{$depth % 2};

    if (!defined $totals{$depth} || $total{$depth % 2} > $totals{$depth}) {
        $totals{$depth} = $total{$depth % 2};
    }

    next if $depth >= 2 * $full_width + $half_width;
    push @queue, [$y < scalar @map - 1 ? $gy : $gy + 1, $gx, $y < scalar @map - 1 ? $y + 1 : 0, $x, $depth + 1];
    push @queue, [$y > 0 ? $gy : $gy - 1, $gx, $y > 0 ? $y - 1 : scalar @map - 1, $x, $depth + 1];
    push @queue, [$gy, $x < length($map[$y]) - 1 ? $gx : $gx + 1, $y, $x < length($map[$y]) - 1 ? $x + 1 : 0, $depth + 1];
    push @queue, [$gy, $x > 0 ? $gx : $gx - 1, $y, $x > 0 ? $x - 1 : length($map[$y]) - 1, $depth + 1];
}

my $delta2 = $totals{2 * $full_width + $half_width} - 2 * $totals{$full_width + $half_width} + $totals{$half_width};
my $delta = $totals{$full_width + $half_width} - $totals{$half_width} - $delta2;
my $row = $totals{$half_width};

for (my $i = $half_width; $i < $STEPS; $i += $full_width) {
    $delta += $delta2;
    $row += $delta;
}

print "$row\n";
