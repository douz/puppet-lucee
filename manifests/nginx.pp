class lucee::nginx (
	$nginxpass   = $lucee::params::nginxpass,
	) inherits lucee::params {
#Create repository for nginx
	file { '/etc/yum.repos.d/nginx.repo':
		ensure   => file,
		source   => 'puppet:///modules/lucee/nginxrepo',
	}

#Create nginx user and group
	group { 'nginx':
		ensure   => present,
		gid      => '2200',
		require  => File['/etc/yum.repos.d/nginx.repo'],
	}

	user { 'nginx':
		ensure   => present,
		uid      => '2200',
		gid      => '2200',
		password => $nginxpass,
		comment  => 'Nginx User',
		require  => Group['nginx'],
	}

#Install nginx package
	package { 'nginx':
		ensure   => installed,
		require  => User['nginx'],
	}

#Run and enable nginx service
	service { 'nginx':
		ensure   => running,
		enable   => true,
		require  => Package['nginx'],
	}

#Change ownership of /etc/nginx/ to nginx:nginx
	file { '/etc/nginx':
		ensure   => directory,
		owner    => 'nginx',
		group    => 'nginx',
		recurse  => true,
		require  => Package['nginx'],
	}
}