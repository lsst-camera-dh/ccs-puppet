class ccs_sal::rpms {

  ## Needed by ts_sal_utils.
  ensure_packages(['linuxptp'])

  $ccs_pkgarchive = lookup('ccs_pkgarchive', String)

  $ccs_sal::rpms.each |$package, $rpm| {

    $file = "/var/tmp/${rpm}"

    archive { $file:
      ensure => present,
      source => "${ccs_pkgarchive}/${rpm}",
    }

    package { $package:
      ensure   => 'latest',
      provider => 'rpm',
      source   => $file,
    }
  }

}
