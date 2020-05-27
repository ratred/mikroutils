#!/usr/bin/env perl

# Simple mikrotik admin tool ##


use strict;
use Getopt::Long qw (GetOptions);

my $verbose = 0;
my $outfile = '.';


GetOptions(
	'verbose|v'   => \$verbose,
	'out|o=s'     => \$outfile,
	'copyid=s'    => \&copyid,
	'admpass=s'   => \&admpass,
	'getconfig'   => \&getconfig,
); 

usage();


sub copyid {
	my $scr = shift;
	my $login = shift;

	print "Uploading id_rsa.pub\n" if ($verbose); 
	my $result = upload("~/.ssh/id_rsa.pub", "flash/". $login. "_rsa.pub");
	print "$result\n" if ($verbose); 
	print "Add user $login" if ($verbose);
	my $result = cmd("/user add name=$login group=full");
	print "$result\n" if ($verbose); 
	print "Import key\n" if ($verbose);
	my $result = cmd("/user ssh-keys import user=$login public-key-file=flash/" . $login . "_rsa.pub");
	print "$result\n" if ($verbose); 
	exit;
}

sub getconfig {
	print "Check mikrotik identity" if ($verbose);
	my ($identity) = cmd('/system identity print') =~ /name: (\w*)/;
	print "Mikrotik identity as $identity to $outfile" if ($verbose);
	my $result = cmd("/export compact file=flash/$identity.rsc");
	download("flash/$identity.rsc", "$outfile");
	exit;
}

sub putconfig {
	my $script = shift;
	my $config = shift or usage();
	my ($config_file) = $config =~ /([\w\_\.\-]+)$/;
	upload ($config, "flash/$config_file");
	cmd ("system reset-configuration no-defaults=yes skip-backup=yes run-after-reset=flash/$config_file");
	exit;
}

sub admpass {
	my $script = shift;
	my $password = shift or usage();
	cmd ("user set admin password=$password");
	exit;
}


sub cmd {
	my ($mikrotik, $mikrotik_user) = parseaddr();
	my $cmd = shift;
	my $ssh = "ssh -o StrictHostKeyChecking=no -q $mikrotik_user\@$mikrotik '$cmd'";
	print "Execute $ssh\n" if ($verbose);
	return qx/$ssh 2>&1/;
}

sub upload {
	my ($mikrotik, $mikrotik_user) = parseaddr();
	my $from = shift;
	my $to = shift;
	my $scp = "scp -o StrictHostKeyChecking=no -q $from $mikrotik_user\@$mikrotik:$to";
	print "Execute $scp\n" if ($verbose);
	return qx/$scp 2>&1/;
}


sub download {
	my ($mikrotik, $mikrotik_user) = parseaddr();
	my $from = shift;
	my $to = shift;
	my $scp = "scp -o StrictHostKeyChecking=no -q $mikrotik_user\@$mikrotik:$from $to";
	print "Execute $scp\n" if ($verbose);
	return qx/$scp 2>&1/;
}


sub parseaddr {
	my $mikrotik = @ARGV[0] or usage();
	my $mikrotik_user = getlogin || getpwuid($<);
	if ($mikrotik =~ /(.+)\@(.+)/) {
		$mikrotik_user = $1;
		$mikrotik = $2;		
	}
	return ($mikrotik, $mikrotik_user);


}

sub usage {
	print "Usage\n";
	exit;
}
