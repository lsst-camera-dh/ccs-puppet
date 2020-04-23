class profile::slac::ssh {

  $ptitle = regsubst($title, '::', '/', 'G')

  $key = strip(file("${ptitle}/${facts['site']}-root_key.txt"))

  ## Note that Chef is also managing /root/.ssh/authorized_keys.
  ## It creates this as a symlink to .public/authorized_keys,
  ## presumably for afs
  ssh_authorized_key { 'root ssh authorized key':
    ensure  => present,
    user    => 'root',
    name    => 'root@lsst-ss01.slac.stanford.edu',
    options => 'from="*.slac.stanford.edu"',
    type    => 'ssh-dss',
    key     => $key,
  }

  ## TODO install private key /root/.ssh/id_dsa

  ## TODO install /etc/ssh/ssh_known_hosts_local


}
