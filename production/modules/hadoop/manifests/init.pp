class hadoop {
  info('[deploop] Hadoop node class')  

  # We define Clases and defines and resources here.

  # Config files in all nodes.
  file {
    '/etc/hadoop/conf/core-site.xml':
      content => template('hadoop/core-site.xml'),
  }

  define test($message = $msg) {
    info("[deploop] define test a regular resource ${message}")  
  }
}
