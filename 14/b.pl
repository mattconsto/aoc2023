#!/usr/bin/env perl

use strict;
use warnings;

use Const::Fast;

const my $MAXIMUM_ITERATIONS => 1_000_000_000;

my @map;
while (<STDIN>) {
    chomp;
    push @map, $1 if /^\s*([O#\.]+)\s*$/;
}

my @weights;
my $width = length $map[0];
my $height = scalar @map;
for (my $i = 0; $i < $MAXIMUM_ITERATIONS; $i++) {
    for (my $j = 0; $j < 4; $j++) {
        # Tilt the board
        for (my $x = 0; $x < $width; $x++) {
            my $rounded = 0;
            my $start = 0;
            for (my $y = 0; $y < $height; $y++) {
                if (substr($map[$y], $x, 1) eq 'O') {
                    $rounded++;
                } elsif (substr($map[$y], $x, 1) eq '#') {
                    for (my $k = $start; $k < $y; $k++) {
                        substr($map[$k], $x, 1, ($k - $start) < $rounded ? 'O' : '.');
                    }
                    $rounded = 0;
                    $start = $y + 1;
                }
            }

            if ($rounded) {
                for (my $k = $start; $k < $height; $k++) {
                    substr($map[$k], $x, 1, ($k - $start) < $rounded ? 'O' : '.');
                }
                $rounded = 0;
            }
        }

        # Rotate the map
        my @new_map = @map;
        for (my $y = 0; $y < $height; $y++) {
            for (my $x = 0; $x < $width; $x++) {
                substr($new_map[$y], $x, 1, substr($map[$height - 1 - $x], $y, 1));
            }
        }
        @map = @new_map;
    }

    # Measure weights
    my $weight = 0;
    for (my $y = 0; $y < $height; $y++) {
        for (my $x = 0; $x < $width; $x++) {
            if (substr($map[$y], $x, 1) eq 'O') {
                $weight += $height - $y;
            }
        }
    }
    push @weights, $weight;

    # Let things settle
    if ($i > 1000) {
        # Find cycles
        for (my $loop_length = 1; $loop_length < int scalar @weights / 2; $loop_length++) {
            my $loop_found = 1;
            for (my $offset = 0; $offset < $loop_length; $offset++) {
                if ($weights[scalar @weights - 1 - $offset] != $weights[scalar @weights - 1 - $loop_length - $offset]) {
                    $loop_found = 0;
                    last;
                }
            }
            if ($loop_found) {
                print $weights[scalar @weights - 1 - ($loop_length - ($MAXIMUM_ITERATIONS - $i) % $loop_length) - 1] . "\n";
                exit;
            }
        }
    }
}
