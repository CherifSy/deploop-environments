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

# Base configuration variables

$extlookup_datadir="/etc/puppet/manifests/extdata"
$extlookup_precedence = ["site", "default"]

# defaults
$puppetserver = 'puppet'
$jdk_package_name = extlookup("jdk_package_name", "jdk")
$default_buildoop_yumrepo_uri = "http://buildooprepo:8080/"

# 
# We set this varialbe for sanity check. Only hosts
# inside Puppet environment 'production' have to entry
# in this catalog.
#
$environment_match = 'production'


# This main loop is designed in order to handle three kind of 
# operational enviroments:
#
#  - production: the live enviroment
#  - preproduction: the staging enviroment
#  - test: the sandbox and integration test enviroment.
#
# Note: this configuration of environments is based on facts, which
# are dinamycs in Deploop. We are not using the "puppet environment"
# feature, so we don't need modify the puppet.conf agent.
node default {
  case $::deploop_collection {
    $environment_match: {
      case $::deploop_category {
        batch: {
          info("[deploop] Node in Production=>Batch path category: ${fqdn}")
          include batch-path
        }
        realtime: {
          info("[deploop] Node in Production=>RealTime path category: ${fqdn}")
          include realtime-path
        }
        bus: {
          info("[deploop] Node in Production=>Bus path category: ${fqdn}")
          include bus-path
        }
        default: {
          info("[deploop] ERROR uncategorized Production node ${fqdn}")
        }
      }
    }
    default: {
      info("[deploop] ERROR no Production collection for this node ${fqdn}")
      info("[deploop] ERROR the deploop_collection fact is: ${deploop_collection}")
    }
  }
}

# vim: autoindent tabstop=2 shiftwidth=2 expandtab softtabstop=2 filetype=ruby
