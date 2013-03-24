#!/usr/bin/perl
use strict;
use warnings;
use YAML::Syck;
use feature 'say';

my $file = shift @ARGV;
die "usage: get_id_name.pl FILE.YAML" unless $file;
say "id  from $file";

my $yaml = YAML::Syck::LoadFile($file);

my %hash;
for my $var (@$yaml) {
	my @array = keys %$var;
	for (@array) {
		$hash{$_} += 1;
	}
}

my @id = keys %hash;

my $outputfile = "$file.id_uniq.txt";
open my $fh, '>>', $outputfile or die;

for (@id) {
 	print $fh "$_\n";
}


