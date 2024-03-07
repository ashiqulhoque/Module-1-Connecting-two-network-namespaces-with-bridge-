## Module-1-Connecting-two-network-namespaces-with-bridge-

**Project Description:** Make three network namespaces using 'red' and 'green' names, connect them with a bridge, and check connectivity.

**Step-0:** Lets install necessary packages or tools in Linux 
     
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install iproute2 iputils-ping net-tools -y

**Step-1:** Create three network namespaces (*blue-ns ,gray-ns and lime-ns*)

	sudo ip netns add blue-ns
	sudo ip netns add gray-ns
	sudo ip netns add lime-ns

**Step-2:** Create a bridge (*v-net*) network on the host. And set the state to `Up`


    sudo ip link add dev v-net type bridge
    sudo ip link set dev v-net up

**Step-3:** Asign IP address to the bridge 

	sudo ip address add 10.0.0.1/24 dev v-net

**Step-4:** Create three `veth` interfaces and attach them to the bridge and namespaces accordingly.

    # creating veths
    sudo ip link add veth-blue-ns type veth peer name veth-blue-br
    sudo ip link add veth-gray-ns type veth peer name veth-gray-br
    sudo ip link add veth-lime-ns type veth peer name veth-lime-br
	
	# attaching with namespaces
	sudo ip link set dev veth-blue-ns netns blue-ns
	sudo ip link set dev veth-gray-ns netns gray-ns
	sudo ip link set dev veth-lime-ns netns lime-ns
	
	# attaching other ends with bridge
	sudo ip link set dev veth-blue-br master v-net
	sudo ip link set dev veth-gray-br master v-net
	sudo ip link set dev veth-lime-br master v-net

 **Step-5:** Setting all the cable interfaces `Up`

	# Set the bridge interfaces up:
	sudo ip link set dev veth-blue-br up
	sudo ip link set dev veth-gray-br up
	sudo ip link set dev veth-lime-br up
	# Set the namespace interfaces up:
	sudo ip netns exec blue-ns ip link set dev veth-blue-ns up
	sudo ip netns exec gray-ns ip link set dev veth-gray-ns up
	sudo ip netns exec lime-ns ip link set dev veth-lime-ns up
 	# to see all interfaces are currently in UP state
  	sudo ip link show 
   
   **Step-6:** Assign IP addresses to the virtual interfaces within each namespace.
   
	sudo ip netns exec blue-ns ip address add 10.0.0.11/24 dev veth-blue-ns
	sudo ip netns exec gray-ns ip address add 10.0.0.21/24 dev veth-gray-ns
	sudo ip netns exec lime-ns ip address add 10.0.0.31/24 dev veth-lime-ns
 
 **Step-7:** Set the default routes for network namespaces

	 sudo ip netns exec blue-ns ip route add default via 10.0.0.1
	 sudo ip netns exec gray-ns ip route add default via 10.0.0.1
	 sudo ip netns exec lime-ns ip route add default via 10.0.0.1

  
**Step-8:**  Add firewall rules in iptable. 

	sudo iptables --append FORWARD --in-interface v-net --jump ACCEPT
	sudo iptables --append FORWARD --out-interface v-net --jump ACCEPT

These rules enabled traffic to travel across the v-net virtual bridge.These are useful to allow all traffic to pass through the v-net interface without any restrictions.

**Step-9:** Test connectivity from each namespaces

	# From lime-ns
	sudo ip netns exec lime-ns ping -c 2 10.0.0.11
	# From gray-ns
	sudo ip netns exec gray-ns ping -c 2 10.0.0.11
	# From blue-ns
	sudo ip netns exec blue-ns ping -c 2 10.0.0.21

