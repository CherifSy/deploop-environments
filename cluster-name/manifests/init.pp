# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require utils
# Base configuration variables
$extlookup_datadir=inline_template("/etc/puppet/environments/<%= Puppet.lookup(:current_environment) %>/extdata")
$extlookup_precedence = ["site", "default"]

# defaults
$puppetserver = 'puppet'
$default_buildoop_yumrepo_uri = extlookup('buildoop_yumrepo_uri', "http://buildooprepo:8080/")
$jdk_package_name = extlookup("jdk_package_name", "jdk")

# 
# We set this varialbe for sanity check. Only hosts
# inside Puppet environment 'environment name' have to entry
# in this catalog.
$environment_match = inline_template("<%= Puppet.lookup(:current_environment) %>")

define parsecategories {
    case $name {
        batch: {
          info("[deploop][${fqdn}] Node in [environment] -> ${environment_match} [category] -> ${name}")
          include batch_path
        }
        speed: {
          info("[deploop][${fqdn}] Node in [environment] -> ${environment_match} [category] -> ${name}")
          include realtime_path
        }
        bus: {
          info("[deploop][${fqdn}] Node in [environment] -> ${environment_match} [category] -> ${name}")
          include bus_path
        }
        serving: {
          info("[deploop][${fqdn}] Node in [environment] -> ${environment_match} [category] -> ${name}")
          include serving_path
        }
        kdc: {
          # This category is only for deploy KDC in the Deploop Master node or
          # a dedicated system.
          info("[deploop][${fqdn}] Node in Production=>Key Distribution Center category")
          include kdc_path
        }
        default: {
          info("[deploop][${fqdn}] ERROR uncategorized Production node")
        }

      }
}

# This selector is designed in order to handle three kind of 
# operational enviroments or clusters:
#
#  - The batch cluster
#  - The online or realtime cluster.
#  - The bus collector cluster.
#
# Note: this configuration of environments is based on facts, which
# are dinamycs in Deploop. 
node default {

  case $::deploop_collection {
    $environment_match: {
      $array_of_categories = split($deploop_category, ' ')
      parsecategories { $array_of_categories: }
    }
    default: {
      info("[deploop][${fqdn}] ERROR no valid collection for this node")
      info("[deploop][${fqdn}] ERROR the deploop_collection fact is: ${deploop_collection}")
    }
  }

}

# vim: autoindent tabstop=2 shiftwidth=2 expandtab softtabstop=2 filetype=ruby
