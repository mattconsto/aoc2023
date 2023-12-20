#!/usr/bin/env perl

use strict;
use warnings;

use List::PriorityQueue;
use List::Util qw(all);

my %inputs;
my %modules = (button => ['', ['broadcaster']]);
while (<STDIN>) {
    chomp;
    if (/^\s*([%&]?)\s*(\w+)\s*->\s*([\w,\s]+)\s*$/) {
        my @split = split /\s*,\s*/, $3;
        $modules{$2} = [$1, [@split]];
        push @{$inputs{$_}}, $2 for @split;
    }
}

my %state;
my %counts = (high => 0, low => 0);
for (my $i = 1; $i <= 1000; $i++) {
    my $queue = List::PriorityQueue->new;
    $queue->insert(['button', '', 'low', 0], 0);
    while (my ($name, $source, $pulse, $priority) = @{$queue->pop || []}) {
        next unless exists $modules{$name};
        my ($type, $dests) = @{$modules{$name}};

        if ($type eq '%' && $pulse eq 'low') {
            $state{$name} = !$state{$name};
            for my $dest (@$dests) {
                my $new_pulse = $state{$name} ? 'high' : 'low';
                $queue->insert([$dest, $name, $new_pulse, $priority + 1], $priority + 1);
                $counts{$new_pulse}++;
            }
        } elsif ($type eq '&') {
            $state{$name}{$source} = $pulse;
            for my $dest (@$dests) {
                my $new_pulse = (all {$_ eq 'high'} map {$state{$name}{$_} // 'low'} @{$inputs{$name}}) ? 'low' : 'high';
                $queue->insert([$dest, $name, $new_pulse, $priority + 1], $priority + 1);
                $counts{$new_pulse}++;
            }
        } elsif (!$type) {
            for my $dest (@$dests) {
                $queue->insert([$dest, $name, $pulse, $priority + 1], $priority + 1);
                $counts{$pulse}++;
            }
        }
    }
}

print $counts{high} * $counts{low} . "\n";
