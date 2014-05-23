#
# Hadoop worker DataNode resouce execution class
#
class batch_path::hadoop_dn inherits batch_path::hadoop_node {

  info('[deploop] hadoop NameNode class constructor')  

    if ($hadoop_security_authentication == "kerberos") {
      include kerberos::server
      include kerberos::kdc      
      include kerberos::kdc::admin_server
  }

  hadoop::datanode{ 'datanode':  
        host => $hadoop_namenode_nn1,  
        dirs => $namenode_data_dirs,    
        auth => $hadoop_security_authentication,
  }
}

