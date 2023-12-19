#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw(max min);

my @instructions;
while (<STDIN>) {
    chomp;
    my ($dir, $len, $color) = /^\s*([URDL])\s*(\d+)\s*\(\s*#\s*([0-9a-f]+)\s*\)\s*$/;
    push @instructions, [$dir, $len, $color];
}

my %grid;
my $x = 0;
my $y = 0;
my $min_x = ~0;
my $max_x = -~0;
my $min_y = ~0;
my $max_y = -~0;
for my $instruction (@instructions) {
    my ($dir, $len, $color) = @$instruction;

    for (my $i = 0; $i < ($dir eq 'L' || $dir eq 'R' ? $len : 0); $i++) {
        $x += $dir eq 'L' ? -1 : $dir eq 'R' ? +1 : 0;
        $min_x = min($min_x, $x);
        $max_x = max($max_x, $x);
        $grid{$y}{$x} = 1;
    }

    for (my $i = 0; $i < ($dir eq 'U' || $dir eq 'D' ? $len : 0); $i++) {
        $y += $dir eq 'U' ? -1 : $dir eq 'D' ? +1 : 0;
        $min_y = min($min_y, $y);
        $max_y = max($max_y, $y);
        $grid{$y}{$x} = 1;
    }
}

my @queue = ([1, 1]);
while (my $place = shift @queue) {
    next if $grid{$place->[0]}{$place->[1]};
    push @queue, [$place->[0] - 1, $place->[1]];
    push @queue, [$place->[0], $place->[1] + 1];
    push @queue, [$place->[0] + 1, $place->[1]];
    push @queue, [$place->[0], $place->[1] - 1];
    $grid{$place->[0]}{$place->[1]} = 1;
}

my $total = 0;
for (my $y = $min_y - 1; $y <= $max_y + 1; $y++) {
    for (my $x = $min_x - 1; $x <= $max_x + 1; $x++) {
        $total += 1 if $grid{$y}{$x};
        print exists $grid{$y}{$x} && $grid{$y}{$x} ? '#' : '.';
    }
    print "\n";
}
print "$total\n";
