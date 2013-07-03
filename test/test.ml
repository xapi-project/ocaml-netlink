open Netlink

let _ =
	let s = Socket.alloc () in
	Socket.connect s Socket.NETLINK_ROUTE;

	let cache = Link.cache_alloc s in

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
	print_endline "== Print interfaces using Link.cache_iter ==\n";
	Link.cache_iter print_link_info cache;

	print_endline "== Print interfaces using Link.cache_to_list and List.iter ==\n";
	let l = Link.cache_to_list cache in
	List.iter print_link_info l;

	Socket.close s;
	Socket.free s

