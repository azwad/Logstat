#!/usr/bin/perl
use strict;
use warnings;
use YAML::Syck;
use feature 'say';
use lib '/home/toshi/perl/lib';
use Pause;
use Data::Dumper;

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


my @select = qw/txt dump/;
my $select = choice2(@select);

my $outputfile = "$file.uniq_id.$select";
open my $fh, '>>', $outputfile or die;

if ($select eq 'txt') {
	for (@id) {
	 	print $fh "$_\n";
	}
}else{	
	print $fh Dumper(\@id);
}
close $fh;

		
	


