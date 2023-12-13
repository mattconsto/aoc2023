#!/usr/bin/env perl

use strict;
use warnings;

my $valid = 0;
while (<STDIN>) {
    chomp;
    my ($springs, $groups) = /^\s*([#\.\?]+)\s+([\d,]+)\s*$/;
    my @springs = split //, $springs;

    my @arrangements = (
        ($springs[0] eq '.' || $springs[0] eq '#') ? ([$springs[0]]) : (['.'], ['#']) 
    );
    for (my $i = 1; $i < scalar @springs; $i++) {
        if ($springs[$i] eq '.' || $springs[$i] eq '#') {
            @arrangements = map {[@$_, $springs[$i]]} @arrangements;
        } elsif ($springs[$i] eq '?') {
            @arrangements = map {[@$_, '.'], [@$_, '#']} @arrangements;
        } else {
            die "Unimplemented!";
        }
    }

    for (my $i = 0; $i < scalar @arrangements; $i++) {
        my $found = join ',', map {length} grep {$_} split /\.+/, join '', @{$arrangements[$i]};
        $valid += 1 if $groups eq $found;
    }
    print "$valid\n";
}
