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
	exit(0);
}


sub install{
	print "Install JDK .\n";
	&installJDK();
}
sub uninstall{
	print "Uninstall JDK .\n";
	&unInstallJDK();	
	print "Successfully Uninstall JDK .\n";
}

sub installJDK{
	`rpm -Uvh soft/jdk-11.0.7_linux-x64_bin.rpm`;
	`/usr/java/jdk-11.0.7/bin/jlink  --module-path /usr/java/jdk-11.0.7/jmods/ --add-modules java.desktop --output /usr/java/jdk-11.0.7/jre`;
	`rpm -Uvh soft/jdk-8u131-linux-x64.rpm`;
	$exitcode = $?;
	if($exitcode == 0){
		 print "Successfully Install JDK . \n";
	}else{
	print "Failed Install JDK . \n";
	}
}

sub writeEnv {
	my $fh ;
	open $fh , ">> /etc/profile ";
	print $fh "\n"."JAVA_HOME=/usr/java/jdk-11.0.7\n";
	print $fh "export JRE_HOME=/usr/java/jdk-11.0.7/jre\n";
	print $fh "export CLASSPATH=\$JAVA_HOME/lib:\$JRE_HOME/lib:\$CLASSPATH\n";
	print $fh "export PATH=\$JAVA_HOME/bin:\$JAR_HOME/bin:\$PATH\n";
	print $fh "ulimit -u 10240\n";
	print $fh "ulimit -n 10240\n";
	print $fh "ulimit -c unlimited\n";
	close $fh;
	`source /etc/profile`;
	`env`;
}

sub unInstallJDK{
	my $rpm = "rpm -qa | grep -i jdk-11.0.7-11.0.7-ga.x86_64";
	&log(`$rpm`);
	open(H,"$logfile");
	while($rpm=<H>){
		print "$rpm\Removing\n";
		my $line = "rpm -ev $rpm ";
		`$line`;
	}
	close H;	 	
}

sub log{
	my $fh ;
	my($line) = @_ ;
	open $fh,">$logfile";
	print $fh "$line";
	close $fh ;
}
