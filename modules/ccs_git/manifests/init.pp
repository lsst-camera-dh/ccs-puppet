class ccs_git (Enum['present', 'latest'] $ensure = 'present') {

  $base = 'https://github.com/lsst-camera-dh'

  $repos = ['release', 'dev-package-lists']

  $dirs = lookup('ccs_dirs::dirs', Hash)
  $dir = $dirs['ccsadm']['path']

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
