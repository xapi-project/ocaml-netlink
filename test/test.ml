open Ctypes

let _ =
	print_endline "started.";
	let s = Netlink.socket_alloc () in
	let _ = Netlink.connect s Netlink.NETLINK_ROUTE in

	let cache = allocate Netlink.Route.cache null in
	let _ = Netlink.Route.link_alloc_cache s 0 cache in
	let link = Netlink.Route.link_get_by_name (!@ cache) "eth0" in
	let mtu = Netlink.Route.link_get_mtu link in
	Printf.printf "MTU: %d\n" mtu;

	let tx_bytes = Netlink.Route.link_get_stat link Netlink.Route.TX_BYTES in
	Printf.printf "TX bytes: %d\n" (Unsigned.UInt64.to_int tx_bytes);
	let rx_bytes = Netlink.Route.link_get_stat link Netlink.Route.RX_BYTES in
	Printf.printf "RX bytes: %d\n" (Unsigned.UInt64.to_int rx_bytes);

	let _ = Netlink.close s in
	Netlink.socket_free s;
	print_endline "done."

