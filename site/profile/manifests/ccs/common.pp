## @summary
##   Common settings for all CCS hosts.

class profile::ccs::common {

  if $facts['site'] == 'slac' {
    include profile::slac::common
  }

  include profile::ccs::facts

  include profile::ccs::users

  include profile::ccs::packages          # needs pkgarchive

  include profile::ccs::clustershell

  include profile::ccs::dirs

  include profile::ccs::etc

  include profile::ccs::git

  include profile::ccs::profile_d

  include profile::ccs::scripts

  include profile::ccs::sudo

  include profile::ccs::sysctl

  include profile::ccs::jdk8


  ### Remaining items are host-specific.

  include profile::ccs::desktop

  include profile::ccs::graphical

  include profile::ccs::network

  include profile::ccs::autologin

  include profile::ccs::database

  ## HCU-specific.
  include profile::ccs::canbus
  include profile::ccs::vldrive
  include profile::ccs::imanager
  include profile::ccs::filter_changer
  include profile::ccs::power

  ## For high-resolution displays.
  include profile::ccs::jdk11
  include profile::ccs::nvidia

  ## These will be replaced by some other monitoring.
  include profile::ccs::monit
  include profile::ccs::mrtg

}
