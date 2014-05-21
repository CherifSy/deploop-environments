#
# Batch path node selector
#
class batch-path {

  info('[deploop] Batch node class')  
  include base
  include zookeeper
  $hadoop_security_authentication = extlookup('hadoop_security', 'simple')
  $nameservice_id = extlookup('hadoop_ha_nameservice', 'openbuscluster')
  $hadoop_namenode_nn1 = extlookup('hadoop_namenode_nn1')
  $hadoop_namenode_nn2 = extlookup('hadoop_namenode_nn2')
  $hadoop_resourcemanager = extlookup('hadoop_resourcemanager')

  case $::deploop_role {
    nn1: {
      info("[deploop] Active NameNode NN1 for HDFS HA")
      info("[deploop] The hostname ${fqdn} has NN1 role")

      include hadoop_datanode_nn1
    }
    nn2: {
      info("[deploop] Standby NameNode NN2 for HDFS HA")
      include hadoop
    }
    rm: {
      info("[deploop] Standby NameNode NN2 for HDFS HA")
      include yarn
    }
    dn: {
      info("[deploop] HDFS Worker DataNode")
      include hadoop
    }
    default: {
      info("[deploop] ERROR undefined role: ${deploop_role}")
    }
  }
}
