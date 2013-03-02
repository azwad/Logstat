#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long 'GetOptions';
use File::Tail;
#for LTSV log format

my %opts;

GetOptions( \%opts, qw( find=s log=s ) );

my @items = @ARGV;

my $word = $opts{find} || undef;

my $finding_word;
if (defined($word)) {
  $finding_word = qr/$word/;
}else{
	$finding_word =  undef;
}

my $file_name = $opts{log} || '/var/log/apache2/access.log';

die "Can't access $file_name, Check the file name" unless -e $file_name;


my $file = File::Tail->new(
		name => $file_name,
		maxinterval => 1,
		adjustafter	=> 10,
);

print "log: $file_name\n";
print "find word: $word\n" if $word;
if (@items){
	print "items: ";
	for (@items) {
		print "$_ ";
	}
	print "\n";
}

while (defined(my $line=$file->read)){
		if ($finding_word){
			if (($line =~ /$finding_word/ ) and (@items)){
				filter($line);
			}elsif ($line =~ /$finding_word/ ) {
				print $line ."\n";
			}else{
				next;
			}
		}else{
			if (@items) {
				filter($line);
			}else{
				print $line ."\n";
			}
		}
}

sub filter {
	my $line = shift;
	my %hash = map { split( /:/, $_, 2 )} split(/\t/, $line);
	foreach (@items){
		print "$_:$hash{$_}\t"if exists($hash{$_})
	}
	print "\n";
}
 

