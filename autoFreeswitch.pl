#!/usr/bin/perl
use strict;


my $vCommon = "freeswitch -version";
my $exitcode;
my $orgVersion =`$vCommon`;
my $version ;
my $oper = $ARGV[0];
my $logfile = "tmp.log";
if($oper eq "install"){
	print "Install FreeSWITCH ... \n";
	&install();
}elsif($oper eq "uninstall"){
	&unInstallFreeSWITCH();
}else{
	print "the parameter is [ install  or  uninstall ]\n";
        exit(0);
}

sub install {
 if($orgVersion =~ /FreeSWITCH version: (.*)/) 
 {
	$version = $1 ;
	print "FreeSWITCH version is $version is already installed\n" ;
	}
	else{
       	print "Install FreeSWITCH or not?(Y/N):" ;
	my $orNot = <STDIN>;
	$orNot = lc($orNot);
	chomp($orNot);
	if($orNot eq 'y')
        {
        &installFreeSWITCH();
	}
	else{
	print "Notihing to do!";
	}
	}
 }


sub unInstallFreeSWITCH{
	print "THIS OPTION WILL UNINSTALL FreeSWITCH,CONTINUE OR NOT ? (Y/N): ";
	my $orNot = <STDIN>;
	$orNot = lc($orNot);
	chomp($orNot);
	if($orNot eq "y"){
		my $rpm = `rpm -qa|grep -iE "freeswitch"`;
		&log($rpm);
		open(H,"$logfile");
		while($rpm=<H>){
			print "$rpm\Removing\n";
			my $line = "rpm -ev --nodeps $rpm";
			`$line`;
			$exitcode = $?;
			if($exitcode != 0){
			exit(0);
			print "Failed Uinstall FreeSWITCH.\n";
			}
		}
		close H;
	}
	else{
		print "Do Nothing!\n";
	}
}




sub installFreeSWITCH{
        `tar -xzvf soft/FreeSWITCH/freeswitch.tar.gz -C soft/FreeSWITCH/`;

        print "Installing...\n";
	my $rpm =  "rpm -ivh soft/FreeSWITCH/freeswitch/*.rpm --force";
        `$rpm`;
#	$exitcode = $?; 
#	sleep(3)
#	if($exitcode == 0){
#	}
	my $status = `ps -ef | grep freeswitch | grep -v grep |wc -l`;
	if($status == 0){
	`freeswitch -nc -nonat`;
	}
        &writeAutoStart();
	print "Successfully Install FreeSWITCH.\n";
}



sub writeAutoStart{
        my $start = `cat /etc/rc.local | grep freeswitch|wc -l`;
        if($start == 0){
        my $fh ;
        open $fh, ">> /etc/rc.local" ;
        print $fh "freeswitch -nc -nonat\n";
        close $fh;
        }
}
