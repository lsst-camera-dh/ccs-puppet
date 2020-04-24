## @summary
##   Add desktop menu entries for CCS apps.

class ccs_software::desktop {

  file { ['/etc/xdg/menus', '/etc/xdg/menus/applications-merged',
          '/usr/share/desktop-directories',
          '/usr/share/applications', '/usr/share/icons']:
            ensure => directory,
  }

  $ptitle = regsubst($title, '::.*', '', 'G')

  $files = ['/etc/xdg/menus/applications-merged/lsst.menu',
            '/usr/share/desktop-directories/lsst.directory',
            ## TODO not a great icon.
            '/usr/share/icons/lsst_appicon.png']

  $files.each |String $file| {
    file { $file:
      ensure => present,
      source => "puppet:///modules/${ptitle}/${basename($file)}",
    }
  }


  $apps = ['console', 'shell']

  $apps.each |String $app| {
    ['prod', 'dev'].each |String $version| {
      case $version {
        'prod': {
          $desc = 'production'
        }
        'dev': {
          $desc = 'development'
        }
        default: { }
      }
      case $app {
        'console': {
          $terminal = false
        }
        'shell': {
          $terminal = true
        }
        default: { }
      }
      file { "/usr/share/applications/lsst.ccs.${app}.${version}.desktop":
        ensure  => file,
        content => epp(
          "${ptitle}/lsst.ccs.APP.VERSION.desktop.epp",
          {
            version  => $version,
            app      => $app,
            desc     => $desc,
            terminal => $terminal,
          }),
      }
    }
  }


}
