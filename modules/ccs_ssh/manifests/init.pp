class ccs_ssh {

  ## Note that Chef is also managing /root/.ssh/authorized_keys.
  ## It creates this as a symlink to .public/authorized_keys,
  ## presumably for afs
  ssh_authorized_key { 'root ssh authorized key':
    user => 'root',
    name => 'root@lsst-ss01.slac.stanford.edu',
    ensure => present,
    options => 'from="*.slac.stanford.edu"',
    type => 'ssh-dss',
    key  => 'AAAAB3NzaC1kc3MAAACBAJVRTAdjoR/1Sir4/caVnv5uIIYpzJvZn8U2yUWa15mNhJlKNH+x0ZBCr5YtqHCkYDWq1lk42eLUgoQn0rhJTbp4AvOO6FCrP61cMyYgJgpfv56InBvhF7aWFwhJsPAym4cQC1/7znmQfR8iM6dxA8z2yThwpUdRAXT4s4c16y0bAAAAFQDuy9XdUIOYTf0Cx4+cP5tZuTWyzQAAAIBjkkDeIAI44VdwTFzubnj5oLU9oXYahibPkTHKyFGVfp330s5+AnOFITXFULPiqCzM0/QiVqZjbWdwDClMIW4OzVbAs4zZ38bpbA08FfCXQ9t9Q2jp6sdI0iDX+ZgBkU1KuDl8uFYV+P0WPiG6nQ90+uo9FRtEuCZNehnKPMJFqgAAAIAoRslF1H+MLA471jndzHIkIGPA8bqKsGSgjSEFEsR1yTnqyVQf2PwrjtIv2PrARNaP76ekeYcYF4+Ql+88hcvfFMUejc4IUTJDQ7U8XL08CzkiG2hZfR5jXlxNoSHpISUE1eEBhYeks4HJV8JjjMyap5ccUoh40N9ezePKdrSjSQ==',
  }

  ## TODO install private key /root/.ssh/id_dsa

  ## TODO install /etc/ssh/ssh_known_hosts_local


}
