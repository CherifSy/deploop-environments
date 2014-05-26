class flume {
  info("Flume base class constructor")  

  class config_files_flume {
   #file { '/etc/flume/conf/flume.conf':
   #     content => template('flume/flume.conf'),
   # }
  }

  #
  # The packages for Flume injector
  #
  $flume_pkgs= ['flume-agent', 
                'flume-kafka-sink']

  package { $flume_pkgs:
	  ensure => 'installed',
  }

  #
  # The configs for the NameNode
  #
  file { "/etc/flume/conf":
    ensure => "directory",
    require => Package[$flume_pkgs],
  }

  include config_files_flume

}
