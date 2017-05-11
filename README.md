
# H3 ssh portin muutto ja Apache2 asennus ja kotisivun luonti

Tero Karvisen tehtävänanto H3:
* SSHD. Konfiguroi SSH uuteen porttiin Puppetilla.
* Modulit Gittiin. Laita modulisi versionhallintaan niin, että saat ne helposti ajettua uudella Live-USB työpöydällä.
* Etusivu uusiksi. Vaihda Apachen oletusweppisivu (default website) Puppetilla. 

## SSH uuteen porttiin 

Halusin muuttaa ssh:n portin niin, että porttinumero on muuttujana. 
### Init.pp tiedoston sisältö:

```puppet
class sshd ($port = 222){
 
	package { 'openssh-server':
		ensure	=> 'latest',
	}
	
	file {'etc/ssh/sshd_config':
		content => template ("sshd/sshd_config.erb"),
		require => Package ["openssh-server"],
		notify => Service ["ssh"],
	}

	service { 'sshd':
		ensure	=> 'running',
		enabled	=> 'true',	
		require => Package ["openssh-server"],
	}
}
```

sshd_config.erb tiedoston lyhennetty sisältö:
 
```puppet
Port <%= @port %>
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_dsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
UsePrivilegeSeparation yes

KeyRegenerationInterval 3600
ServerKeyBits 1024

SyslogFacility AUTH
LogLevel INFO

LoginGraceTime 120
PermitRootLogin prohibit-password
StrictModes yes

RSAAuthentication yes
PubkeyAuthentication yes

IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no

PermitEmptyPasswords no

ChallengeResponseAuthentication no

X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes

AcceptEnv LANG LC_*

Subsystem sftp /usr/lib/openssh/sftp-server

UsePAM yes
```
Tarkastin kofiguraation komennolla:
$ sudo cat /etc/ssh/sshd_config
```
# Package generated configuration file
# See the sshd_config(5) manpage for details

# What ports, IPs and protocols we listen for

Port 222 
#Use these options to restrict which interfaces/protocols sshd will bind to
#ListenAddress ::
#ListenAddress 0.0.0.0
Protocol 2
```

## Apache2

Käytin ensimmäisen kotitehtävän moduuli pohjaa jossa olin asentanut Apache2:sen.

### init.pp tiedoston sisältö:

```puppet
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
```

Testasin asennusta ja tämä onnistui ongelmitta.

``` $ sudo puppet apply  -e 'class{"apache2":}' ```

### Vastaus:

Notice: Compiled catalog for spiderstorm.eqfgq4capfouriaj4cztiwndne.fx.internal.cloudapp.net in environment production in 0.32 seconds
Notice: /Stage[main]/Apache2/Exec[userdir]/returns: executed successfully


Lisäsin luokkaan filen ja template tiedostot luokkalaiseni Niko Kaartisen tehtävän mukaan. Muokkasin vain käyttäjänimet ja ryhmät oikeaksi.
https://github.com/nikaar/puppet/tree/master/modules/apache

```puppet
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
```



### Kurssin kotisivut:

http://terokarvinen.com/2017/aikataulu-%e2%80%93-linuxin-keskitetty-hallinta-%e2%80%93-ict4tn011-11-%e2%80%93-loppukevat-2017-p2

### Niko Kaartisen esimerkki:

https://github.com/nikaar/puppet/tree/master/modules/apache

