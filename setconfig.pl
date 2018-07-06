use warnings;
use strict;
use CPANPLUS::Configure;

my $conf = CPANPLUS::Configure->new();
$conf->set_conf(dist_type => 'CPANPLUS::Dist::PAR');
$conf->set_conf(prereqs => 1);
$conf->save();
