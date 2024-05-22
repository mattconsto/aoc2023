#!/usr/bin/env perl

use strict;
use warnings;

use Const::Fast;
use List::Util qw(any sum);

const my $BROKEN  => '#';
const my $COMMA   => ',';
const my $MYSTERY => '?';
const my $WORKING => '.';

const my $UNFOLD  => 5;

my $total = 0;
while (<STDIN>) {
    chomp;
    my ($raw_springs, $raw_groups) = /^\s*(\S+)\s+((?:\d|\Q$COMMA\E)+)\s*$/;

    my @springs = split //, (join $MYSTERY, ($raw_springs) x $UNFOLD);
    my @groups  = split /\Q$COMMA\E/, (join $COMMA, ($raw_groups) x $UNFOLD);

    $total += count_combos(
        \my %cache,
        known_springs(\@springs, $BROKEN),
        find_starts(\@springs, @groups),
        0,
        -1,
    );
}
print "$total\n";

sub known_springs {
    my ($springs, $state) = @_;
    my @known;
    for (my $i = 0; $i < @$springs; $i++) {
        push @known, $i if $springs->[$i] eq $state;
    }
    return \@known;
}

sub find_starts {
    my ($springs, @groups) = @_;

    my @data;
    for (my $i = 0; $i < @groups; $i++) {
        my @potential_starts = (sum(@groups[0..$i - 1], 0) + $i)
            ..
            (@$springs-1 - sum(@groups[$i + 1..@groups-1], 0) - (@groups-1 - $i) - ($groups[$i] - 1));

        my @possible_starts;
        for my $start (@potential_starts) {
            # Avoid any preceded by a broken spring
            next if $start > 0 && $springs->[$start - 1] eq $BROKEN;

            # Avoid any followed by a broken spring
            next if $start + ($groups[$i]-1) < @$springs - 1 && $springs->[$start + 1 + ($groups[$i]-1)] eq $BROKEN;

            my $valid = 1;
            for (my $j = 0; $j < $groups[$i]; $j++) {
                # Avoid any containing a working spring
                if ($springs->[$start+$j] eq $WORKING) {
                    $valid = 0;
                    last;
                }
            }
            next unless $valid;
            push @possible_starts, $start;
        }

        push @data, {
            size   => $groups[$i],
            starts => \@possible_starts,
        };
    }

    return \@data;
}

sub count_combos {
    my ($cache, $broken, $groups, $g, $pos) = @_;

    my $cache_key = "$g:$pos";
    my $result = $cache->{$cache_key};

    if (!defined $result) {
        # Base case
        $result = 1 if $g >= @$groups;
    }

    if (!defined $result) {
        my $total = 0;
        for my $start (@{$groups->[$g]->{starts}}) {
            # Avoid any we have already passed
            next unless $start > $pos;

            # Avoid any that skip over a known broken spring
            next if @$broken && any {$_ > $pos && $_ < $start} @$broken;

            # Avoid any last start position that leaves a broken spring unaccounted for
            next if $g == @$groups - 1 && any {$_ > $start + $groups->[$g]->{size}} @$broken;

            # Recurse
            $total += count_combos($cache, $broken, $groups, $g + 1, $start + $groups->[$g]->{size});
        }

        $result = $total;
    }

    $cache->{$cache_key} = $result;
    return $result;
}
