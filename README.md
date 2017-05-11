
# H3 sshd portin muutto ja Apache2 asennus ja kotisivun luonti

Tero Karvisen tehtävänanto H3:
a) SSHD. Konfiguroi SSH uuteen porttiin Puppetilla.
b) Modulit Gittiin. Laita modulisi versionhallintaan niin, että saat ne helposti ajettua uudella Live-USB työpöydällä.
c) Etusivu uusiksi. Vaihda Apachen oletusweppisivu (default website) Puppetilla. 

### Apache2

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

