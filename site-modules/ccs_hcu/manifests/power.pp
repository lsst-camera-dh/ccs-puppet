## @summary
##   Add (or remove) hcu shutdown utilities
##
## @param ensure
##   String saying whether to install ('present') or remove ('absent').
## @param quadbox
##   Boolean true on quadbox hosts
class ccs_hcu::power (String $ensure = 'absent', Boolean $quadbox = false) {

  $ptitle = regsubst($title, '::.*', '', 'G')

  file { '/etc/sudoers.d/poweroff':
    ensure => $ensure,
    source => "puppet:///modules/${ptitle}/sudo-poweroff",
    mode   => '0440',
  }

  file { '/usr/local/libexec/poweroff':
    ensure => $ensure,
    source => "puppet:///modules/${ptitle}/poweroff",
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
      source => "puppet:///modules/${ptitle}/${file}",
      mode   => '0755',
    }
  }

}
