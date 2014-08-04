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

      #
      # Serving Layer on top of Batch Layer:
      # This roles are handled by the Speed Layer itself.
      # This code is only for logging and sanity checking.
      #

      # HBase
      hbase-master: {
        info("[deploop][${fqdn}] Hbase Master role handled by serving layer")
      }
      hbase-region-server: {
        info("[deploop][${fqdn}] Hbase Region Server role handled by serving layer")
      }
      # ElasticSearch
      es-master: {
        info("[deploop][${fqdn}] ElasticSearch Master role handled by serving layer")
      }
      es-data: {
        info("[deploop][${fqdn}] ElasticSearch Data role handled by serving layer")
      }

      default: {
        info("[deploop][${fqdn}] ERROR undefined role: ${deploop_role}")
      }
    }
 }

 $array_of_roles = split($deploop_role, ' ')
 parseroles { $array_of_roles: }
}
