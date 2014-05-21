class batch_path::hadoop_dn {
  include base

  hadoop::test{'test':
    message => "mierda",
  }
}
