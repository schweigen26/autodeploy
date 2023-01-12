#!/usr/bin/perl
use strict;


my $vCommon = "psql -V";
my $exitcode;
my $orgVersion =`$vCommon`;
my $version ;
my $oper = $ARGV[0];
my $logfile = "tmp.log";
if($oper eq "install"){
	print "Install PostgreSQL ... \n";
	&install();
}elsif($oper eq "uninstall"){
	&unInstallpsql();
}else{
	print "the parameter is [ install  or  uninstall ]\n";
        exit(0);
}

sub install {
 if($orgVersion =~ /(.*)\(PostgreSQL\) (.*)/) 
 {
	$version = $2 ;
	print "PostgreSQL version is $version is already installed\n" ;
	}
	else{
       	print "Install PostgreSQL 10 or not?(Y/N):" ;
	my $orNot = <STDIN>;
	$orNot = lc($orNot);
	chomp($orNot);
	if($orNot eq 'y')
        {
        &installpsql();
	}
	else{
	print "Notihing to do!";
	}
	}
 }


sub unInstallpsql{
	print "THIS OPTION WILL UNINSTALL PostgreSQL,CONTINUE OR NOT ? (Y/N): ";
	my $orNot = <STDIN>;
	$orNot = lc($orNot);
	chomp($orNot);
	if($orNot eq "y"){
		my $rpm = `rpm -qa|grep -iE "postgresql10"`;
		&log($rpm);
		open(H,"$logfile");
		while($rpm=<H>){
			print "$rpm\Removing\n";
			my $line = "rpm -ev --nodeps $rpm";
			`$line`;
			$exitcode = $?;
			if($exitcode != 0){
			exit(0);
			print "Failed Uinstall PostgreSQL.\n";
			}
		}
		close H;
	}
	else{
		print "Do Nothing!\n";
	}
}




sub installpsql{
        `tar -xvf soft/pgsql/postgresql.tar -C soft/pgsql/`;
        my $libspath = "soft/pgsql/postgresql10-libs-10.19-1PGDG.rhel7.x86_64.rpm";
        my $commonpath = "soft/pgsql/postgresql10-10.19-1PGDG.rhel7.x86_64.rpm";
        my $serverpath = "soft/pgsql/postgresql10-server-10.19-1PGDG.rhel7.x86_64.rpm";

        print "Installing...\n";
	my $rpm =  "rpm -ivh $libspath";
        `$rpm`;
        my $rpm =  "rpm -ivh $commonpath";
        `$rpm`;
        $rpm = "rpm -ivh $serverpath";
        `$rpm`;
#	$exitcode = $?; 
#	sleep(3)
#	if($exitcode == 0){
	my $init="cd /usr/pgsql-10 && sudo -u postgres /usr/pgsql-10/bin/initdb -D /var/lib/pgsql/10/data";
	`$init`;
#	}

#	my $init=`cd /usr/pgsql-10 && sudo -u postgres /usr/pgsql-10/bin/initdb -D /var/lib/pgsql/10/data`;
	&writePgCnf();
	my $status = `ps -ef | grep pgsql | grep -v grep |wc -l`;
	if($status == 0){
	`systemctl start postgresql-10`;
	}
        &writeAutoStart();
	print "Successfully Install PostgreSQL 10\n";
}



sub writePgCnf{
        my $hbapath = "/var/lib/pgsql/10/data/pg_hba.conf";
        my $cnfpath = "/var/lib/pgsql/10/data/postgresql.conf";
#	chomp($cnfpath);
	print "Init pgsql Cnf .. \n";
#	`sed -i "/# IPv4 local connections/a\host    all             all             0.0.0.0/0            trust" $hbapath`;
	my $trust=`sed -i "/# IPv4 local connections/a\host    all             all             0.0.0.0/0            trust" /var/lib/pgsql/10/data/pg_hba.conf`;
#       `sed -i \"sed -i \"/\# IPv4 local connections/a\\host    all             all             0.0.0.0/0            trust\" $cnfpath`;
	`sed -i \"s#max_connections =.*#max_connections = 1000#\" $cnfpath`;
	`sed -i \"s\/\^\#\\\(listen\_addresses \=.*\\)\/listen\_addresses \= \\\'*\\'\/\" $cnfpath`;

}



sub writeAutoStart{
        my $start = `cat /etc/rc.local | grep postgresql|wc -l`;
        if($start == 0){
        my $fh ;
        open $fh, ">> /etc/rc.local" ;
        print $fh "service postgresql-10 start\n";
        close $fh;
        }
}
