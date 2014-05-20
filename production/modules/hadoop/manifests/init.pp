class hadoop {
  info('[deploop] Hadoop node class')  

  file {
    '/etc/hadoop/conf/core-site.xml':
      content => template('hadoop/core-site.xml'),
  }

}
