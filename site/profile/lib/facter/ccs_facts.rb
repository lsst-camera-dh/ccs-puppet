require 'facter'

## With a unique match, could use node instead.
Facter.add(:role) do
  setcode do
    hostname=Facter.value(:hostname)
    case hostname
    when /-(it|lt|aio|vw)\d/
      'desktop'
    when /-(uno|lion|hcu)\d/
      'hcu'
    when /-db\d/
      'database'
    when /-dc\d/
      'dc'
    when /-vi\d/
      'virt'
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

