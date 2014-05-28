class kerberos {
  info("kerberos base class constructor")  

  define kerberos_server () {
      info("[deploop][${fqdn}] KDC Server node role")

      package {'krb5-server':
        allow_virtual => false,
	      ensure => 'installed',
      }
  }

  define kerberos_workstation () {
      info("[deploop][${fqdn}] Kerberos Workstation node role")

      package {'krb5-workstation':
        allow_virtual => false,
	      ensure => 'installed',
      }
  }
}
