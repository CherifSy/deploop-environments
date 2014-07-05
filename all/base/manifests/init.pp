#
# Class with common resources for all enviroments:
# 1. The ecosystem repository.
# 2 The JVM
#
class base {
    
  info('[deploop] Base node class')
	
  #
  # Base resources for all servers
  #

  # The Buildoop repository
  case $::operatingsystem {
    /(CentOS|RedHat)/: {
      yumrepo { "buildoop":
   		  baseurl => extlookup("buildoop_yumrepo_uri", $default_buildoop_yumrepo_uri),
   		  descr => "Buildoop Hadoop Ecosystem",
   		  enabled => 1,
   		  gpgcheck => 0,
	    }
    } 
    default: {
	    notify{"[deploop] WARNING: non-yum platform or check Buildoop repo": }
    }
  }

  # Oracle Sun JDK is the only supported JVM by Deploop.
  # http://wiki.apache.org/hadoop/HadoopJavaVersions
  package { $jdk_package_name:
    allow_virtual => false,
	ensure => "installed",
	alias => "jdk",
  }

  # System wide JAVA_HOME load. FIXME: the version is hardcoded.
  $java_version = 'jdk1.7.0_51'
  file {'java.sh':
    path    => '/etc/profile.d/java.sh',
    ensure  => present,
    mode    => 0755,
    content => template('base/java.sh'),
  }

  # This utiliy is used by mcollective-service-agent
  # for start/stop/status services.
  package { 'lsof':
    allow_virtual => false,
	ensure => "installed",
  }

  # FIXME: problem with puppetlabs-stdlib
  # below an alternative: comment_out_line
  #
  #file_line {'etc_sudoers':
  #  ensure  => present,
  #  path    => '/etc/sudoers',
  #  line    => '#Defaults    requiretty',
  #  match   => 'Defaults    requiretty'
  #}

  # FIXME: recreate cache conditional
  #exec { "yum makecache":
  #  command => "/usr/bin/yum makecache",
  #  require => Yumrepo["buildoop"]
  #}

  # Filename to process and pattern for find
  # the line for comment out with the character '#'.
  define comment_out_line ($file, $pattern) {
   exec { "/bin/sed -i -r -e '/^Defaults\s*requiretty/ s/^/#/' $file":
    onlyif => "/bin/grep -E '$pattern' '$file'",
   }
  }

   # We need to disable the 'requiretty' property
   # in the sudoers file in order to execute 'sudo'
   # by means of mcollective-deploop-agent 'execute'
   # action.
  comment_out_line { 'sudoers':
    file => "/etc/sudoers",
    pattern => "^Defaults\s*requiretty",
  }

  define parse_entities{
    case $name{
      flume: {
        info("[deploop][${fqdn}] Flume entity")
        include flume
      }
      monit: {
        info("[deploop][${fqdn}] Monit entity")
        #include monit
      }
      default: {
        info("[deploop][${fqdn}] ERROR undefined entity: ${deploop_role}")
      }
    }
 }
}

