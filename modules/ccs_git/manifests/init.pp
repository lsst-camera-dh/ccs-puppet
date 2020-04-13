class ccs_git (Enum['present', 'latest'] $ensure = 'present') {

  $base = 'https://github.com/lsst-camera-dh'

  $repos = ['release', 'dev-package-lists']

  $dir = lookup('ccs_dirs::adm', String)

  $repos.each | String $repo | {
    vcsrepo { "${dir}/${repo}":
      ## Use latest to keep up-to-date (NB overwrites any local changes).
      ensure   => $ensure,
      provider => git,
      source   => "${base}/${repo}.git",
      owner    => 'ccs',
      group    => 'ccs',
    }
  }
}
