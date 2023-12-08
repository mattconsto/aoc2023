#!/usr/bin/env perl

use strict;
use warnings;

my @lr;
my %network;
while (<STDIN>) {
    chomp;
    push @lr, map {$_ eq 'R' ? 1 : 0} split //, $1 if /^\s*([LR]+)\s*$/;
    $network{$1} = [$2, $3] if /^\s*(\w+)\s*=\s*\(\s*(\w+)\s*,\s*(\w+)\s*\)\s*$/;
}

my $steps = 0;
my $node = 'AAA';
for (my $i = 0; $node && $node ne 'ZZZ'; $i = ($i + 1) % scalar @lr) {
    $node = $network{$node}->[$lr[$i]];
    $steps += 1;
}

print "$steps\n";