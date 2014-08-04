#
# Bus path node selector
#
class serving_path {

  info('[deploop] Serving node class')  
  info("[deploop] Host role(s): ${deploop_role}")  

  define parseroles{
    case $name{
      nn1, nn2, rm, dn: {
        info("[deploop][${fqdn}] Batch layer role dropped in Serving layer")
      }

      # HBase
      hbase-master: {
        info("[deploop][${fqdn}] Hbase Master role")
      }

      hbase-worker: {
        info("[deploop][${fqdn}] Hbase Region Server role")
      }

      # ElasticSearch
      elasticsearch-master: {
        info("[deploop][${fqdn}] ElasticSearch Master role")
      }

      elasticsearch-worker: {
        info("[deploop][${fqdn}] ElasticSearch Data role")
      }

      default: {
        info("[deploop][${fqdn}] ERROR undefined role: ${deploop_role}")
      }
    }
 }

 $array_of_roles = split($deploop_role, ' ')
 parseroles { $array_of_roles: }

}
