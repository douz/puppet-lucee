class lucee (
	$luceeadminpass      = $lucee::params::luceeadminpass,
	$install_nginx       = $lucee::params::install_nginx,
	$version             = $lucee::params::version,
	) inherits lucee::params {
#Install Nginx if required
	if $install_nginx    == undef {
		fail('install_nginx is undefined')
	}
	elsif $install_nginx == true {
		class { lucee::nginx: }
	}
	elsif $install_nginx != false {
		fail("Option $install_nginx is not valid for install_nginx")
	}

#Get Lucee installer
	if $version          == undef {
		fail('version is undefined')
	}
	elsif $version       == '4.5.3' {
		exec { 'download lucee':
			command      => "wget http://cdn.lucee.org/downloader.cfm/id/167/file/lucee-4.5.3.020-pl0-linux-x64-installer.run -O /tmp/lucee_installer.run",
			path         => '/usr/sbin/:/usr/bin/',
			creates      => '/tmp/lucee_installer.run',
			onlyif       => 'test ! -d /opt/lucee',
		}
	}
	elsif $version       == '5.0.0' {
		exec { 'download lucee':
            command      => "wget http://cdn.lucee.org/downloader.cfm/id/164/file/lucee-5.0.0.254-pl0-linux-x64-installer.run -O /tmp/lucee_installer.run",
            path         => '/usr/sbin/:/usr/bin/',
            creates      => '/tmp/lucee_installer.run',
			onlyif       => 'test ! -d /opt/lucee',
        }
	}
	elsif $version       == '5.1.0' {
    	exec { 'download lucee':
        	command      => "wget http://cdn.lucee.org/downloader.cfm/id/170/file/lucee-5.1.0.034-pl0-linux-x64-installer.run -O /tmp/lucee_installer.run",
            path         => '/usr/sbin/:/usr/bin/',
            creates      => '/tmp/lucee_installer.run',
            onlyif       => 'test ! -d /opt/lucee',
        }
    }
	else {
		fail("version $version is not supported")
	}

#Create run user for lucee
    user { 'lucee':
    	ensure           => present,
        comment          => 'Lucee Admin User',
    }

#Install Lucee
	exec { 'install lucee':
		command          => "/tmp/lucee_installer.run --mode unattended --luceepass $luceeadminpass --installconn false",
		creates          => '/opt/lucee',
		require          => [User['lucee'], Exec['download lucee']],
	}

#Run Lucee as lucee user
	exec { 'change_user.sh lucee':
		command          => "/opt/lucee/sys/change_user.sh lucee /opt/lucee/ lucee nobackup",
		cwd              => '/opt/lucee/sys',
		subscribe        => Exec['install lucee'],
		refreshonly      => true,
		notify           => Service['lucee_ctl'],
	}
#Change ownership of /opt/lucee
	file { '/opt/lucee':
		ensure           => directory,
        owner            => 'lucee',
        group            => 'lucee',
        mode             => '0775',
		recurse          => true,
		require          => User['lucee'],
	}

#Make sure Lucee service is running
	service { 'lucee_ctl':
		ensure           => running,
		enable           => true,
		require          => User['lucee'],
	}
}