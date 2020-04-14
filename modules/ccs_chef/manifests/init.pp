class ccs_chef {

  $fhost = $trusted['certname']

  unless $facts['chef_run_list'].any |$item| { $item =~ /role\[lsst\]/ } {
    exec { 'knife set role':
      cwd     => '/root',
      path    => [ '/usr/bin/' ],
      #unless => "sh -c \"knife node show $fhost -Fjson | grep -qF 'role[lsst]'\"",
      command => "knife node run_list add ${fhost} 'role[lsst]'",
    }
  }


  if $facts['role'] =~ /(desktop|virt)/ {

    #notify { "yum ${facts['chef_normal']['chef_yum_should']}": }
    unless $facts['chef_normal']['chef_yum_should'] == 'update everything' {
      exec { 'knife set yum update everything':
        cwd     => '/root',
        path    => [ '/usr/bin/' ],
        #unless => "sh -c \"knife node show $fhost -Fjson | grep -q 'yum_should.*update everything'\"",
        command => "knife node attribute set ${fhost} yum_should 'update everything'",
      }
    }

    unless $facts['native_gpfs'] == 'true' {
      #notify { "kernel ${facts['chef_normal']['chef_kernel_updatedefault']}": }
      unless $facts['chef_normal']['chef_kernel_updatedefault'] == 'yes' {
        exec { 'knife set kernel_updatedefault yes':
          cwd     => '/root',
          path    => [ '/usr/bin/' ],
          #unless => "sh -c \"knife node show $fhost -Fjson | grep -q 'kernel_updatedefault.*yes'\"",
          command => "knife node attribute set ${fhost} kernel_updatedefault 'yes'",
        }
      }
    }

  }                             # desktop

}
