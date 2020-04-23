## @summary
##   Common settings for all CCS hosts.

class profile::ccs::common {

  include profile::ccs::facts

  include profile::ccs::users

  include profile::ccs::clustershell

  include profile::ccs::dirs

  include profile::ccs::etc

  include profile::ccs::git

  include profile::ccs::profile_d

  include profile::ccs::scripts

  include profile::ccs::sudo

  include profile::ccs::sysctl

  include profile::ccs::jdk8

  ## These will be replaced by some other monitoring.
  include profile::ccs::monit
  include profile::ccs::mrtg

  ### Remaining items are host-specific.

  include profile::ccs::desktop # needs pkgarchive

  include profile::ccs::graphical

  include profile::ccs::network

}
