use common::sense;
use Function::Parameters;
use MetaCPAN::Client;
use Module::CoreList;
use Config;
use File::Spec::Functions;
use PAR::Repository;

my $client = MetaCPAN::Client->new();

my %visited;

my $repo = new PAR::Repository (path => catfile('PARs', 'runtime', 'runtime'));

fun go($releaseName) {
	my $release = $client->release($releaseName);
	my $releaseVersion = $release->version;

	my $parFile = catfile
		( $ENV{USERPROFILE}
		, ".cpanplus"
		, $Config{version}
		, 'dist/PAR'
		, "$releaseName-$releaseVersion-$Config{archname}-$Config{version}.par"
		);
	if (-r $parFile) {
		print "Injecting $parFile\n";
		$repo->inject(file => $parFile);	
		unlink $parFile;
	};
	return $release;
};

fun check($releaseName) {

	my $release = go $releaseName;
	foreach my $x (@{$release->dependency})
	{
		next if $x->{phase} ne 'runtime';
		next if $x->{relationship} ne 'requires';
		next if Module::CoreList::is_core($x->{module});

		my $module = $x->{module};
		next if $module eq 'perl';
		my $distribution = $client->module($module)->{data}->{distribution};
		next if exists $visited{$distribution};
		$visited{$distribution} = undef;
		# print "$releaseName -> $distribution\n";
		check $distribution;
	};
};

foreach (@ARGV) {
	check($_);
};
