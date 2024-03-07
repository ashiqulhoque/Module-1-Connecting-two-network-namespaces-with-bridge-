# Module-1-Connecting-two-network-namespaces-with-bridge-

﻿## Module 2 Networking Project
**Project Description:** Make two network namespaces using 'red' and 'green' names, connect them with a bridge, and check connectivity. You have to successfully ping Google's public IP from those network namespaces.
## Work Through

![img](diagram.png#center)
*A simple diagram to visualize what we we'll do in this project*

**Step-0:** Install necessary packages or tools in Linux machine using following command

    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install iptables iproute2 iputils-ping net-tools -y

**Step-1:** Create two network namespaces (*red and green*)

    sudo ip netns add red
	sudo ip netns add green

**Step-2:** Create a bridge (*br0*) network on the host. `Up` the created bridge and check whether it is created and in UP/UNKNOWN state.

    sudo ip link add br0 type bridge
	sudo ip link set br0 up
	
	#to make sure it's state run this command
	sudo ip link show type bridge

**Step-3:** Now, we need to create two `veth` interfaces for two network namespaces, then attach them to the bridge and namespaces accordingly.

    #creating veths
    sudo ip link add veth-red type veth peer name veth-red-br
	sudo ip link add veth-green type veth peer name veth-green-br
	
	#attaching with namespaces
	sudo ip link set dev veth-red netns red
	sudo ip link set dev veth-green netns green
	
	#attaching with bridge
	sudo ip link set dev veth-red-br master br0
