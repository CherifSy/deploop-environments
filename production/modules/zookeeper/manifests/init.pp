class zookeeper {
  info("Zookeeper base class constructor")  

  $hadoop_security_authentication = extlookup('hadoop_security_authentication')

  class zookeeper_files_keytab {
    file {'/etc/zookeeper/conf/keytables/':
      ensure => "directory",
    }

    file {'/etc/zookeeper/conf/keytables/zookeeper.keytab':
      ensure => present,
      target => "/var/kerberos/principals/${fqdn}/zookeeper.keytab",
    }
  }

  #
  # The defaults for Zookeeper
  #
  file { '/etc/zookeeper/conf/zoo.cfg':
    content => template('zookeeper/zoo.cfg'),
  }

  define create_myid {
    case $name {
      nn1,nn2,rm: { 
        file {'/var/lib/zookeeper/myid':
          path    => '/var/lib/zookeeper/myid',
          ensure  => present,
          mode    => 0644,
          content => $name? {
            'nn1'  => '1',
            'nn2'  => '2',
            'rm'   => '3',
          },
        }
      }
      default: {
      }
    }
  }

  $array_of_roles = split($::deploop_role, ' ')
  create_myid { $array_of_roles: }

  if ($hadoop_security_authentication == 'kerberos') { 
      include zookeeper_files_keytab
  }

}
