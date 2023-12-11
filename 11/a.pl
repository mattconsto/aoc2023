#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw(none sum0);
use POSIX qw(abs);

my @image;
while (<STDIN>) {
    chomp;
    push @image, [split //];
}

# Expand space
for (my $y = 0; $y < scalar @image; $y++) {
    if (none {$_ eq '#'} @{$image[$y]}) {
        splice @image, $y, 0, [('.') x scalar @{$image[$y]}];
        $y++;
    }
}

# Again
for (my $x = 0; $x < scalar @{$image[0]}; $x++) {
    if (none {$_ eq '#'} map {$_->[$x]} @image) {
        for (my $y = 0; $y < scalar @image; $y++) {
            splice @{$image[$y]}, $x, 0, ('.');
        }
        $x++;
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
        push @distances, (
            abs($galaxies[$g1][0] - $galaxies[$g2][0]) +
            abs($galaxies[$g1][1] - $galaxies[$g2][1])
        );
    }
}

print sum0(@distances) . "\n";
