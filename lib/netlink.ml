open Ctypes
open Foreign

let libnl = Dl.dlopen ~filename:"libnl-3.so" ~flags:[Dl.RTLD_LAZY]
let libnl_route = Dl.dlopen ~filename:"libnl-route-3.so" ~flags:[Dl.RTLD_LAZY]

module Socket = struct
	type t
	let t : t structure typ = structure "nl_sock"

	type protocol = NETLINK_ROUTE

	let int_of_protocol = function
		| NETLINK_ROUTE -> 0

	let protocol_of_int = function
		| 0 -> NETLINK_ROUTE
		| _ -> invalid_arg "protocol"

	let protocol = view ~read:protocol_of_int ~write:int_of_protocol int

	let alloc = foreign ~from:libnl "nl_socket_alloc" (void @-> returning (ptr t))
	let free = foreign ~from:libnl "nl_socket_free" (ptr t @-> returning void)

	exception Connect_failed

	let connect' = foreign ~from:libnl "nl_connect" (ptr t @-> protocol @-> returning int)
	let connect s p =
		let ret = connect' s p in
		if ret = 0 then
			()
		else
			raise Connect_failed

	let close = foreign ~from:libnl "nl_close" (ptr t @-> returning void)
end

module Cache = struct
	let t = ptr void

	let iter f cache ty =
		let callback_t = ptr ty @-> ptr void @-> returning void in
		let foreach = foreign ~from:libnl "nl_cache_foreach"
			(t @-> funptr callback_t @-> ptr void @-> returning void) in
		let f' x _ = f x in
		foreach (!@ cache) f' null

	let to_list cache ty =
		let get_first = foreign ~from:libnl "nl_cache_get_first" (t @-> returning (ptr ty)) in
		let get_prev = foreign ~from:libnl "nl_cache_get_prev" (ptr ty @-> returning (ptr ty)) in
		let get_last = foreign ~from:libnl "nl_cache_get_last" (t @-> returning (ptr ty)) in

		let first = get_first (!@ cache) in
		let rec loop obj ac =
			if obj = first then
				obj :: ac
			else
				loop (get_prev obj) (obj :: ac)
		in
		loop (get_last (!@ cache)) []
end

module Link = struct
	type t

	type stat_id = RX_PACKETS | TX_PACKETS | RX_BYTES | TX_BYTES | RX_ERRORS | TX_ERRORS

	let int_of_stat_id = function
		| RX_PACKETS -> 0
		| TX_PACKETS -> 1
		| RX_BYTES -> 2
		| TX_BYTES -> 3
		| RX_ERRORS -> 4
		| TX_ERRORS -> 5

	let stat_id_of_int = function
		| 0 -> RX_PACKETS
		| 1 -> TX_PACKETS
		| 2 -> RX_BYTES
		| 3 -> TX_BYTES
		| 4 -> RX_ERRORS
		| 5 -> TX_ERRORS
		| _ -> invalid_arg "stat_id"

	let stat_id = view ~read:stat_id_of_int ~write:int_of_stat_id int

	let t : t structure typ = structure "rtnl_link"

	let alloc_cache' = foreign ~from:libnl_route "rtnl_link_alloc_cache"
		(ptr Socket.t @-> int @-> ptr Cache.t @-> returning int)

	let cache_alloc s =
		let cache = allocate Cache.t null in
		let _ = alloc_cache' s 0 cache in
		cache

	let cache_iter f cache =
		Cache.iter f cache t

	let cache_to_list cache =
		Cache.to_list cache t

	let get_by_name = foreign ~from:libnl_route "rtnl_link_get_by_name"
		(Cache.t @-> string @-> returning (ptr t))

	let put = foreign ~from:libnl_route "rtnl_link_put"
		(ptr t @-> returning void)

	let get_name = foreign ~from:libnl_route "rtnl_link_get_name"
		(ptr t @-> returning string)

	let get_mtu = foreign ~from:libnl_route "rtnl_link_get_mtu"
		(ptr t @-> returning int)

	let get_stat = foreign ~from:libnl_route "rtnl_link_get_stat"
		(ptr t @-> stat_id @-> returning uint64_t)
end

