require 'facter'

## With a unique match, could use node instead.
Facter.add(:role) do
  setcode do
    hostname=Facter.value(:hostname)
    case hostname
    when /-vw\d/
      'ccs-viswork'
    when /-mcm/
      'ccs-mcm'
    when /-(it|lt|aio)\d/
      'ccs-desktop'
    when /-(uno|lion|hcu)\d/
      'ccs-hcu'
    when /-db\d/
      'ccs-database'
    when /-dc\d/
      'ccs-dc'
    when /-vi\d/
      'ccs-virt'
    end
  end
end

Facter.add(:site) do
  setcode do
    network=Facter.value(:network)
    case network
    when /^134\.79\./
      'slac'
    when /^(140\.252|10\.0\.103)\./
      'tu'
    when '139.229.150.0'
      'ls'
    when '139.229.174.0'
      'cp'
    else
      'unknown'
    end
  end
end

