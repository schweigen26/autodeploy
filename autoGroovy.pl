#!/usr/bin/perl
use strict;

my $oper = $ARGV[0];
my $logfile = "tmp.log";
my $exitcode ;

if($oper eq "install"){
	&install();
}elsif($oper eq "uninstall"){
	&uninstall();
}else{
	 print "the parameter is [ install  or  uninstall ]\n";
	`exit 0`;
}

sub install {
	print "Install Groovy-binary-2.3.3\n";
	`tar -zxvf soft/groovy-2.3.3.tar.gz`;
	$exitcode = $?;
	`/bin/cp -rf groovy-2.3.3 /root`;
#	my $env = `cat /etc/profile | grep groovy | wc -l`;
#	if($env == 0){
#		&writeEnv();
#	}	
	`rm -rf groovy-2.3.3/`;
	if($exitcode == 0){
	print "Successfully install groovy\n";
	}
}

sub uninstall {
	print "Uninstall Groovy .\n";
	`rm -rf /root/groovy-2.3.3`;
	print "Successfully Uninstall groovy .\n";
}

sub writeEnv{
	my $fh ;
	open $fh, ">> /etc/profile" ;
	print $fh "\n"."GROOVY_HOME=/root/groovy-2.3.3";
	print $fh "\n"."export PATH=\$GROOVY_HOME/bin:\$PATH";
	close $fh;
	`source /etc/profile`;
	`env`;
}
