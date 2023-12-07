#!/usr/bin/env perl

use strict;
use warnings;

my %map = (
    'A' => 0xd,
    'K' => 0xc,
    'Q' => 0xb,
    'T' => 0xa,
    '9' => 0x9,
    '8' => 0x8,
    '7' => 0x7,
    '6' => 0x6,
    '5' => 0x5,
    '4' => 0x4,
    '3' => 0x3,
    '2' => 0x2,
    'J' => 0x1,
);

sub evaluate_hand {
    my ($hand) = @_;
    my @split  = split //, $hand;
    my $sorted = join '', sort {$map{$b} <=> $map{$a}} @split;

    my $score;
    if ($sorted =~ /^(.)(?:\1|J)(?:\1|J)(?:\1|J)(?:\1|J)$/) {
        # Five of a kind
        $score = 0x7;
    } elsif ($sorted =~ /^.*(.).*(?:\1|J).*(?:\1|J).*(?:\1|J).*$/) {
        # Four of a kind
        $score = 0x6;
    } elsif ($sorted =~ /^(?:(.)\1\1(.)\2|(.)\3(.)\4\4|(.)\5(.)\6J)$/) {
        # Full House, two Jokers make Four of a kind
        $score = 0x5;
    } elsif ($sorted =~ /^.*(.).*(?:\1|J).*(?:\1|J).*$/) {
        # Three of a kind
        $score = 0x4;
    } elsif ($sorted =~ /^.*(.).*\1.*(.).*\2.*$/) {
        # Two pair, a single Joker makes Three of a kind
        $score = 0x3;
    } elsif ($sorted =~ /^.*(.).*(?:\1|J).*$/) {
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
    my $rank = $i + 1;
    my $prize = $hands[$i]->[1] * $rank;
    # print "$hands[$i]->[0]\t$rank * $hands[$i]->[1]\t=\t$prize\t$hands[$i]->[2]\n";
    $score += $prize;
}
print "$score\n";