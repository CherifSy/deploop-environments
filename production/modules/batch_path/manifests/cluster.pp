class batch_path::cluster {
      hadoop::test{'test':
        message => "mierda",
      }
}

class batch_path::otra {
      hadoop::test{'otrotest':
        message => "mierda otra",
      }
}

