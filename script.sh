sudo apt-get update
sudo apt-get upgrade
sudo apt-get install iproute2 iputils-ping net-tools -y

sudo ip netns add blue-ns
sudo ip netns add gray-ns
sudo ip netns add lime-ns

sudo ip link add dev v-net type bridge
sudo ip link set dev v-net up

sudo ip address add 10.0.0.1/24 dev v-net

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

sudo ip netns exec blue-ns ip address add 10.0.0.11/24 dev veth-blue-ns
sudo ip netns exec gray-ns ip address add 10.0.0.21/24 dev veth-gray-ns
sudo ip netns exec lime-ns ip address add 10.0.0.31/24 dev veth-lime-ns

sudo ip netns exec blue-ns ip route add default via 10.0.0.1
sudo ip netns exec gray-ns ip route add default via 10.0.0.1
sudo ip netns exec lime-ns ip route add default via 10.0.0.1

sudo iptables --append FORWARD --in-interface v-net --jump ACCEPT
sudo iptables --append FORWARD --out-interface v-net --jump ACCEPT

# From lime-ns
sudo ip netns exec lime-ns ping -c 2 10.0.0.11
# From gray-ns
sudo ip netns exec gray-ns ping -c 2 10.0.0.11
# From blue-ns
sudo ip netns exec blue-ns ping -c 2 10.0.0.21
