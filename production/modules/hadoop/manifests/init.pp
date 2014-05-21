class hadoop {
  info('[deploop] Hadoop node class')  

  # Config files in all nodes.
  file {
    '/etc/hadoop/conf/core-site.xml':
      content => template('hadoop/core-site.xml'),
  }

  define test($message = $msg) {
    info("[deploop] define test a regular resource ${message}")  
  }
}
