#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw(first min pairmap uniq);

my %all_maps;
my $mode;
my @seeds;
while (<STDIN>) {
    chomp;
    if (/^seeds\s*:\s*(.*)/) {
        @seeds = split /\s+/, $1;
    } elsif (/^(\w+)-to-\w+\smap\s*:/) {
        $mode = $1;
    } elsif ($mode && /^(\d+)\s+(\d+)\s+(\d+)/) {
        push @{$all_maps{$mode}}, [$1, $2, $3];
    } elsif (!/^\s*$/) {
        die "Unimplemented: '$_'";
    }
}

my %next_category = (
    seed        => 'soil',
    soil        => 'fertilizer',
    fertilizer  => 'water',
    water       => 'light',
    light       => 'temperature',
    temperature => 'humidity',
    humidity    => 'location',
);

my $min_location = ~0;
for (my $i = 0; $i < scalar @seeds; $i += 2) {
    print "$i $min_location\n";
    my $limit = $seeds[$i] + $seeds[$i + 1];
    for (my $seed = $seeds[$i]; $seed < $limit; $seed++) {
        my $category = 'seed';
        my $value = $seed;

        while ($category) {
            my $min_mapped = ~0;
            for my $map (@{$all_maps{$category}}) {
                my $delta = $value - $map->[1];
                if ($delta >= 0 && $delta < $map->[2]) {
                    my $mapped = $map->[0] + $delta;
                    $min_mapped = $mapped if $mapped < $min_mapped;
                }
            }
            $value = $min_mapped if $min_mapped != ~0;

            $category = $next_category{$category};
            if (!$category) {
                $min_location = $value if $value < $min_location;
            }
        }
    }
}

print $min_location;