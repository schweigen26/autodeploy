#!/usr/bin/perl
use strict;


my $vCommon = "mysql -V";
my $exitcode;
my $orgVersion =`$vCommon`;
my $version ;
my $oper = $ARGV[0];
my $logfile = "tmp.log";
if($oper eq "install"){
	print "Install Mysql ... \n";
	&install();
}elsif($oper eq "uninstall"){
	&unInstallMysql();
}else{
	print "the parameter is [ install  or  uninstall ]\n";
        exit(0);
}

sub install {
 if($orgVersion =~ /(.*)Distrib (.*),(.*)/) 
 {
	$version = $2 ;
	if($version =~ /^5\.(.*)(.*)/)
	{
       	 print "MYSQL version is $version is already installed\n" ;
#	 &modifyPwd();
	}
	else{
       	print "MYSQL version is $version Not Support.Install MYSQL5.7 or not?(Y/N):" ;
	
	my $orNot = <STDIN>;
	$orNot = lc($orNot);
	chomp($orNot);
	if($orNot eq 'y')
	{
#		&unInstallMysql();
       	&installMysql();
	}
	else{
		print "WARN:You choose use current Mysql:$version\n";
	}
	}
 }
 else {
	print "WARN:Unknown MYSQL Version,Install MYSQL5.7 or not?(Y/N):";
	my $orNot = <STDIN>;
        $orNot = lc($orNot);
	chomp($orNot);
        if($orNot eq "y"){
#                &unInstallMysql();
                &installMysql();
        }
		else{
                print "WARN:You choose use current Mysql version:Unkown.\n";
        }
 } 
}
sub getVersion{
	$version = `mysql -V`;
	if($version =~ /(.*)Distrib (.*),(.*)/){
		$version = $2 ;	
		if($version =~ /^5\.(\d)\.(.*)/){
			$version = $1 ;
		}
	}
}

#uninstall mariadb
sub unInstallMariadb{
	my $rpm = `rpm -qa|grep -iE "mariadb"`;
	&log($rpm);
	open(H,"$logfile");
	while($rpm=<H>){
		print "$rpm\Removing\n";
		my $line = "rpm -ev --nodeps $rpm";
		`$line`;
		$exitcode = $?;
		if($exitcode != 0){
			exit(0);
			print "Failed Uinstall Mariadb.\n";
				}
		}
	close H;
}


#uninstall mysql
sub unInstallMysql{
	print "THIS OPTION WILL UNINSTALL MYSQL5.7,CONTINUE OR NOT ? (Y/N): ";
        my $orNot = <STDIN>;
        $orNot = lc($orNot);
        chomp($orNot);
        if($orNot eq "y"){                                      

#	my $process = `ps -ef | grep -v grep | grep mysql`;
#	&log($process);
#	open(H,"$logfile");
#	while($process=<H>){
#		if($process =~ /([a-zA-Z]*)\s*(\d*)\s*(.*)/){
#			`kill -9 $2`;
#		}
#	}
#	close H;

			my $rpm = `rpm -qa|grep -iE "mysql-community-server-5.7.36-1.el7.x86_64|mysql-community-client-5.7.36-1.el7.x86_64|mysql-community-common-5.7.36-1.el7.x86_64|mysql-community-devel-5.7.36-1.el7.x86_64|mysql-community-libs-compat-5.7.36-1.el7.x86_64|mysql-community-libs-5.7.36-1.el7.x86_64"`;
			&log($rpm);
			open(H,"$logfile");
			while($rpm=<H>){
				print "$rpm\Removing\n";
				my $line = "rpm -ev --nodeps $rpm";
				`$line`;
				$exitcode = $?;
				if($exitcode != 0){
					exit(0);
					print "Failed Uinstall Mysql.\n";
				}	
			}
			close H;

			&delFile();
			print "Successfully Uninstall Mysql . \n";
		}	
		else{
			print "Do Nothing!\n";
		}
}

sub delFile(){
	`rm -rf /var/lib/mysql`;
	`rm -rf /usr/share/mysql`;
	`rm -rf /usr/lib64/mysql`;
	`rm -rf /var/lock/subsys/mysql`;
	`rm -rf /etc/my.cnf`;
	`rm -rf /usr/my.cnf`;
	`rm -rf /var/log/mysqld.log`;	
}

