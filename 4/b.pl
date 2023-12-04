#!/usr/bin/env perl

use strict;
use warnings;

use Array::Utils qw(intersect);

my %copies;
my $total = 0;
while (<STDIN>) {
    chomp;
    my ($card, $winning, $having) = /^Card\s*(\d+)\s*:\s*(.*)\s*\|\s*(.*)\s*$/;
    my @winning = split /\s+/, $winning;
    my @having  = split /\s+/, $having;
    for (my $i = 1; $i <= scalar intersect(@winning, @having); $i++) {
        $copies{$card + $i} += 1 + ($copies{$card} // 0);
    }
    $total += 1 + ($copies{$card} // 0);
}
print "$total\n";
