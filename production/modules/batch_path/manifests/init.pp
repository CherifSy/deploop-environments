#
# Batch path node selector
#
class batch_path {

  info('[deploop] Batch node class')  

    case $::deploop_role {
    nn1, nn2: {
      info("[deploop] Active NameNode NN1 for HDFS HA")
      info("[deploop] The hostname ${fqdn} has NN1 role")
      include hadoop_nn
    }
    rm: {
      info("[deploop] Standby NameNode NN2 for HDFS HA")
      include hadoop_rm
    }
    dn: {
      info("[deploop] HDFS Worker DataNode")
      include hadoop_dn
    }
    default: {
      info("[deploop] ERROR undefined role: ${deploop_role}")
    }
  }
}
