#!/bin/sh

function get_devmem()
{
	/usr/bin/devmem2 $1 | grep ": " | cut -d ":" -f 2|cut -d "x" -f 2
}

function hex_to_mac_addr()
{
	addr=$1
	n=0
	mac_addr=$(echo ${addr} | while read -r -n2 c; do 
		if [ ! -z "$c" ]; then
			if [ $n -ne 0 ] ; then
				echo -n ":${c}"
			else
				echo -n "${c}"
			fi
		fi
		n=$(($n+1))
	done)
	echo ${mac_addr}
}

function reverse_bytes()
{
	addr=$1
	New_addr=$(echo ${addr} | while read -r -n2 c; do 
		if [ ! -z "$c" ]; then
			New_addr=${c}${New_addr}
		else echo
			echo ${New_addr}
		fi
	done)
	echo ${New_addr}
}

DEVMEM_ADDR_LO=$(get_devmem 0x44e10638|bc)
DEVMEM_ADDR_LO=$(reverse_bytes ${DEVMEM_ADDR_LO})

DEVMEM_ADDR_HI=$(get_devmem 0x44e1063C)
DEVMEM_ADDR_HI=$(reverse_bytes ${DEVMEM_ADDR_HI})

DEV_ADDR=$(hex_to_mac_addr "${DEVMEM_ADDR_HI}${DEVMEM_ADDR_LO}")

modprobe g_ether host_addr=${DEV_ADDR}
