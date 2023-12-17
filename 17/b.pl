#!/usr/bin/env perl

use strict;
use warnings;

use List::PriorityQueue;
use List::Util qw(min);

my @map;
while (<STDIN>) {
    chomp;
    push @map, $1 if /^\s*(\d+)\s*$/;
}

my $queue = List::PriorityQueue->new;
$queue->insert({
    path => '',
    dir  => '?',
    len  => 0,
    loss => 0,
    x    => 0,
    y    => 0,
}, 0);
my %seen;
while (my %node = %{$queue->pop || {}}) {
    next if $node{x} < 0 || $node{y} < 0 || $node{x} > length($map[$node{y}]) - 1 || $node{y} > scalar @map - 1;

    next if $seen{$node{y}}{$node{x}}{$node{len}}{$node{dir}} && $seen{$node{y}}{$node{x}}{$node{len}}{$node{dir}} <= $node{loss};
    $seen{$node{y}}{$node{x}}{$node{len}}{$node{dir}} = $node{loss};

    # print "$node{x}, $node{y} = $node{loss}\n";
    if ($node{y} == scalar @map - 1 && $node{x} eq length($map[$node{y}]) - 1) {
        print "$node{loss}\n";
        print "$node{path}\n";
        last;
    }

    if ($node{y} > 0 && (!$node{dir} || ($node{dir} ne 's' && ($node{dir} !~ /^[ew]$/ || $node{len} > 3) && ($node{dir} ne 'n' || $node{len} < 10)))) {
        $queue->insert({
            path => $node{path} . '^',
            dir  => 'n',
            len  => $node{dir} && $node{dir} eq 'n' ? $node{len} + 1 : 1,
            loss => $node{loss} + int(substr($map[$node{y} - 1], $node{x}, 1)),
            x    => $node{x},
            y    => $node{y} - 1
        }, $node{loss} + int(substr($map[$node{y} - 1], $node{x}, 1)));
    }

    if ($node{x} < length($map[$node{y}]) - 1 && (!$node{dir} || ($node{dir} ne 'w' && ($node{dir} !~ /^[ns]$/ || $node{len} > 3) && ($node{dir} ne 'e' || $node{len} < 10)))) {
        $queue->insert({
            path => $node{path} . '>',
            dir  => 'e',
            len  => $node{dir} && $node{dir} eq 'e' ? $node{len} + 1 : 1,
            loss => $node{loss} + int(substr($map[$node{y}], $node{x} + 1, 1)),
            x    => $node{x} + 1,
            y    => $node{y},
        }, $node{loss} + int(substr($map[$node{y}], $node{x} + 1, 1)));
    }

    if ($node{y} < scalar @map - 1 && (!$node{dir} || ($node{dir} ne 'n' && ($node{dir} !~ /^[ew]$/ || $node{len} > 3) && ($node{dir} ne 's' || $node{len} < 10)))) {
        $queue->insert({
            path => $node{path} . 'v',
            dir  => 's',
            len  => $node{dir} && $node{dir} eq 's' ? $node{len} + 1 : 1,
            loss => $node{loss} + int(substr($map[$node{y} + 1], $node{x}, 1)),
            x    => $node{x},
            y    => $node{y} + 1,
        }, $node{loss} + int(substr($map[$node{y} + 1], $node{x}, 1)));
    }

    if ($node{x} > 0 && (!$node{dir} || ($node{dir} ne 'e' && ($node{dir} !~ /^[ns]$/ || $node{len} > 3) && ($node{dir} ne 'w' || $node{len} < 10)))) {
        $queue->insert({
            path => $node{path} . '<',
            dir  => 'w',
            len  => $node{dir} && $node{dir} eq 'w' ? $node{len} + 1 : 1,
            loss => $node{loss} + int(substr($map[$node{y}], $node{x} - 1, 1)),
            x    => $node{x} - 1,
            y    => $node{y},
        }, $node{loss} + int(substr($map[$node{y}], $node{x} - 1, 1)));
    }
}

# for (my $y = 0; $y < scalar @map; $y++) {
#     for (my $x = 0; $x < length $map[$y]; $x++) {
#         print sprintf '%3d ', min(~0, values %{$seen{$y}{$x}});
#     }
#     print "\n";
# }
