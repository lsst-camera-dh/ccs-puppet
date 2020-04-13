class ccs_desktop {

  file { ['/etc/xdg/menus', '/etc/xdg/menus/applications-merged',
          '/usr/share/desktop-directories',
          '/usr/share/applications', '/usr/share/icons']:
            ensure => directory,
  }


  $files = ['/etc/xdg/menus/applications-merged/lsst.menu',
            '/usr/share/desktop-directories/lsst.directory',
            ## FIXME not a great icon.
            '/usr/share/icons/lsst_appicon.png']

  $files.each |String $file| {
    file { "${file}":
      source => "puppet:///modules/${title}/${basename($file)}",
      ensure => present,
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
      }
      case $app {
        'console': {
          $terminal = false
        }
        'shell': {
          $terminal = true
        }
      }
      file { "/usr/share/applications/lsst.ccs.${app}.${version}.desktop":
        ensure => file,
        content => epp("${title}/lsst.ccs.APP.VERSION.desktop.epp",
                       {version => $version, app => $app,
                         desc => $desc, terminal => $terminal} ),
      }
    }
  }


}
