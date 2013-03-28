#!/usr/bin/perl
use strict;
use warnings;
use DBD::SQLite;
use DBI;
use feature 'say';
use lib '/home/toshi/perl/lib';
use Pause;
use HashDump;

my $database = 'test.db';

my $dbinfo =  get_dbinfo($database);

$dbinfo = create_SQL_statement($dbinfo);


pause;
my $record = get_record($database, $dbinfo);
HashDump->load($record);


sub get_dbinfo {
	my $database = shift;
	my $data_source = "dbi:SQLite:dbname=$database";
	my $dbh = DBI->connect($data_source);
	my $statement = "select * from dbinfo";
	my $res = $dbh->selectall_arrayref($statement);

	my %hash;
	for my $var (@$res ){
		my $table = $var->[0];
		my $ids =		$var->[1];
		$hash{$table} = { tablename => $table,ids => $ids };
	}
	return \%hash;
}



sub get_record {
	my $database = shift;
	my $dbinfo = shift;
	my $SQLstatement = $dbinfo->{current_sql_statement};
	my $data_source = "dbi:SQLite:dbname=$database";
	my $dbh = DBI->connect($data_source);
	my $records = $dbh->selectall_arrayref($SQLstatement);	
	return $record;
}

sub create_SQL_statement {
	my $dbinfo = shift;

	my $compose_where_statement =  sub  {
		my $dbinfo = shift;
		my $default_table = $dbinfo->{current_work_table};
		say $default_table;
		my $default_table_ids = $dbinfo->{$default_table}->{ids};
		say "you can use :$default_table_ids";
		my $query = type('create where statement');
		my $statement = sprintf("WHERE %s", $query);
		say $statement;
		return $statement;
	};

	$dbinfo  =  compose_select_statement($dbinfo);
	my $where_statement  = execute($compose_where_statement, $dbinfo);
	my $SQLstatement ='';

	if ($where_statement) {
		my  $ids = $dbinfo->{current_select_statement}->{ids};
		my 	$default_table = $dbinfo->{current_select_statement}->{default_table};
		my	$order_id = $dbinfo->{current_select_statement}->{order_id};
		my	$order_by = $dbinfo->{current_select_statement}->{order_by};
		my	$limit = $dbinfo->{current_select_statement}->{limit};

		$SQLstatement = sprintf("SELECT %s FROM %s %s ORDER by %s %s LIMIT %s",
		$ids, $default_table, $where_statement, $order_id, $order_by, $limit);
		say $SQLstatement;
	}else{
		$SQLstatement = 	$dbinfo->{current_select_statement}->{statement};
		say $SQLstatement;
	}
	$dbinfo->{current_sql_statement} = $SQLstatement;
	return $dbinfo;
}


sub compose_select_statement {
	my $dbinfo = shift;
	my @tables = keys %$dbinfo;
	say "choice default table";
	my $default_table = choice2(@tables);

	my @default_table_ids = split(",",$dbinfo->{$default_table}->{ids});
	unshift @default_table_ids, '*';

	say "select id's from $default_table";
#	say @default_table_ids;
	my @ids = select(@default_table_ids);
	my $ids = join(",",@ids);
	say $ids;
	say '';

	say "order id's from $default_table";
#	say @default_table_ids;
	my  $order_id = choice2(@default_table_ids);
	say "";

	say "order '$order_id' by ASC? DESC?";
	my @order_by =('ASC', 'DESC');
	my $order_by = choice2(@order_by);
	say "";

	say "how many records?";
	my $limit = typenum('input number');
	say"";

  my $statement = sprintf("SELECT %s FROM %s ORDER BY %s %s LIMIT %d"	, $ids, $default_table, $order_id, $order_by,$limit);
	$dbinfo->{current_work_table} = $default_table;
	$dbinfo->{current_select_statement} = {
		statement => $statement,
		ids => $ids,
		default_table => $default_table,
		order_id => $order_id,
		order_by => $order_by,
		limit => $limit,
	};
	return $dbinfo;
}

#todo add "DISTINCT", Statement history  stored in DB
