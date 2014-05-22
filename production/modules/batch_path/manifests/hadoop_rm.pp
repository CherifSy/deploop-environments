#
# Hadoop ResourceManager resouce execution class
#
class batch_path::hadoop_rm inherits batch_path::hadoop_node {

  info('[deploop] hadoop ResourceManager class constructor')  

    if ($hadoop_security_authentication == "kerberos") {
      include kerberos::server
      include kerberos::kdc      
      include kerberos::kdc::admin_server
  }

  hadoop::resourcemanager{ 'resourcemanager':  
        host => $hadoop_namenode_nn1,  
        dirs => $namenode_data_dirs,    
        auth => $hadoop_security_authentication,
  }
}
