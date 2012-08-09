class solr::install ($source_url, $install_dir, $package) {
	$packages = ["curl", "default-jre"]
	package { $packages:
		ensure => present
	}
	$destination = "$install_dir/$package.tgz"
	exec { "download-solr":
	    command => "curl -o $destination $source_url",
		unless => "test -f $destination",
		require => Package["curl"],
	}
	exec { "unpack-solr":
	    command => "tar -xzf $destination --directory=$install_dir",
		unless => "test -d $install_dir/$package",
		require => Exec["download-solr"],
	}
	file { "$install_dir/apache-solr":
		ensure => "link",
		target => "$install_dir/$package",
	}
}

class solr::supervisord ($install_dir, $solr_home_dir, $solr_data_dir) {
	package { "supervisor":
		ensure => present,
	}
	$start_dir = "$install_dir/apache-solr/example"
	file { "/etc/supervisor/conf.d/solr.conf":
	    ensure => present,
		content => template("solr/solr.conf"),
		require => Package["supervisor"],
	}
	service { "supervisor":
		ensure => "running",
		require => [Package["supervisor"]]
	}
}

class solr ($source_url="http://mirrors.enquira.co.uk/apache/lucene/solr/3.6.1/apache-solr-3.6.1.tgz",
            $install_dir="/opt",
			$package="apache-solr-3.6.1",
			$solr_home_dir,
			$solr_data_dir="/opt/data") {
	class { "solr::install":
		source_url => $source_url,
		install_dir => $install_dir,
		package => $package,
	}
	class { "solr::supervisord":
		install_dir => $install_dir,
		solr_home_dir => $solr_home_dir,
		solr_data_dir => $solr_data_dir,
	}
}