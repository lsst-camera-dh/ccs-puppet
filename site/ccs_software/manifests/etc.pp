## @summary
##   Install /etc/ccs files.
##
## @param dir
##   String giving the location of the /etc/ccs directory.

class ccs_software::etc (String $dir) {

  ## FIXME use hiera.
  $attributes = {
    'owner' => 'ccsadm',
    'group' => 'ccsadm',
  }

  $ptitle = regsubst($title, '::.*', '', 'G')

  $files = ['logging.properties', 'ccsGlobal.properties']

  $files.each |$file| {
    file { "${dir}/${file}":
      ensure => file,
      source => "puppet:///modules/${ptitle}/${file}",
      *      => $attributes,
    }
  }


  $udp = 'udp_ccs.properties'

  file { "${dir}/${udp}":
    ensure  => file,
    content => epp("${ptitle}/${udp}", {'hostname' => $trusted['certname']}),
    *       => $attributes,
  }

}
