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

      $kdc_server = extlookup('kdc_server')
      $realm = extlookup('kdc_realm')

      package {'krb5-workstation':
        allow_virtual => false,
	      ensure => 'installed',
      }

      file { '/etc/krb5.conf':
        content => template('kerberos/krb5.conf'),
      }
  }
}
