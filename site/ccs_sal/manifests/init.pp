## @summary
##   Install stuff for CCS/SAL gateway.
##
## @param rpms
##   Hash of packages and rpms to install. Eg:
##   "ts_sal_utils" => "ts_sal_utils-4.0.0-1.x86_64.rpm"
## @param address
##   String giving ip address of SAL interface
## @param ospl_home
##   String giving OSPL_HOME.
## @param dds_domain
##   String giving LSST_DDS_DOMAIN (eg base)
## @param instrument
##   String giving instrument (eg comcam).

class ccs_sal (
  Hash[String,String,2] $rpms,
  String $address = '127.0.0.1',
  String $ospl_home = '/opt/OpenSpliceDDS/V6.9.0/HDE/x86_64.linux',
  String $dds_domain = 'base',
  String $instrument = 'comcam',
) {

  include ccs_sal::rpms
  include ccs_sal::etc

}
