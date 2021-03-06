class hadoop {
  # We define clasess, defines and resources here.

  info('[deploop] Hadoop node class')  

  # Common definitions for hadoop nodes.
  # They all need these files so we can access hdfs/jobs from any node

  class config_files_hdfs {

    # HDFS Config files
    file { '/etc/hadoop/conf/core-site.xml':
      content => template('hadoop/core-site.xml'),
    }

    file { '/etc/hadoop/conf/hdfs-site.xml':
      content => template('hadoop/hdfs-site.xml'),
    }

    file { '/etc/hadoop/conf/hadoop-env.sh':
      content => template('hadoop/hadoop-env.sh'),
    }

    file { '/etc/hadoop/conf/hadoop-env.cmd':
      content => template('hadoop/hadoop-env.cmd'),
    }

    file { '/etc/hadoop/conf/hadoop-metrics.properties':
      content => template('hadoop/hadoop-metrics.properties'),
    }

    file { '/etc/hadoop/conf/hadoop-metrics2.properties':
      content => template('hadoop/hadoop-metrics2.properties'),
    }

    file { '/etc/hadoop/conf/hadoop-policy.xml':
      content => template('hadoop/hadoop-policy.xml'),
    }

    file { '/etc/hadoop/conf/log4j.properties':
      content => template("hadoop/log4j.properties"),
    }

  }

 # YARN config files
 class config_files_yarn {

  file { '/etc/hadoop/conf/yarn-site.xml':
    content => template('hadoop/yarn-site.xml'),
  }

  file { '/etc/hadoop/conf/yarn-env.cmd':
    content => template('hadoop/yarn-env.cmd'),
  }

  file { '/etc/hadoop/conf/yarn-env.sh':
    content => template('hadoop/yarn-env.sh'),
  }

  file { '/etc/hadoop/conf/capacity-scheduler.xml':
    content => template('hadoop/capacity-scheduler.xml'),
  }

  file { '/etc/hadoop/conf/configuration.xsl':
    content => template('hadoop/configuration.xsl'),
  }
 
  file { '/etc/hadoop/conf/container-executor.cfg':
    content => template('hadoop/container-executor.cfg'),
  }

 }

 # MapReduce v2 config files
 class config_files_mrv2 {

  file { '/etc/hadoop/conf/mapred-site.xml':
    content => template('hadoop/mapred-site.xml'),
  }

  file { '/etc/hadoop/conf/mapred-env.cmd':
    content => template('hadoop/mapred-env.cmd'),
  }

  file { '/etc/hadoop/conf/mapred-env.sh':
    content => template('hadoop/mapred-env.sh'),
  }
 }

class hadoop_files_keytab {
  file {'/etc/hadoop/conf/security/':
    ensure => "directory",
  }

  file {'/etc/hadoop/conf/security/hdfs.keytab':
    ensure => present,
    target => "/var/kerberos/principals/${fqdn}/hdfs.keytab",
  }

  file {'/etc/hadoop/conf/security/yarn.keytab':
    ensure => present,
    target => "/var/kerberos/principals/${fqdn}/yarn.keytab",
  }

  file {'/etc/hadoop/conf/security/mapred.keytab':
    ensure => present,
    target => "/var/kerberos/principals/${fqdn}/mapred.keytab",
  }

  file {'/etc/hadoop/conf/security/HTTP.keytab':
    ensure => present,
    target => "/var/kerberos/principals/${fqdn}/HTTP.keytab",
  }
}

 define makeBaseDirs {
    file { "$name":
        ensure => "directory",
        owner  => "hdfs",
        group  => "hdfs",
        mode   => 755,
    }

    file { "$name/dfs":
        ensure => "directory",
        owner  => "hdfs",
        group  => "hdfs",
        mode   => 755,
    }
 }

 define makeNNdirs {

    info("[deploop] NameNode makeDirs: $name/dfs/nn")  
    
    file { "$name/dfs/nn":
        ensure => "directory",
        owner  => "hdfs",
        group  => "hdfs",
        mode   => 700,
    }
 }

 define makeJNdirs {

    info("[deploop] JournalNode makeDirs: $name/dfs/jn")  

    file { "$name/dfs/jn":
        ensure => "directory",
        owner  => "hdfs",
        group  => "hdfs",
        mode   => 700,
    }
 }

 define makeDNdirs {

    info("[deploop] DataNode makeDirs: $name/dfs/nn")  
    
    file { "$name/dfs/dn":
        ensure => "directory",
        owner  => "hdfs",
        group  => "hdfs",
        mode   => 755,
    }

   file { "$name/yarn":
        ensure => "directory",
        owner  => "yarn",
        group  => "yarn",
        mode   => 755,
    }

   file { "$name/yarn/local":
        ensure => "directory",
        owner  => "yarn",
        group  => "yarn",
        mode   => 755,
    }

   file { "$name/yarn/logs":
        ensure => "directory",
        owner  => "yarn",
        group  => "yarn",
        mode   => 755,
    }
 }
 
 #
 # The NameNode definition
 # 
 define namenode ($host = $fqdn , 
                  $auth = 'simple') {

    $hadoop_security_authentication = extlookup('hadoop_security_authentication')
    $realm = extlookup('kdc_realm')
    $nameservice_id = extlookup('hadoop_ha_nameservice', 'openbuscluster')
    $hadoop_namenode_nn1 = extlookup('hadoop_namenode_nn1')
    $hadoop_namenode_nn2 = extlookup('hadoop_namenode_nn2')
    $hadoop_resourcemanager = extlookup('hadoop_resourcemanager')

    # The host set up the storage locations by means of fact.
    $roots              = extlookup("hadoop_storage_dirs",       split($hadoop_storage_locations, ";"))

    $namenode_data_dirs = extlookup("hadoop_namenode_data_dirs", append_each("/dfs/dn", $roots))
    $nodemanager_log_dirs = extlookup("hadoop_namenode_data_dirs", append_each("/yarn/logs", $roots))
    $nodemanager_local_dirs = extlookup("hadoop_namenode_data_dirs", append_each("/yarn/local", $roots))
    $namenode_fsimage_dirs = extlookup("hadoop_namenode_data_dirs", append_each("/dfs/nn", $roots))
    $journal_edits_dirs = extlookup("hadoop_namenode_data_dirs", append_each("/dfs/jn", $roots))
    info("[deploop] DataNode datadirs: $namenode_data_dirs")  

    #
    # The packages for the NameNode 
    #
    $namenode_pkgs = [ 'hadoop-hdfs-namenode', 
                       'hadoop-hdfs-journalnode', 
                       'zookeeper-server',
                       'hadoop-hdfs-zkfc']

    package { $namenode_pkgs:
      allow_virtual => false,
	    ensure => 'installed',
    }

    #
    # The configs for the NameNode
    #
    file { "/etc/hadoop/conf":
      ensure => "directory",
      require => Package[$namenode_pkgs],
    }

    #
    # The defaults for the NameNode
    #
    file { '/etc/default/hadoop':
        content => template('hadoop/hadoop'),
    }
    file { '/etc/default/hadoop-hdfs-namenode':
        content => template('hadoop/hadoop-hdfs-namenode'),
    }
    file { '/etc/default/hadoop-hdfs-journalnode':
        content => template('hadoop/hadoop-hdfs-journalnode'),
    }
    file { '/etc/default/hadoop-hdfs-zkfc':
        content => template('hadoop/hadoop-hdfs-zkfc'),
    }

    #
    # The NameNode local filesystem looks like this if
    # we are not using redundancy in the JBOD for metatada
    # or JNs index.
    #
    # /cluster/
    #  └── data
    #      └── 1
    #          └── dfs
    #              ├── jn
    #              └── nn
     
    #
    # The local fileystem for HDFS in the NameNode
    #
    file {"/data/":
        ensure => "directory",
        owner  => "hdfs",
        group  => "hdfs",
        mode   => 755,
    }

    makeBaseDirs { $roots :} 

    makeNNdirs { $roots :} 

    makeJNdirs { $roots :} 

    include config_files_hdfs
    include config_files_yarn
    include config_files_mrv2

    if ($hadoop_security_authentication == 'kerberos') { 
      include hadoop_files_keytab
    }

    include zookeeper
  }

 #
 # The ResourceManager definition
 #
 define resourcemanager ($host = $fqdn , 
                  $auth = 'simple', 
                  $dirs = ["/tmp/nn"], 
                  $zk = '') {

    $hadoop_security_authentication = extlookup('hadoop_security_authentication')
    $realm = extlookup('kdc_realm')
    $nameservice_id = extlookup('hadoop_ha_nameservice', 'openbuscluster')
    $hadoop_namenode_nn1 = extlookup('hadoop_namenode_nn1')
    $hadoop_namenode_nn2 = extlookup('hadoop_namenode_nn2')
    $hadoop_resourcemanager = extlookup('hadoop_resourcemanager')

    # The host set up the storage locations by means of fact.
    $roots              = extlookup("hadoop_storage_dirs",       split($hadoop_storage_locations, ";"))
    
    $namenode_data_dirs = extlookup("hadoop_namenode_data_dirs", append_each("/dfs/dn", $roots))
    $nodemanager_log_dirs = extlookup("hadoop_namenode_data_dirs", append_each("/yarn/logs", $roots))
    $nodemanager_local_dirs = extlookup("hadoop_namenode_data_dirs", append_each("/yarn/local", $roots))
    $namenode_fsimage_dirs = extlookup("hadoop_namenode_data_dirs", append_each("/dfs/nn", $roots))
    $journal_edits_dirs = extlookup("hadoop_namenode_data_dirs", append_each("/dfs/jn", $roots))
    info("[deploop] DataNode datadirs: $namenode_data_dirs")  

    #
    # The packages for the ResourceManager
    #
    $resourcemananger_pkgs = [ 'hadoop-yarn-resourcemanager', 
                       'hadoop-hdfs-journalnode',
                       'zookeeper-server',
                       'hadoop-mapreduce-historyserver']

    package { $resourcemananger_pkgs:
      allow_virtual => false,
	    ensure => 'installed',
    }

    #
    # The configs for the NameNode
    #
    file { "/etc/hadoop/conf":
      ensure => "directory",
      require => Package[$resourcemananger_pkgs],
    }

    #
    # The defaults for the ResourceManager
    #
    file { '/etc/default/hadoop':
        content => template('hadoop/hadoop'),
    }
    file { '/etc/default/hadoop-yarn-resourcemanager':
        content => template('hadoop/hadoop-yarn-resourcemanager'),
    }
    file { '/etc/default/hadoop-hdfs-journalnode':
        content => template('hadoop/hadoop-hdfs-journalnode'),
    }

    #
    # The ResourceManager local filesystem looks like this if
    # we are not using redundancy in the JBOD for JNs index.
    #
    # /cluster/
    #  └── data
    #      └── 1
    #          └── dfs
    #              └── jn
     
    # 
    # The local fileystem for JournalNode
    #
    file {"/data/":
        ensure => "directory",
        owner  => "hdfs",
        group  => "hdfs",
        mode   => 755,
    }

    makeBaseDirs { $roots :} 

    makeJNdirs { $roots :} 

    include config_files_hdfs
    include config_files_yarn
    include config_files_mrv2

    if ($hadoop_security_authentication == 'kerberos') { 
      include hadoop_files_keytab
    }

    include zookeeper
 }

 #
 # The DataNode definition
 #
 define datanode ($host = $fqdn , 
                  $auth = 'simple', 
                  $dirs = ["/tmp/nn"], 
                  $zk = '') {

    $hadoop_security_authentication = extlookup('hadoop_security_authentication')
    $realm = extlookup('kdc_realm')
    $nameservice_id = extlookup('hadoop_ha_nameservice', 'openbuscluster')
    $hadoop_namenode_nn1 = extlookup('hadoop_namenode_nn1')
    $hadoop_namenode_nn2 = extlookup('hadoop_namenode_nn2')
    $hadoop_resourcemanager = extlookup('hadoop_resourcemanager')

    # The host set up the storage locations by means of fact.
    $roots              = extlookup("hadoop_storage_dirs",       split($hadoop_storage_locations, ";"))
    
    $namenode_data_dirs = extlookup("hadoop_namenode_data_dirs", append_each("/dfs/dn", $roots))
    $nodemanager_log_dirs = extlookup("hadoop_namenode_data_dirs", append_each("/yarn/logs", $roots))
    $nodemanager_local_dirs = extlookup("hadoop_namenode_data_dirs", append_each("/yarn/local", $roots))
    $namenode_fsimage_dirs = extlookup("hadoop_namenode_data_dirs", append_each("/dfs/nn", $roots))
    $journal_edits_dirs = extlookup("hadoop_namenode_data_dirs", append_each("/dfs/jn", $roots))
    info("[deploop] DataNode datadirs: $namenode_data_dirs")  

    #
    # The packages for the DataNode
    #
    $datanode_pkgs = [ 'hadoop-hdfs-datanode', 
                       'hadoop-yarn-nodemanager',
                       'jsvcdaemon',
                       'hadoop-mapreduce']

    package { $datanode_pkgs:
      allow_virtual => false,
	    ensure => 'installed',
    }

    #
    # The configs for the NameNode
    #
    file { "/etc/hadoop/conf":
      ensure => "directory",
      require => Package[$datanode_pkgs],
    }

    #
    # The defaults for the DataNode
    #
    file { '/etc/default/hadoop':
        content => template('hadoop/hadoop'),
    }
    file { '/etc/default/hadoop-hdfs-datanode':
        content => template('hadoop/hadoop-hdfs-datanode'),
    }
    file { '/etc/default/hadoop-yarn-nodemanager':
        content => template('hadoop/hadoop-yarn-nodemanager'),
    }

    # 
    # The local fileystem for HDFS and YARN DataNodes. In this
    # case we have to use the whole JBOD partitions available.
    #
    #    /cluster/
    #    └── data
    #        ├── 1
    #        │   ├── dfs
    #        │   │   └── dn
    #        │   └── yarn
    #        │       ├── local
    #        │       └── logs
    #        ├── 2
    #        ... 

    #
    # FIXME: This is the most ugly way to create folders. Puppet
    # cannot create folders recursively. I have to change this poor
    # way to do that wit a "define and loop parsing", with a new
    # puppet function or even with exec { "mkdir -p /path" }.

    file { '/data':
        ensure => 'directory',
        owner  => 'hdfs',
        group  => 'hdfs',
        mode   => 755,
    }

    makeBaseDirs { $roots :} 

    makeDNDirs { $roots :} 

    include config_files_hdfs
    include config_files_yarn
    include config_files_mrv2

    if ($hadoop_security_authentication == 'kerberos') { 
      include hadoop_files_keytab
    }
 }

}
