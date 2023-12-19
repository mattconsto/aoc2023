#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw(sum0);

my %workflows;
my @parts;
while (<STDIN>) {
    chomp;

    $workflows{$1} = [map {[split /\s*:\s*|\b/, $_]} split /\s*,\s*/, $2]
        if /^\s*(\w+)\s*\{\s*(.+)\s*\}\s*$/;

    push @parts, {x => $1, m => $2, a => $3, s => $4}
        if /^\s*\{\s*x\s*=\s*(\d+)\s*,\s*m\s*=\s*(\d+)\s*,\s*a\s*=\s*(\d+)\s*,\s*s\s*=\s*(\d+)\s*\}\s*$/;
}

my $total = 0;
for my $part (@parts) {
    my $pos = 'in';

    while (exists $workflows{$pos}) {
        for my $rule (@{$workflows{$pos}}) {
            if (scalar @$rule == 1) {
                $pos = $rule->[0];
            } else {
                my ($var, $cond, $val, $res) = @$rule;
                if (
                    ($cond eq '>' && $part->{$var} > $val) ||
                    ($cond eq '<' && $part->{$var} < $val)
                ) {
                    $pos = $res;
                    last;
                }
            }
        }
    }

    $total += sum0(values %$part) if $pos eq 'A';
}

print "$total\n";