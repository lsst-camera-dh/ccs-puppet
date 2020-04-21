## @summary
##   Add (or remove) hcu shutdown utilities
##
## @param ensure
##   String saying whether to install ('present') or remove ('absent').
## @param quadbox
##   Boolean true on quadbox hosts
class profile::ccs::power (String $ensure = 'absent', Boolean $quadbox = false) {

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
