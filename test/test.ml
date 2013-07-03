open Netlink

let _ =
	let s = Socket.alloc () in
	let _ = Socket.connect s Socket.NETLINK_ROUTE in

	let print_link_info link =
		let name = Link.get_name link in
		print_endline name;

		let mtu = Link.get_mtu link in
		Printf.printf "\tMTU: %d\n" mtu;

		let tx_bytes = Link.get_stat link Link.TX_BYTES in
		Printf.printf "\tTX bytes: %d\n" (Unsigned.UInt64.to_int tx_bytes);
		let rx_bytes = Link.get_stat link Link.RX_BYTES in
		Printf.printf "\tRX bytes: %d\n" (Unsigned.UInt64.to_int rx_bytes);
		let rx_errors = Link.get_stat link Link.RX_ERRORS in
		Printf.printf "\tRX errors: %d\n" (Unsigned.UInt64.to_int rx_errors);
		print_endline "";
	in
	let cache = Link.alloc_cache s in
	Link.iter_cache print_link_info cache;

	let _ = Socket.close s in
	Socket.free s

