#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long 'GetOptions';
use lib '/home/toshi/perl/lib';
use Pause;

#for LTSV log format

my %opts;

GetOptions( \%opts, qw( find=s log=s help ) );

my @items = @ARGV;

if ($opts{help}) {
	die "usage: loganalyze.pl --f=WORD --l=LOGNAME (items..){ID TIME etc...}";
}

my $word = $opts{find} || undef;

my $finding_word;
if (defined($word)) {
  $finding_word = qr/$word/;
}else{
	$finding_word =  undef;
}

my $log_file = $opts{log} || '/var/log/apache2/access.log';

die "Can't access $log_file, Check the file name" unless -e $log_file;

print "log: $log_file\n";
print "find word: $word\n" if $word;
if (@items){
	print "items: ";
	for (@items) {
		print "$_ ";
	}
	print "\n";
}

my @select=('print', 'data output');
my $select=choice2(@select);

if ($select eq 'print') {
	my @choice = ('monitor', 'text');
	my $choice = choice2(@choice);
	if ( $choice eq 'text') {
		my $output_file = type('type output filename');
		printout($log_file, $output_file);
	}else{
		printout($log_file);
	}
}else{
	my @outputdata = dataoutput($log_file);
	my @format = qw/JSON XML YAML/;
	my $choice = choice2(@format);	

	my $output_file = type('type output filename');
	my $dataformat = DataFormat->new;
	$dataformat->$choice(\@outputdata,$output_file);
}

sub printout {
	my $log_file = shift;
	my $output_file = shift || undef;

	if ($output_file) {
		open STDOUT, '>', $output_file;
	}

	open my $fh, '<', $log_file;

	while (my $line= <$fh>){
		chomp $line;
		if ($finding_word){
			if (($line =~ /$finding_word/ ) and (@items)){
				$line = filter($line);
				print $line ."\n";
			}elsif ($line =~ /$finding_word/ ) {
				print $line ."\n";
			}else{
				next;
			}
		}else{
			if (@items) {
				$line = filter($line);
				print $line ."\n";
			}else{
				print $line ."\n";
			}
		}
	}
	close $fh;
	close STDOUT;
}

sub dataoutput {
	my $file_name = shift;
	open my $fh, '<', $file_name;
	my @outputdata;

	while (my $line= <$fh>){
		chomp $line;
		if ($finding_word){
			if (($line =~ /$finding_word/ ) and (@items)){
				$line = filterd($line);
				push @outputdata, $line;
			}elsif ($line =~ /$finding_word/ ) {
				$line = nonfilterd($line);
				push @outputdata, $line;
			}else{
				next;
			}
		}else{
			if (@items) {
				$line = filterd($line);
				push @outputdata, $line;
			}else{
				$line = nonfilterd($line);
				push @outputdata, $line;
			}
		}
	}
	return @outputdata;
}

sub filter {
	my $line = shift;
	my %hash = map { split( /:/, $_, 2 )} split(/\t/, $line);
	my @tmpoutput;
	foreach (@items){
		push @tmpoutput, "$_:$hash{$_}" if exists($hash{$_});
	}
	$line = join ("\t", @tmpoutput);
	return $line;
}
 
sub filterd {
	my $line = shift;
	my %hash = map { split( /:/, $_, 2 )} split(/\t/, $line);
	my %newhash;	
	foreach (@items){
		$newhash{$_} = $hash{$_} if exists($hash{$_});
	}
	return \%newhash;
}

sub nonfilterd {
	my $line = shift;
	my %hash = map { split( /:/, $_, 2 )} split(/\t/, $line);
	return \%hash;
}

package DataFormat {
	sub new {
		my $self = {};
		bless $self, shift;
		return $self;
	}
		
	sub XML {
		use XML::Simple;
		my $self = shift;
		my $outputdata = shift;
		my $output_file = shift;
		open my $fh, '>', $output_file;
		print $fh 	XMLout($outputdata);
		close $fh;
	}
	sub JSON {
		use JSON;
		my $self = shift;
		my $outputdata = shift;
		my $output_file = shift;
		open my $fh, '>', $output_file;
		print $fh encode_json($outputdata);
		close $fh;
	}
	sub YAML {
		use YAML;
		my $self = shift;
		my $outputdata = shift;
		my $output_file = shift;
		YAML::DumpFile($output_file, $outputdata);
	}
}





