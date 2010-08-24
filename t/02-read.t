use Test::More; 

my $template =
{ qw/ 001 RecordID /
, 200 => { qw/ a title f authorDisplay /} 
, 600 => [ Author => {qw/ 2 as a lastname b firstname c title d /} ]
}
