#!/usr/bin/env perl

use strict;
use warnings;

my %workflows;
my @parts;
while (<STDIN>) {
    chomp;

    $workflows{$1} = [map {[split /\s*:\s*|\b/, $_]} split /\s*,\s*/, $2]
        if /^\s*(\w+)\s*\{\s*(.+)\s*\}\s*$/;

    push @parts, {x => $1, m => $2, a => $3, s => $4}
        if /^\s*\{\s*x\s*=\s*(\d+)\s*,\s*m\s*=\s*(\d+)\s*,\s*a\s*=\s*(\d+)\s*,\s*s\s*=\s*(\d+)\s*\}\s*$/;
}

my $combos = 0;
my @queue = ({
    wf   => 'in',
    x_min => 1, x_max => 4000,
    m_min => 1, m_max => 4000,
    a_min => 1, a_max => 4000,
    s_min => 1, s_max => 4000,
});
while (my $item = shift @queue) {
    if ($item->{wf} eq 'A') {
        $combos += ($item->{x_max} - $item->{x_min} + 1) *
                   ($item->{m_max} - $item->{m_min} + 1) *
                   ($item->{a_max} - $item->{a_min} + 1) *
                   ($item->{s_max} - $item->{s_min} + 1);
    } elsif ($item->{wf} ne 'R') {
        for my $rule (@{$workflows{$item->{wf}}}) {
            if (scalar @$rule == 1) {
                push @queue, {%$item, wf => $rule->[0]};
            } else {
                my ($var, $cond, $val, $res) = @$rule;
                if ($cond eq '>') {
                    push @queue, {%$item, wf => $res, "${var}_min" => $val + 1};
                    $item->{"${var}_max"} = $val;
                } elsif ($cond eq '<') {
                    push @queue, {%$item, wf => $res, "${var}_max" => $val - 1};
                    $item->{"${var}_min"} = $val;
                }
            }
        }
    }
}
print "$combos\n";
