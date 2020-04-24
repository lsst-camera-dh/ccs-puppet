## @summary
##   Common settings for all CCS hosts.

class profile::ccs::common {

  include profile::ccs::facts
  include profile::ccs::users
  include profile::ccs::clustershell

  include ccs_software

  include profile::ccs::profile_d
  include profile::ccs::sudo

  ## These will be replaced by some other alerting/monitoring system.
  include profile::ccs::monit
  include profile::ccs::mrtg

}
