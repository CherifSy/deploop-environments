#
# This class is the common definitios for all hadoop
# nodes in the cluster.
#
class batch_path::hadoop_node {
  include base

  hadoop::test{'test':
    message => "mierda",
  }
}
