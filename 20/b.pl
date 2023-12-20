#!/usr/bin/env perl

use strict;
use warnings;

use List::PriorityQueue;
use List::Util qw(any all product);

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

# Find inputs to rx
my %cycles = ('rx' => undef);
while (scalar keys %cycles == 1) {
    %cycles = map {$_ => undef} grep {any {exists $cycles{$_}} @{$modules{$_}[1]}} keys %modules;
}

# Continue until all cycles are found
my %state;
for (my $i = 1; any {!defined} values %cycles; $i++) {
    my $queue = List::PriorityQueue->new;
    $queue->insert(['button', '', 'low', 0], 0);
    while (my ($name, $source, $pulse, $priority) = @{$queue->pop || []}) {
        next unless exists $modules{$name};
        my ($type, $dests) = @{$modules{$name}};

        if ($name eq 'rx') {
            print "$i, $name, $pulse\n";
            exit if $pulse eq 'low';
        }

        if ($type eq '%' && $pulse eq 'low') {
            $state{$name} = !$state{$name};
            for my $dest (@$dests) {
                my $new_pulse = $state{$name} ? 'high' : 'low';
                $queue->insert([$dest, $name, $new_pulse, $priority + 1], $priority + 1);
            }
        } elsif ($type eq '&') {
            $state{$name}{$source} = $pulse;
            for my $dest (@$dests) {
                my $new_pulse = (all {$_ eq 'high'} map {$state{$name}{$_} // 'low'} @{$inputs{$name}}) ? 'low' : 'high';
                $cycles{$name} = $i if exists $cycles{$name} && $new_pulse eq 'high';
                $queue->insert([$dest, $name, $new_pulse, $priority + 1], $priority + 1);
            }
        } elsif (!$type) {
            for my $dest (@$dests) {
                $queue->insert([$dest, $name, $pulse, $priority + 1], $priority + 1);
            }
        }
    }
}

print product(values %cycles) . "\n";
