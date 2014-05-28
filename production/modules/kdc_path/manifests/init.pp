#
# Bus path node selector
#
class kdc_path {
  info('[deploop] KDC node class')  

  /*
   * The Deploop Management node is used as KDC for all the
   * the enviroments.
   */
  $hadoop_security_authentication = extlookup('hadoop_security_authentication')
  if ($hadoop_security_authentication == 'kerberos') { 

    include kerberos

    if ($deploop_role == 'master') {
      info("[deploop][${fqdn}] Deploop Management and Key Distribution Center node")
      kerberos::kerberos_server{'server':}
    } 
  } else {
      info("[deploop][${fqdn}][ERROR] Node in KDC path however hadoop_security is simple")
  }
}
