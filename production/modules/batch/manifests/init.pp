class batch {
  info('[deploop] Batch node class')  
  include hadoop
  case $::deploop_role {
    nn1: {
      info("[deploop] Active NameNode NN1 for HDFS HA")
    }
    nn2: {
      info("[deploop] Standby NameNode NN2 for HDFS HA")
    }
    default: {
      info("[deploop] ERROR undefined role: ${deploop_role}")
    }
  }
}
