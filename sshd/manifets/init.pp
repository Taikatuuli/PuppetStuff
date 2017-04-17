class sshd ($port = 22){
 
	package { 'openssh-server':
		ensure	=> 'latest',
	}
	
	file {'etc/ssh/sshd_config':
		content => template ("sshd/sshd_config.erb"),
		require => Package ["openssh-server"],
		notify => Service ["ssh"],

	service { 'sshd':
		ensure	=> 'running',
		enabled	=> 'true',	
		require => Package ["openssh-server"],
	}
}
