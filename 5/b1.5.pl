#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw(first min pairmap uniq);

my %all_maps;
my $mode;
my @seeds;
my %next_category;
my %last_category;
while (<STDIN>) {
    chomp;
    if (/^seeds\s*:\s*(.*)/) {
        @seeds = split /\s+/, $1;
    } elsif (/^(\w+)-to-(\w+)\smap\s*:/) {
        $mode = $1;
        $next_category{$1} = $2;
        $last_category{$2} = $1;
    } elsif ($mode && /^(\d+)\s+(\d+)\s+(\d+)/) {
        push @{$all_maps{$mode}}, {
            s1 => $2,
            s2 => $2 + $3 - 1,
            d1 => $1,
            d2 => $1 + $3 - 1,
            l => $3,
        };
    } elsif (!/^\s*$/) {
        die "Unimplemented: '$_'";
    }
}

my @combined_map = @{$all_maps{humidity}};
warn Dumper(\@combined_map);
my $key = 'temperature';
while ($key) {
    print "$key\n";

    for (my $i = 0; $i < scalar @{$all_maps{$key}}; $i++) {
        my $i_map = $all_maps{$key}->[$i];
        next unless $i_map;

        my $original_length = scalar @combined_map;

        for (my $j = 0; $j < $original_length; $j++) {
            my $j_map = $combined_map[$j];
            next unless $j_map;

            if (
                $i_map->{s2} < $j_map->{s1} ||
                $i_map->{s1} > $j_map->{s2}
            ) {
                # do nothing
            } elsif (
                $i_map->{s1} <= $j_map->{s1} &&
                $i_map->{s2} >= $j_map->{s2}
            ) {
                $combined_map[$j] = undef;
            } elsif (
                $i_map->{s1} > $j_map->{s1} &&
                $i_map->{s2} >= $j_map->{s2}
            ) {
                my $len1 = ($i_map->{s1} - 1) - $j_map->{s1};
                push @combined_map, {
                    s1 => $j_map->{s1},
                    s2 => $i_map->{s1} - 1,
                    d1 => $j_map->{d1},
                    d2 => $j_map->{d1} + $len1 - 1,
                    w => "$key: a $i $j/$original_length",
                };
                $combined_map[$j] = undef;
            } elsif (
                $i_map->{s1} <= $j_map->{s1} &&
                $i_map->{s2} < $j_map->{s2}
            ) {
                my $len2 = $j_map->{s2} - ($i_map->{s2} + 1);
                push @combined_map, {
                    s1 => $i_map->{s2} + 1,
                    s2 => $j_map->{s2},
                    d1 => $j_map->{d2} - $len2,
                    d2 => $j_map->{d2},
                    w => "$key: b $i $j/$original_length",
                };
                $combined_map[$j] = undef;
            } elsif (
                $i_map->{s1} > $j_map->{s1} &&
                $i_map->{s2} < $j_map->{s2}
            ) {
                my $len1 = ($i_map->{s1} - 1) - $j_map->{s1};
                push @combined_map, {
                    s1 => $j_map->{s1},
                    s2 => $i_map->{s1} - 1,
                    d1 => $j_map->{d1},
                    d2 => $j_map->{d1} + $len1 - 1,
                    w => "$key: c $i $j/$original_length",
                };
                my $len2 = $j_map->{s2} - ($i_map->{s2} + 1);
                push @combined_map, {
                    s1 => $i_map->{s2} + 1,
                    s2 => $j_map->{s2},
                    d1 => $j_map->{d2} - $len2,
                    d2 => $j_map->{d2},
                    w => "$key: d $i $j/$original_length",
                };
                $combined_map[$j] = undef;
            } else {
                die "Unexpected!";
            }
        }

        @combined_map = grep {defined} @combined_map;
    }

    @combined_map = (@{$all_maps{$key}}, @combined_map);
    warn Dumper(\@combined_map);

    last if $key eq 'light';
    $key = $last_category{$key};

}

use Data::Dumper;
# die Dumper(\@combined_map);

for my $seed (@seeds) {
    print "$seed\n";
    for my $item (@combined_map) {
        if ($item->{s1} <= $seed && $item->{s2} >= $seed) {
            my $mapped = $item->{d1} + ($seed - $item->{s1});
            print " $seed -> $mapped\n"; 
            # print Dumper $item;
        }
    }
}
