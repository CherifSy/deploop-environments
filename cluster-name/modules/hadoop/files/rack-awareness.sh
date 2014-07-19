#!/bin/bash
#
# Set rack id based on IP address. Assumes network 
# administrator has complete control over IP addresses 
# assigned to nodes and they are in the 10.x.y.z address space. 
# Assumes that:
# IP addresses are distributed hierarchically as:
#
# 10.<DataCenter>.<Rack>.z
#
# 10.1.y.z is one data center segment 
# 10.2.y.z is another data center segment.
#
# Within the same data center 1:
#
# 10.1.1.z is one rack
# 10.1.2.z is another rack in
#
# This is invoked with an IP address as its only argument
#
# Examples:
#
# rack-awareness.sh 10.1.1.10
# /dc1/rack1
# rack-awareness.sh 10.1.2.10
# /dc1/rack2
# rack-awareness.sh 10.2.1.20
# /dc2/rack1

# get IP address from the input
ipaddr=$1

# select "x.y" from IO and convert it to "dcx/racky"
segments=`echo $ipaddr | cut --delimiter=. --fields=2-3 --output-delimiter=/rack`
echo /dc${segments}




