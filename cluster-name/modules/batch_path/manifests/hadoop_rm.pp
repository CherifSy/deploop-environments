#
# Hadoop ResourceManager resouce execution class
#
class batch_path::hadoop_rm inherits batch_path::hadoop_node {

  info('[deploop] hadoop ResourceManager class constructor')  
  info("[deploop] Host entities(s): ${deploop_entity}")  

  include base

  hadoop::resourcemanager{ 'resourcemanager':  
        host => $hadoop_namenode_nn1,  
        dirs => $namenode_data_dirs,    
        auth => $hadoop_security_authentication,
  }

 $array_of_entities = split($deploop_entity, ' ')
 base::parse_entities{ $array_of_entities: }
}
