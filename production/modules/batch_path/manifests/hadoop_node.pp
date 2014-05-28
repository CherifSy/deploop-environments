#
# This class is the common definitios for all hadoop
# nodes in the cluster.
#
class batch_path::hadoop_node {
  info('[deploop] generic hadoop node class constructor')  

  include base

  $hadoop_security_authentication = extlookup('hadoop_security_authentication')
  if ($hadoop_security_authentication == 'kerberos') {
      include kerberos
      kerberos::kerberos_workstation{'workstation':}
  }

}
