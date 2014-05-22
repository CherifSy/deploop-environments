#
# Hadoop DataNode NN1 resouce execution class
#
class batch_path::hadoop_nn1 inherits batch_path::hadoop_node {
  info('[deploop] hadoop NameNode NN1 class constructor')  

  hadoop::test{'test':
    message => "mierda",
  }
}

