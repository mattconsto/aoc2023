#!/usr/bin/env perl

use strict;
use warnings;

use Array::Utils qw(intersect);
use List::Util qw(max);
use POSIX qw(floor);

my $total = 0;
while (<STDIN>) {
    chomp;
    my ($card, $winning, $having) = /^Card\s*(\d+)\s*:\s*(.*)\s*\|\s*(.*)\s*$/;
    my @winning = split /\s+/, $winning;
    my @having  = split /\s+/, $having;
    $total += max(0, floor(2 ** (scalar intersect(@winning, @having) - 1)));
}
print "$total\n";
