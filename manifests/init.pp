class solr ($source_url="http://mirrors.enquira.co.uk/apache/lucene/solr/3.6.1/apache-solr-3.6.1.tgz",
            $install_folder="/opt",
			$package="apache-solr-3.6.1") {
) {
	$packages = ["curl", "default-jre"]
	package { $packages:
		ensure => present
	}
	$destination = "$install_folder/$package.tgz"
	exec { "download-solr":
	    command => "curl -o $destination $source_url",
		unless => "test -f $destination",
		require => Package["curl"],
	}
	exec { "unpack-solr":
	    command => "tar -xzf $destination --directory=$install_folder",
		unless => "test -f $install_folder/$package",
		require => Exec["download-solr"],
	}
	file { "/opt/apache-solr":
		ensure => "link",
		target => "$install_folder/$package",
	}
}