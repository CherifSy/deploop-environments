class base {
    
  info('[deploop] Base node class')

  file {'base-system-module':
    path    => '/tmp/base-system-module',
    ensure  => present,
    mode    => 0640,
    content => "OK",
  }

  # Base resources for all servers
  case $::operatingsystem {
    /(CentOS|RedHat)/: {
      yumrepo { "buildoop":
   		  baseurl => extlookup("buildoop_yumrepo_uri", $default_buildoop_yumrepo_uri),
   		  descr => "Buildoop Hadoop Ecosystem",
   		  enabled => 1,
   		  gpgcheck => 0,
	    }
    } 
    default: {
	    notify{"[deploop] WARNING: running on a non-yum platform -- make sure Buildoop repo is setup": }
    }
}
	
  package { $jdk_package_name:
	  ensure => "installed",
	  alias => "jdk",
  }

  exec { "yum makecache":
    command => "/usr/bin/yum makecache",
    require => Yumrepo["buildoop"]
  }
}

