#!/usr/bin/env perl

use strict;
use warnings;

my @steps;
while (<STDIN>) {
    chomp;
    @steps = split /,/;
}

sub hash {
    my ($input) = @_;
    my $value = 0;
    for (my $i = 0; $i < length $input; $i++) {
        $value = (($value + ord(substr($input, $i, 1))) * 17) % 256;
    }
    return $value;
}

my @boxes;
for my $step (@steps) {
    if ($step =~ /^(\w+)=(\d+)$/) {
        my $found = 0;
        for (my $i = 0; $i < scalar @{$boxes[hash($1)] // []}; $i++) {
            if ($boxes[hash($1)][$i][0] eq $1) {
                $boxes[hash($1)][$i][1] = $2;
                $found = 1;
                last;
            }
        }
        push @{$boxes[hash($1)]}, [$1, $2] unless $found;
    } elsif ($step =~ /^(\w+)-$/) {
        $boxes[hash($1)] = [grep {$_->[0] ne $1} @{$boxes[hash($1)]}];
    }
}

my $total = 0;
for (my $i = 0; $i < scalar @boxes; $i++) {
    for (my $j = 0; $j < scalar @{$boxes[$i] // []}; $j++) {
        $total += ($i + 1) * ($j + 1) * $boxes[$i][$j][1];
    }
}
print "$total\n";
