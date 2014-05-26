class hadoop {
  # We define clasess, defines and resources here.

  info('[deploop] Hadoop node class')  

  # Common definitions for hadoop nodes.
  # They all need these files so we can access hdfs/jobs from any node
  # 
  class kerberos {             
    require kerberos::client   
  
    kerberos::host_keytab { "hdfs": 
      princs => [ "host", "hdfs" ],   
      spnego => true,          
      require => Package["hadoop-hdfs"],
    }
   
    kerberos::host_keytab { [ "yarn", "mapred" ]:
      tag    => "mapreduce",   
      spnego => true,          
      require => Package["hadoop-yarn"],
    }
  }

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

  # YARN config files
  class config_files_yarn {

  }

  # MapReduce v2 config files
  class config_files_mrv2 {


  }

 }

 #
 # The NameNode definition
 # 
 define namenode ($host = $fqdn , 
                  $auth = 'simple', 
                  $dirs = ["/tmp/nn"], 
                  $zk = '') {

    $hadoop_security_authentication = extlookup('hadoop_security', 'simple')
    $nameservice_id = extlookup('hadoop_ha_nameservice', 'openbuscluster')
    $hadoop_namenode_nn1 = extlookup('hadoop_namenode_nn1')
    $hadoop_namenode_nn2 = extlookup('hadoop_namenode_nn2')
    $hadoop_resourcemanager = extlookup('hadoop_resourcemanager')
    $namenode_data_dirs = extlookup('namenode_data_dirs')

    if ($hadoop_security_authentication == 'kerberos') { 
      include hadoop::kerberos
    }
    
    #
    # The packages for the NameNode 
    #
    $namenode_pkgs = [ 'hadoop-hdfs-namenode', 
                       'hadoop-hdfs-journalnode', 
                       'zookeeper-server',
                       'hadoop-hdfs-zkfc']

    package { $namenode_pkgs:
	    ensure => 'installed',
    }

    #
    # The configs for the NameNode
    #
    file { "/etc/hadoop/conf":
      ensure => "directory",
      require => Package[$namenode_pkgs],
    }

    include config_files_hdfs
  }

 #
 # The ResourceManager definition
 #
 define resourcemanager ($host = $fqdn , 
                  $auth = 'simple', 
                  $dirs = ["/tmp/nn"], 
                  $zk = '') {

    $hadoop_security_authentication = extlookup('hadoop_security', 'simple')
    $nameservice_id = extlookup('hadoop_ha_nameservice', 'openbuscluster')
    $hadoop_namenode_nn1 = extlookup('hadoop_namenode_nn1')
    $hadoop_namenode_nn2 = extlookup('hadoop_namenode_nn2')
    $hadoop_resourcemanager = extlookup('hadoop_resourcemanager')
    $namenode_data_dirs = extlookup('namenode_data_dirs')

    if ($hadoop_security_authentication == 'kerberos') { 
      include hadoop::kerberos
    }
    
    #
    # The packages for the ResourceManager
    #
    $resourcemananger_pkgs = [ 'hadoop-yarn-resourcemanager', 
                       'hadoop-hdfs-journalnode',
                       'zookeeper-server',
                       'hadoop-mapreduce-historyserver']

    package { $resourcemananger_pkgs:
	    ensure => 'installed',
    }

    #
    # The configs for the NameNode
    #
    file { "/etc/hadoop/conf":
      ensure => "directory",
      require => Package[$resourcemananger_pkgs],
    }

    include config_files_hdfs
    include config_files_yarn
 }

 #
 # The DataNode definition
 #
 define datanode ($host = $fqdn , 
                  $auth = 'simple', 
                  $dirs = ["/tmp/nn"], 
                  $zk = '') {

    $hadoop_security_authentication = extlookup('hadoop_security', 'simple')
    $nameservice_id = extlookup('hadoop_ha_nameservice', 'openbuscluster')
    $hadoop_namenode_nn1 = extlookup('hadoop_namenode_nn1')
    $hadoop_namenode_nn2 = extlookup('hadoop_namenode_nn2')
    $hadoop_resourcemanager = extlookup('hadoop_resourcemanager')
    $namenode_data_dirs = extlookup('namenode_data_dirs')

    if ($hadoop_security_authentication == 'kerberos') { 
      include hadoop::kerberos
    }
    
    #
    # The packages for the DataNode
    #
    $datanode_pkgs = [ 'hadoop-hdfs-datanode', 
                       'hadoop-yarn-nodemanager',
                       'jsvcdaemon',
                       'hadoop-mapreduce']

    package { $datanode_pkgs:
	    ensure => 'installed',
    }

    #
    # The configs for the NameNode
    #
    file { "/etc/hadoop/conf":
      ensure => "directory",
      require => Package[$datanode_pkgs],
    }

    include config_files_hdfs
    include config_files_mrv2
 }

}
