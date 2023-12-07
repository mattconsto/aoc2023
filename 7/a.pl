#!/usr/bin/env perl

use strict;
use warnings;

my %map = (
    'A' => 0xd,
    'K' => 0xc,
    'Q' => 0xb,
    'J' => 0xa,
    'T' => 0x9,
    '9' => 0x8,
    '8' => 0x7,
    '7' => 0x6,
    '6' => 0x5,
    '5' => 0x4,
    '4' => 0x3,
    '3' => 0x2,
    '2' => 0x1,
);

sub evaluate_hand {
    my ($hand) = @_;
    my @split  = split //, $hand;
    my $sorted = join '', sort {$map{$b} <=> $map{$a}} @split;

    my $score;
    if ($hand =~ /^(.)\1\1\1\1$/) {
        # Five of a kind
        $score = 0x7;
    } elsif ($sorted =~ /^.*(.).*\1.*\1.*\1.*$/) {
        # Four of a kind
        $score = 0x6;
    } elsif ($sorted =~ /^(?:(.)\1\1(.)\2|(.)\3(.)\4\4)$/) {
        # Full House
        $score = 0x5;
    } elsif ($sorted =~ /^.*(.).*\1.*\1.*$/) {
        # Three of a kind
        $score = 0x4;
    } elsif ($sorted =~ /^.*(.).*\1.*(.).*\2.*$/) {
        # Two pair
        $score = 0x3;
    } elsif ($sorted =~ /^.*(.).*\1.*$/) {
        # One pair
        $score = 0x2;
    } else {
        # High card
        $score = 0x1;
    }

    return ($score << 20) + ($map{$split[0]} << 16) + ($map{$split[1]} << 12) + ($map{$split[2]} << 8) + ($map{$split[3]} << 4) + ($map{$split[4]} << 0);
}

my @hands;
while (<STDIN>) {
    chomp;
    my ($hand, $bid) = /^(\w+)\s+(\d+)$/;
    push @hands, [$hand, $bid, evaluate_hand($hand)];
}

@hands = sort {$a->[2] <=> $b->[2]} @hands;
my $score = 0;
for (my $i = 0; $i < scalar @hands; $i++) {
    $score += $hands[$i]->[1] * ($i + 1);
}
print "$score\n";