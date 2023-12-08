#!/usr/bin/env perl

use strict;
use warnings;

use Math::Utils qw(lcm);

my @lr;
my %network;
while (<STDIN>) {
    chomp;
    push @lr, map {$_ eq 'R' ? 1 : 0} split //, $1 if /^\s*([LR]+)\s*$/;
    $network{$1} = [$2, $3] if /^\s*(\w+)\s*=\s*\(\s*(\w+)\s*,\s*(\w+)\s*\)\s*$/;
}

my @all_steps;
for my $starting_node (sort grep {/A$/} keys %network) {
    my $steps = 0;
    my $node = $starting_node;
    for (my $i = 0; $node && $node !~ /Z$/; $i = ($i + 1) % scalar @lr) {
        $node = $network{$node}->[$lr[$i]];
        $steps += 1;
    }

    print "$starting_node $steps\n";
    push @all_steps, $steps;
}

print lcm(@all_steps) . "\n";