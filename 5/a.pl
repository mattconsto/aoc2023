#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw(first min);

my %all_maps;
my $mode;
my @seeds;
while (<STDIN>) {
    chomp;
    if (/^seeds\s*:\s*(.*)/) {
        @seeds = split /\s+/, $1;
    } elsif (/^(\S+)\smap\s*:/) {
        $mode = $1;
    } elsif ($mode && /^(\d+)\s+(\d+)\s+(\d+)/) {
        push @{$all_maps{$mode}}, {d => $1, s => $2, len => $3};
    } elsif (!/^\s*$/) {
        die "Unimplemented: '$_'";
    }
}

my @locations;
for my $seed (@seeds) {
    my $category = 'seed';
    my $value = $seed;

    while ($category) {
        my $maps_key = first {/^$category-to-/} keys %all_maps;

        if ($maps_key) {
            my $maps = $all_maps{$maps_key};

            my @mapped;
            for my $map (@$maps) {
                my $delta = $value - $map->{s};
                if ($delta >= 0 && $delta < $map->{len}) {
                    push @mapped, $map->{d} + $delta;
                }
            }
            $value = min @mapped if @mapped;

            $category = $maps_key =~ /^$category-to-(\S+)/ ? $1 : undef;
        } else {
            push @locations, $value;
            $category = undef;
        }
    }
}

print min @locations;