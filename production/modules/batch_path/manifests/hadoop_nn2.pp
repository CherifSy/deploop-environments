#
# Hadoop NameNode NN2 resouce execution class
#
class batch_path::hadoop_nn2 inherits batch_path::hadoop_node {

  info('[deploop] hadoop NameNode NN2 class constructor')  

    if ($hadoop_security_authentication == "kerberos") {
      include kerberos::server
      include kerberos::kdc      
      include kerberos::kdc::admin_server
  }

  hadoop::namenode { 'namenode':  
        host => $hadoop_namenode_nn2,  
        dirs => $namenode_data_dirs,    
        auth => $hadoop_security_authentication,
  }
}


