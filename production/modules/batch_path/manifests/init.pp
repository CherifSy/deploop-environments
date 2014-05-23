#
# Batch path node selector
#
class batch_path {

  info('[deploop] Batch node class')  
  info("[deploop] Host role(s): ${deploop_role}")  

  define parseroles{
    case $name{
      nn1, nn2: {
        info("[deploop][${fqdn}] NameNode role")
        include hadoop_nn
      }
      rm: {
        info("[deploop][${fqdn}] ResourceManager role")
        include hadoop_rm
      }
      dn: {
        info("[deploop][${fqdn}] DataNode role")
        include hadoop_dn
      }
      hbase-master: {
        info("[deploop][${fqdn}] Hbase Master role")
      }
      default: {
        info("[deploop][${fqdn}] ERROR undefined role: ${deploop_role}")
      }
    }
 }

 $array_of_roles = split($deploop_role, ' ')
 parseroles { $array_of_roles: }
}
