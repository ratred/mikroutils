#!/usr/bin/env perl

# Simple mikrotik admin tool ##


use strict;
use Getopt::Long qw (GetOptions);
my $mikrotik_user = 'admin';


GetOptions(
	'user|u=s'  => \$mikrotik_user,
	'copyid=s'  => \&copyid,
	'getconfig' => \&getconfig,
	'putconfig=s' => \&putconfig,
) or usage();


sub copyid {
	my $scr = shift;
	my $login = shift;
	my $mikrotik = @ARGV[0] or usage();

	upload("~/.ssh/id_rsa.pub");
	cmd("");

}

sub getconfig {
	my $mikrotik = @ARGV[0] or usage();
	my ($identity) = cmd('/system identity print') =~ /name: (\w*)/;
	my $result = cmd("/export compact file=flash/$identity.rsc");
	download("flash/$identity.rsc", ".")
}

sub putconfig {
	my $mikrotik = @ARGV[0] or usage();
	my $script = shift;
	my $config = shift or usage();
	my ($config_file) = $config =~ /([\w\_\.\-]+)$/;
	upload ($config, "flash/$config_file");
	cmd ("system reset-configuration no-defaults=yes skip-backup=yes run-after-reset=flash/$config_file")
}

sub cmd {
	my $mikrotik = @ARGV[0] or usage();
	my $cmd = shift;
	my $cmd = "ssh $mikrotik_user\@$mikrotik '$cmd'";
	return `$cmd`;
}

sub upload {
	my $mikrotik = @ARGV[0] or usage();
	my $from = shift;
	my $to = shift;
	my $cmd = "scp $from $mikrotik_user\@$mikrotik:$to";
	print $cmd;
	return `$cmd`;
}


sub download {
	my $mikrotik = @ARGV[0] or usage();
	my $from = shift;
	my $to = shift;
	my $cmd = "scp $mikrotik_user\@$mikrotik:$from $to";
	return `$cmd`;
}



#	user add name=oleg group=full

sub usage {
	print "Usage\n";
	exit;
}
