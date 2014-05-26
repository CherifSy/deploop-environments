#
# Hadoop NameNode resouce execution class
#
class batch_path::hadoop_nn inherits batch_path::hadoop_node {

  info('[deploop] hadoop NameNode class constructor')  
  info("[deploop] Host entities(s): ${deploop_entity}")  

  include base

  if ($hadoop_security_authentication == "kerberos") {
      include kerberos::server
      include kerberos::kdc      
      include kerberos::kdc::admin_server
  }

  hadoop::namenode { 'namenode':  
        host => $hadoop_namenode_nn1,  
        auth => $hadoop_security_authentication,
  }

 $array_of_entities = split($deploop_entity, ' ')
 base::parse_entities{ $array_of_entities: }
}

