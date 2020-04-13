class ccs_etc (String $dir = lookup('ccs_dirs::etc')) {

  $files = ['logging.properties', 'ccsGlobal.properties']

  $files.each |$file| {
    file { "${dir}/${file}":
      ensure => file,
      source => "puppet:///modules/${title}/${file}",
    }
  }


  $udp = 'udp_ccs.properties'

  file { "${dir}/${udp}":
    ensure => file,
    content => epp("${title}/${udp}", {'hostname' => $trusted['certname']}),
  }

}
