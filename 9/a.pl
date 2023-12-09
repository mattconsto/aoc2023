#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw(any sum0);

sub next_value {
    my (@input) = @_;

    my @lasts;
    while (any {$_} @input) {
        for (my $i = 0; $i < scalar @input - 1; $i++) {
            $input[$i] = $input[$i + 1] - $input[$i];
        }
        push @lasts, pop @input;
    }

    return sum0 @lasts;
}

my $total = 0;
while (<STDIN>) {
    chomp;
    $total += next_value(split /\s+/, s/^\s+|\s+$//gr) . "\n";
}
print "$total\n";
