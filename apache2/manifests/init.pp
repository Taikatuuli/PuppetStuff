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

}
