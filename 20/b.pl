#!/usr/bin/env perl

use strict;
use warnings;

my $total;
while (<STDIN>) {
    chomp;
    my ($first) = /^\D*(\d)/;
    my ($last)  = /(\d)\D*$/;
    $total += "$first$last";
}
print "$total\n";
