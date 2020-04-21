#!/bin/sh

fhost=${HOSTNAME%%.*}.slac.stanford.edu

## Hacky way to add a chef_ prefix to all variables.
knife node -c /root/.chef/knife.rb show $fhost -Fjson | sed 's/^ *"/ "chef_/g'
