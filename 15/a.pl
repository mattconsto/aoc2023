#!/usr/bin/env perl

use strict;
use warnings;

my @steps;
while (<STDIN>) {
    chomp;
    @steps = split /,/;
}

my $total = 0;
for my $step (@steps) {
    my $value = 0;
    for (my $i = 0; $i < length $step; $i++) {
        $value = (($value + ord(substr($step, $i, 1))) * 17) % 256;
    }
    $total += $value;
}
print "$total\n";
