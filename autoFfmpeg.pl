#!/usr/bin/perl
use strict;

my $oper = $ARGV[0];

if($oper eq "install"){
	&install();
}elsif($oper eq "uninstall"){
	&uninstall();
}else{
	print "Parameter is [install or uninstall]\n";
	exit(0);
}

sub install {
	print "Install FFmpeg .\n";
	`/bin/cp -rf soft/ffmpeg /usr/local/bin/`;
	print "Successfully Install FFmpeg .\n";
}

sub uninstall{
	print "Uninstall FFmpeg .\n";
#	`rm -rf /usr/local/bin/ffmpeg`;
#	`rm -rf /lib64/libz.so.1`;

	print "Successfully Uninstall FFMpeg .\n";
}
