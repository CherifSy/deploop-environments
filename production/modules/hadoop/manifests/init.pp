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


 #
 # The NameNode definition
 # 
 define namenode ($host = $fqdn , 
                  $auth = 'simple') {

    $hadoop_security_authentication = extlookup('hadoop_security', 'simple')
    $nameservice_id = extlookup('hadoop_ha_nameservice', 'openbuscluster')
    $hadoop_namenode_nn1 = extlookup('hadoop_namenode_nn1')
    $hadoop_namenode_nn2 = extlookup('hadoop_namenode_nn2')
    $hadoop_resourcemanager = extlookup('hadoop_resourcemanager')

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
    # The local fileystem for HDFS
    #
    $nn_local_dirs = [ "/cluster/", "/cluster/metadata/",
                      "/cluster/metadata/1/", "/cluster/metadata/1/dfs/"]
    file {$nn_local_dirs:
        ensure => "directory",
        owner  => "hdfs",
        group  => "hdfs",
        mode   => 755,
    }
    file {'/cluster/metadata/1/dfs/nn':
         ensure => "directory",
        owner  => "hdfs",
        group  => "hdfs",
        mode   => 700,
    }

    # 
    # The local fileystem for JournalNode
    #
    $jn_local_dirs = ["/cluster/data/",
                      "/cluster/data/1/", "/cluster/data/1/dfs/"]
    file {'/cluster/data/1/dfs/jn':
         ensure => "directory",
        owner  => "hdfs",
        group  => "hdfs",
        mode   => 700,
    }
    file { $jn_local_dirs:
        ensure => "directory",
        owner  => "hdfs",
        group  => "hdfs",
        mode   => 755,
    }

    include config_files_hdfs
    include config_files_yarn
    include config_files_mrv2
    include zookeeper
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
    # The local fileystem for JournalNode
    #
    $jn_local_dirs = [ "/cluster/", "/cluster/data/",
                      "/cluster/data/1/", "/cluster/data/1/dfs/"]
    file {'/cluster/data/1/dfs/jn':
         ensure => "directory",
        owner  => "hdfs",
        group  => "hdfs",
        mode   => 700,
    }
    file { $jn_local_dirs:
        ensure => "directory",
        owner  => "hdfs",
        group  => "hdfs",
        mode   => 755,
    }

    include config_files_hdfs
    include config_files_yarn
    include config_files_mrv2
    include zookeeper
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
    $roots = extlookup("datanode_data_dirs", split($datanode_data_dirs, ",")) 
    $namenode_data_dirs = extlookup("hadoop_namenode_data_dirs", append_each("/namenode", $roots))

    info("[deploop] DataNode datadirs: $namenode_data_dirs")  

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
    # The local fileystem for HDFS DataNode
    #
    $dn_local_dirs = [ "/cluster/", "/cluster/data/",
                      "/cluster/data/1/", "/cluster/data/1/dfs/",
                      '/cluster/data/1/dfs/dn']
    file { $dn_local_dirs:
        ensure => 'directory',
        owner  => 'hdfs',
        group  => 'hdfs',
        mode   => 755,
    }

    $yarn_local_dirs = ['/cluster/data/1/yarn/','/cluster/data/1/yarn/local',
                        '/cluster/data/1/yarn/logs']
    file { $yarn_local_dirs:
        ensure => 'directory',
        owner  => 'yarn',
        group  => 'yarn',
        mode   => 755,
    }

    include config_files_hdfs
    include config_files_yarn
    include config_files_mrv2
 }

}
