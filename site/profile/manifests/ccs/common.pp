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
  include profile::ccs::desktop

  ## These will be replaced by some other alerting/monitoring system.
  include profile::ccs::monit
  include profile::ccs::mrtg

}
