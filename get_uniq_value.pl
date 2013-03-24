#!/usr/bin/perl
use strict;
use warnings;
use YAML::Syck;
use feature 'say';

my $file = shift @ARGV;
my $id = shift;

die "usage: get_uniq_value.pl FILE.YAML ID" unless ($file and $id );

say "unification value of id '$id' from $file";

my $yaml = YAML::Syck::LoadFile($file);

my @keys;
for my $var (@$yaml) {
	push @keys, $var->{$id};
}
my %hash;

for (@keys) {
	$hash{$_} += 1;
}
my $outputfile = "${id}_uniq.txt";
open my $fh, '>>', $outputfile or die;

for (sort { $hash{$b} <=> $hash{$a}} keys %hash) {
 	print $fh "$_\n";
}


