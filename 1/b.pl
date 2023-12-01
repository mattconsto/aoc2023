#!/usr/bin/env perl

use strict;
use warnings;

my %edits = (
    one   => 1,
    two   => 2,
    three => 3,
    four  => 4,
    five  => 5,
    six   => 6,
    seven => 7,
    eight => 8,
    nine  => 9,
);

my $total;
while (<STDIN>) {
    chomp;
    my ($first) = s/(@{[join '|', keys %edits]})/$edits{$1}/gir =~ /^\D*(\d)/;
    my ($last)  = (scalar reverse) =~ s/(@{[join '|', map {scalar reverse} keys %edits]})/$edits{scalar reverse $1}/gir =~ /^\D*(\d)/;
    $total += "$first$last";
}
print "$total\n";
