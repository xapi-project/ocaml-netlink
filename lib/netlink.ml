open Ctypes
open Foreign

type socket

type protocol = NETLINK_ROUTE

let int_of_protocol = function
	| NETLINK_ROUTE -> 0

let protocol_of_int = function
	| 0 -> NETLINK_ROUTE
	| _ -> invalid_arg "protocol"

let protocol = view ~read:protocol_of_int ~write:int_of_protocol int

let libnl = Dl.dlopen ~filename:"libnl-3.so" ~flags:[Dl.RTLD_NOW]

let socket : socket structure typ = structure "nl_sock"

let socket_alloc = foreign ~from:libnl "nl_socket_alloc" (void @-> returning (ptr socket))
let socket_free = foreign ~from:libnl "nl_socket_free" (ptr socket @-> returning void)
let connect = foreign ~from:libnl "nl_connect" (ptr socket @-> protocol @-> returning int)
let close = foreign ~from:libnl "nl_close" (ptr socket @-> returning int)

module Route = struct
	type link

	type link_stat_id = RX_PACKETS | TX_PACKETS | RX_BYTES | TX_BYTES

	let int_of_link_stat_id = function
		| RX_PACKETS -> 0
		| TX_PACKETS -> 1
		| RX_BYTES -> 2
		| TX_BYTES -> 3

	let link_stat_id_of_int = function
		| 0 -> RX_PACKETS
		| 1 -> TX_PACKETS
		| 2 -> RX_BYTES
		| 3 -> TX_BYTES
		| _ -> invalid_arg "link_stat_id"

	let link_stat_id = view ~read:link_stat_id_of_int ~write:int_of_link_stat_id int

	let libnl_route = Dl.dlopen ~filename:"libnl-route-3.so" ~flags:[Dl.RTLD_NOW]

	let cache = ptr void
	let link : link structure typ = structure "rtnl_link"

	let link_alloc_cache = foreign ~from:libnl_route "rtnl_link_alloc_cache"
		(ptr socket @-> int @-> ptr cache @-> returning int)

	let link_get_by_name = foreign ~from:libnl_route "rtnl_link_get_by_name"
		(cache @-> string @-> returning (ptr link))

	let link_get_mtu = foreign ~from:libnl_route "rtnl_link_get_mtu"
		(ptr link @-> returning int)

	let link_get_stat = foreign ~from:libnl_route "rtnl_link_get_stat"
		(ptr link @-> link_stat_id @-> returning uint64_t)
end

