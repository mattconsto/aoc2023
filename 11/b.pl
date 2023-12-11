#!/usr/bin/env perl

use strict;
use warnings;

use Const::Fast qw(const);
use List::Util qw(max min none sum0);
use POSIX qw(abs);

const my $INFLATION => 1_000_000;

my @image;
while (<STDIN>) {
    chomp;
    push @image, [split //];
}

# Find empty rows
my @empty_ys;
for (my $y = 0; $y < scalar @image; $y++) {
    if (none {$_ eq '#'} @{$image[$y]}) {
        push @empty_ys, $y;
    }
}

# Again
my @empty_xs;
for (my $x = 0; $x < scalar @{$image[0]}; $x++) {
    if (none {$_ eq '#'} map {$_->[$x]} @image) {
        push @empty_xs, $x;
    }
}

# Find galaxies
my @galaxies;
for (my $y = 0; $y < scalar @image; $y++) {
    for (my $x = 0; $x < scalar @{$image[0]}; $x++) {
        push @galaxies, ([$y, $x]) if $image[$y][$x] eq '#';
    }
}

# Calculate distances
my @distances;
for (my $g1 = 0; $g1 < scalar @galaxies; $g1++) {
    for (my $g2 = $g1 + 1; $g2 < scalar @galaxies; $g2++) {
        my $y1 = $galaxies[$g1][0];
        my $y2 = $galaxies[$g2][0];
        my $x1 = $galaxies[$g1][1];
        my $x2 = $galaxies[$g2][1];
        push @distances, (
            abs($y1 - $y2) +
            (scalar grep {$_ > min($y1, $y2) && $_ < max($y1, $y2)} @empty_ys) * ($INFLATION - 1) +
            abs($x1 - $x2) +
            (scalar grep {$_ > min($x1, $x2) && $_ < max($x1, $x2)} @empty_xs) * ($INFLATION - 1)
        );
    }
}

print sum0(@distances) . "\n";
