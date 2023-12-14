#!/usr/bin/env perl

use strict;
use warnings;

my @map;
while (<STDIN>) {
    chomp;
    push @map, [split //, $1] if /^\s*([O#\.]+)\s*$/;
}

for (my $x = 0; $x < scalar @{$map[0]}; $x++) {
    my $rounded = 0;
    my $start = 0;
    for (my $y = 0; $y < scalar @map; $y++) {
        if ($map[$y][$x] eq 'O') {
            $rounded++;
        } elsif ($map[$y][$x] eq '#') {
            for (my $i = $start; $i < $y; $i++) {
                $map[$i][$x] = ($i - $start) < $rounded ? 'O' : '.';
            }
            $rounded = 0;
            $start = $y + 1;
        } elsif ($map[$y][$x] eq '.') {
            # Do nothing
        } else {
            die "Unimplemented!";
        }
    }

    if ($rounded) {
        for (my $i = $start; $i < scalar @map; $i++) {
            $map[$i][$x] = ($i - $start) < $rounded ? 'O' : '.';
        }
        $rounded = 0;
    }
}

my $weight = 0;
for (my $y = 0; $y < scalar @map; $y++) {
    for (my $x = 0; $x < scalar @{$map[$y]}; $x++) {
        if ($map[$y][$x] eq 'O') {
            $weight += scalar @map - $y;
        }
    }
}
print "$weight\n";
