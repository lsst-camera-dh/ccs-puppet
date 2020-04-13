class ccs_power ( Boolean $install = true, Boolean $quadbox = false ) {

  $ensure = $install ? { true => 'file', default => 'absent' }

  file { '/etc/sudoers.d/poweroff':
    ensure => $ensure,
    source => "puppet:///modules/${title}/sudo-poweroff",
    mode   => '0440',
  }

  file { '/usr/local/libexec/poweroff':
    ensure => $ensure,
    source => "puppet:///modules/${title}/poweroff",
    mode   => '0755',
  }


  $files = ['CCS_POWEROFF',
            'CCS_REBOOT',
            'CCS_QUADBOX_POWEROFF'].filter |$elem| {
              $elem =~ /QUADBOX/ ? { true => $quadbox, default => true }
            }

  $files.each | String $file | {
    file { "/usr/local/bin/${file}":
      ensure => $ensure,
      source => "puppet:///modules/${title}/${file}",
      mode   => '0755',
    }
  }

}
