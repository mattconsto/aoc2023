#!/usr/bin/env perl

use strict;
use warnings;

use List::MoreUtils qw(pairwise);
use List::Util qw(product);
use POSIX qw(ceil floor);

my $eps = 1e-10;

my @times;
my @distances;
while (<STDIN>) {
    chomp;
    @times = join '', split /\s+/, $1 if /^\s*Time\s*:\s*(.*)/;
    @distances = join '', split /\s+/, $1 if /^\s*Distance\s*:\s*(.*)/;
}

print product(pairwise {floor(($a + sqrt($a**2 - 4*$b)) / 2 - $eps) - ceil(($a - sqrt($a**2 - 4*$b)) / 2 + $eps) + 1} @times, @distances) . "\n";