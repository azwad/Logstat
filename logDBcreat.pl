#!/usr/bin/perl
use strict;
use warnings;
use DBD::SQLite;
use DBI;
use feature 'say';
use lib '/home/toshi/perl/lib';
use Pause;
use YAML::Syck;
use HashDump;

my $database = 'test.db';
my $table = 'accesslog';
my $accesslog_data = YAML::Syck::LoadFile('accesslog.yaml');
HashDump->load($accesslog_data);

my $uniq_id_file  = 'accesslog.yaml.uniq_id.dump';
my $id =  do $uniq_id_file;
my $id_str = join (",", @$id );
#pause;

unless ( -e $database ) {
	create_database($database, $id_str);
	sub create_database {
		my $database = shift;
		my $id_str = shift;

		say "create database: $database";

		my $data_source = "dbi:SQLite:dbname=$database";
		my $dbh = DBI->connect($data_source);
		my $sqlstatement = "CREATE TABLE $table ( $id_str )";
		say $sqlstatement;
		$dbh->do($sqlstatement);

		$sqlstatement = "CREATE TABLE dbinfo( tables ,ids )";
		say $sqlstatement;
		$dbh->do($sqlstatement);
		$sqlstatement = "INSERT INTO dbinfo ( tables, ids) VALUES( '$table', '$id_str' );";
		$dbh->do($sqlstatement);
		$sqlstatement = "INSERT INTO dbinfo ( tables, ids) VALUES( 'dbinfo', 'tables,ids' );";
		$dbh->do($sqlstatement);
	}
}

pause;

my $data_source = "dbi:SQLite:dbname=$database";
my $dbh = DBI->connect($data_source);


#pause;

for my $var (@$accesslog_data) {
	my @data;
	my	@id_str;
	for (@$id) {
		push @id_str, $_;
		say $_;
		push @data, $var->{$_};
		say $var->{$_};
#		pause;
	}
	my $id_str = join(",",@id_str);
	my $values_str = join(",",split('',"?" x ($#id_str + 1)));
	say $values_str;
#	pause;
	my $sqlstatement = "INSERT INTO $table ( $id_str ) VALUES( $values_str );";
	say $sqlstatement;
	say @data;
	my $sth = $dbh->prepare($sqlstatement);
	$sth->execute (@data);
}





