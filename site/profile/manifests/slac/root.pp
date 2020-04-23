class profile::slac::root {

  file_line { 'Enlarge bash history file':
    path  => '/root/.bashrc',
    line  => 'export HISTFILESIZE=1000000',
    match => '^ *export +HISTFILESIZE=',
  }

  file_line { 'Enlarge bash history':
    path  => '/root/.bashrc',
    line  => 'export HISTSIZE=50000',
    match => '^ *export +HISTSIZE=',
  }

}
