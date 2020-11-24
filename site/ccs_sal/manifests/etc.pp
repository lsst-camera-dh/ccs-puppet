class ccs_sal::etc {

  $dir = '/etc/ccs'

  $attributes = {
    'owner' => 'ccsadm',
    'group' => 'ccsadm',
    'mode'  => '0644',
  }


  $ptitle = regsubst($title, '::.*', '', 'G')

  $salfile = 'setup-sal5'

  file { "${dir}/${salfile}":
    ensure  => file,
    content => epp("${ptitle}/${salfile}", {
      'domain' => $ccs_sal::dds_domain,
      'home'   => $ccs_sal::ospl_home,
    }
                  ),
    *       => $attributes,
  }


  $osplfile = 'ospl5.xml'

  ## Note that this will not pick up any changes in the distribution file.
  ## You would have to force it by eg deleting the destination file.
  exec { "Create ${dir}/${osplfile}":
    path    => ['/usr/bin'],
    command => @("CMD"/L),
      sh -c "sed 's|^\( *<NetworkInterfaceAddress>\).*|\
      \1${ccs_sal::address}</NetworkInterfaceAddress>|' \
      ${ccs_sal::ospl_home}/etc/config/ospl.xml > \
      ${dir}/${osplfile}"
      | CMD
    unless  => "grep -q ${ccs_sal::address} ${dir}/${osplfile}",
    user    => $attributes['owner'],
  }


  $qosfile = 'QoS5.xml'

  file { "${dir}/${qosfile}":
    ensure => file,
    source => "puppet:///modules/${ptitle}/${qosfile}",
    *      => $attributes,
  }


  $instrument = $ccs_sal::instrument

  $bridge = "${dir}/ocs-bridge-${instrument}.app"
  $gui = "${dir}/ocs-bridge-${instrument}.app"

  ['bridge', 'gui'].each|$thing| {
    $file = "${dir}/ocs-${thing}-${instrument}.app"
    file { $file:
      ensure  => present,
      content => "system.pre-execute=${salfile}\n",
      *       => $attributes,
    }
  }


}
