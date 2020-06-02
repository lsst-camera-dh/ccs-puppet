## @summary
##   Install CCS release and dev-package-lists from git.
##
## @param dir
##   Directory to install to (normally /opt/lsst/ccsadm).
##
## @param ensure
##   'present' (default) or 'latest'

class ccs_software::git (
  String $dir,
  Enum['present', 'latest'] $ensure = 'present',
) {

  $base = 'https://github.com/lsst-camera-dh'

  $repos = ['release', 'dev-package-lists']

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
