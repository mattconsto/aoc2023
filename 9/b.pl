#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw(any);

sub prev_value {
    my (@input) = @_;

    my @firsts;
    while (any {$_} @input) {
        push @firsts, $input[0];
        for (my $i = 0; $i < scalar @input - 1; $i++) {
            $input[$i] = $input[$i + 1] - $input[$i];
        }
        pop @input;
    }

    my $prev = 0;
    for (my $i = scalar @firsts - 1; $i >= 0; $i--) {
        $prev = $firsts[$i] - $prev;
    }

    return $prev;
}

my $total = 0;
while (<STDIN>) {
    chomp;
    $total += prev_value(split /\s+/, s/^\s+|\s+$//gr) . "\n";
}
print "$total\n";
