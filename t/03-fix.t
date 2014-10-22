use strict;
use warnings;
use Test::More;

use Catmandu;
use Catmandu::Fix;
use Catmandu::Importer::MAB2;

my $fixer = Catmandu::Fix->new(fixes => [
	'mab_map("LDR", "leader")',
	'mab_map("001", "id")',
	'mab_map("004", "date")',
	'mab_map("406[b]j", "coverage")',
	'remove_field("record")',
	'remove_field("_id")']);
my $importer = Catmandu::Importer::MAB2->new(file => "./t/mab2.dat", type=> "RAW");
my $records = $fixer->fix($importer)->to_array();

ok( $records->[0]->{'leader'} eq '02020nM2.01200024      h', 'fix leader' );
ok( $records->[0]->{'id'} eq '47918-4', 'fix id' );
ok( $records->[0]->{'date'} eq '20110211', 'fix date' );
ok( $records->[0]->{'coverage'} eq '1983', 'fix coverage' );
is_deeply( $records->[0], {'id' => '47918-4', 'date' => '20110211', 'coverage' => '1983', 'leader' => '02020nM2.01200024      h'}, 'fix record');

done_testing;