#install mysql
sub installMysql{
	&unInstallMariadb();
	`tar -xvf soft/mysql/mysql-5.7.36-1.el7.x86_64.rpm-bundle.tar -C soft/mysql/`;
	my $commonpath = "soft/mysql/mysql-community-common-5.7.36-1.el7.x86_64.rpm";	
	my $libspath = "soft/mysql/mysql-community-libs-5.7.36-1.el7.x86_64.rpm";
	my $libs_compatpath = "soft/mysql/mysql-community-libs-compat-5.7.36-1.el7.x86_64.rpm";
	my $develpath = "soft/mysql/mysql-community-devel-5.7.36-1.el7.x86_64.rpm";
	my $serverpath = "soft/mysql/mysql-community-server-5.7.36-1.el7.x86_64.rpm";
	my $clientpath = "soft/mysql/mysql-community-client-5.7.36-1.el7.x86_64.rpm";

	print "install mysql-common\n";
        my $rpm =  "rpm -ivh $commonpath";
        `$rpm`;
	print "install mysql-libs\n";
        my $rpm =  "rpm -ivh $libspath";
        `$rpm`;
	print "install mysql-libs-compat\n";
        my $rpm =  "rpm -ivh $libs_compatpath";
        `$rpm`;
	print "install mysql-devel\n";
        my $rpm =  "rpm -ivh $develpath";
        `$rpm`;
	print "install mysql-client\n";
	my $rpm =  "rpm -ivh $clientpath";
	`$rpm`;
	print "install mysql-server\n";
	$rpm = "rpm -ivh $serverpath";
	`$rpm`;
	print "Successfully Install Mysql\n";
	
#	if((my $mysqlstatus = `ps -ef | grep mysql | grep -v | wc -l`) != 0){
		&modifyPwd();	
#	}else{
#		&modifyPwd();
#	}
}


sub modifyPwd {
	&getVersion();
	if($version == 7){
		&writeMyCnf7();

		my $status = `ps -ef | grep mysql | grep -v grep |wc -l`;
                if($status == 0){
			`service mysqld start`;
		}
		#try use default password	
		my $pwd = &findMysqlPwd();
               	my $login = "mysql -uroot -p'$pwd'";	
		print "********************************\nPlease Entry this SQL to Modify the Password :\t 'SET PASSWORD=PASSWORD('Pachira\@123');' , then Entry 'quit' Exit mysql to go on install.\n*******************************\n";
		my $loginrs = system($login);
                if( $loginrs == 0 ){
                	print "Successfully modify password \n";
                }else{
                	print "Cann't Login Mysql Use Default Password, Modify init password failed.\n";
               		print "!WARNING:Please entry the current password of your mysql:";
               		$pwd = <STDIN>;
               		chomp($pwd);
               		$loginrs= system("mysql -uroot -p'$pwd' -e \"SET PASSWORD= PASSWORD('Pachira@123')\"");
               		if($loginrs == 0){
               			print "Successfully modify password \n";
               		}else{
               			print "Sorry ,Cannot login mysql,Your password is wrong .";
               			print "Please modify password by yourself .\n";
               		}
    	           		print "Finished modify password.\n";
               	}	

	}
}

sub findMysqlPwd{
#	my $sqlPwd = `tail -n 2 /root/.mysql_secret`;
	my $sqlPwd = `grep 'temporary password' /var/log/mysqld.log|awk '{print \$11}'|tr -d '\n'`;
#	if($sqlPwd =~ /^#(.*):\s(.*)\n/){
#		print "Mysql init password is :*$2*,try use default password in mysql. \n";
#		return $2;
#	}
}

sub log{
	my $fh ;
	my($line) = @_ ;
	open $fh,">$logfile";
	print $fh "$line";
	close $fh ;
}


sub writeMyCnf7{
	my $cnfpath ;
	if($version == 7){
		$cnfpath = "/etc/my.cnf";
	}else{
		return ;
	}
	chomp($cnfpath); 
#	print "$cnfpath | grep ...\n";
	my $mysqld = `cat $cnfpath | grep character_set_server | wc -l`;
	my $client = `cat $cnfpath | grep client | wc -l`;
	my $clientSet =`cat $cnfpath |grep default-character-set |wc -l`;

	if($mysqld == 0 || $client == 0 || $clientSet ==0){
 		print "Init Mysql Cnf .. \n";
		my $tmp ;
                    open(H,"$cnfpath");
                    while(my $line=<H>){
			if($mysqld == 0){
			  if($line =~ /\[mysqld\](.*)/){
			   	$tmp = $tmp.$line."character_set_server=utf8\nevent_scheduler=ON\nmax_connections=1000\ninnodb_flush_log_at_trx_commit=2\n";
				next;
			  }
			}
			if( $client != 0 && $clientSet == 0 ){
			  if($line =~ /\[client\](.*)/){
			   	$tmp = $tmp.$line."default-character-set=utf8\n";
				next;
			  }
			}
			$tmp = $tmp.$line ;
			
                     }
		if( $client ==0 ){
			$tmp = $tmp."[client]\n"."default-character-set=utf8\n";
		}
                close H;
		&log($tmp);
		`/bin/cp -rf $logfile $cnfpath`;
		print "Restart Mysql .. \n";
		if($version == 7){
		`service mysqld restart`;
		}
	}
}

sub writeAutoStart{
	my $start = `cat /etc/rc.local | grep mysql|wc -l`;
        if($start == 0){
        my $fh ;
        open $fh, ">> /etc/rc.local" ;
	print $fh "service mysqld start";
        close $fh;
        }
}
