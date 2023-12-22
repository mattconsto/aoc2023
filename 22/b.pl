#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw(any all none);

my @bricks;
while (<STDIN>) {
    chomp;
    push @bricks, [[$1, $2, $3], [$4, $5, $6]]
        if /^\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*~\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*$/;
}

my %collisions;
my %supports;
while (1) {
    # Avoid comparing each brick against each brick
    my %occupied;
    for (my $i = 0; $i < scalar @bricks; $i++) {
        my @brick = @{$bricks[$i]};

        for (my $x = $brick[0][0]; $x <= $brick[1][0]; $x++) {
            for (my $y = $brick[0][1]; $y <= $brick[1][1]; $y++) {
                for (my $z = $brick[0][2]; $z <= $brick[1][2]; $z++) {
                    $occupied{$z}{$y}{$x} = $i;
                }
            }
        }
    }

    # Simulate gravity
    my $moved = 0;
    for (my $i = 0; $i < scalar @bricks; $i++) {
        my @brick = @{$bricks[$i]};

        my $dz = 0;
        my $collided = 0;
        while (!$collided) {
            my $potential_dz = $dz - 1;
            for (my $x = $brick[0][0]; $x <= $brick[1][0]; $x++) {
                for (my $y = $brick[0][1]; $y <= $brick[1][1]; $y++) {
                    for (my $z = $brick[0][2]; $z <= $brick[1][2]; $z++) {
                        if ($z + $potential_dz < 1 || (
                            (exists $occupied{$z + $potential_dz}{$y}{$x} &&
                            $occupied{$z + $potential_dz}{$y}{$x} != $i)
                        )) {
                            $collided = 1;
                            $collisions{$i}{$occupied{$z + $potential_dz}{$y}{$x} // 'floor'} = 1;
                            $supports{$occupied{$z + $potential_dz}{$y}{$x} // 'floor'}{$i} = 1;
                        }
                    }
                }
            }
            $dz = $potential_dz unless $collided;
        }

        # We have moved
        if ($dz) {
            $brick[0][2] += $dz;
            $brick[1][2] += $dz;
            $moved = 1;
        }
    }
    if ($moved) {
        %collisions = ();
        %supports = ();
    } else {
        last;
    }
}

my $total = 0;
for (my $i = 0; $i < scalar @bricks; $i++) {
    for (my $j = 0; $j < scalar @bricks; $j++) {
        $total++ unless $i == $j || is_reachable(\%supports, 'floor', $j, $i);
    }
}
print "$total\n";

sub is_reachable {
    my ($graph, $source, $dest, $ignore) = @_;

    return 0 if $source eq $ignore || $dest eq $ignore;

    my @queue = ($source);
    my %seen;
    while (@queue) {
        my $key = shift @queue;
        next if $seen{$key} || $key eq $ignore;
        return 1 if $key eq $dest;
        push @queue, keys %{$graph->{$key}};
        $seen{$key} = 1;
    }

    return 0;
}
