class apache2 {

   	package { "apache2":
		ensure => "installed"
	}

	service { "apache2":
        	ensure => "running",
        	enable => "true",
        	require => Package["apache2"],
    	}

	exec { "userdir":
        	notify => Service["apache2"],
        	command => "/usr/sbin/a2enmod userdir",
        	require => Package["apache2"],
    	}
	
	file {'/etc/apache2/mods-enabled/userdir.load':
		ensure => "link",
		target => "/etc/apache2/mods-available/userdir.load",
		notify => Service["apache2"],
		require => Package["apache2"],
	}

	file {'/etc/apache2/mods-enabled/userdir.conf':
		ensure => "link",
		target => "/etc/apache2/mods-available/userdir.conf",
		notify => Service["apache2"],
		require => Package["apache2"],
	}

	file {'/home/taikatuuli/public_html':
		ensure => "directory",
		owner => "taikatuuli",
		group => "taikatuuli",
	}

	file {'/home/taikatuuli/public_html/index.html':
		content => template("apache/html.template"),
		owner => "taikatuuli",
		group => "taikatuuli",
	}

	file {'/etc/apache2/sites-available/taikatuuli.conf':
                content => template("apache/taikatuuli.conf.template"),
                require => Package["apache2"],
		owner => "root",
                group => "root",
        }
	
	file {'/etc/apache2/sites-enabled/taikatuuli.conf':
		ensure => "link",
		target => "/etc/apache2/sites-available/taikatuuli.conf",
		notify => Service["apache2"],
                require => Package["apache2"],
	}
	
	file {'/etc/apache2/sites-enabled/000-default.conf':
		ensure => "absent",
		notify => Service["apache2"],
		require => Package["apache2"],
	}

	file {'/etc/hosts':
		content => template("apache/hosts.template"),
		owner => "root",
		group => "root",
		notify => Service["apache2"],

	}	

}
