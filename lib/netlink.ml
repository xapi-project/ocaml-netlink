open Ctypes
open Foreign

type socket

type protocol = NETLINK_ROUTE

let int_of_protocol = function
	| NETLINK_ROUTE -> 0

let protocol_of_int = function
	| _ -> NETLINK_ROUTE

let protocol = view ~read:protocol_of_int ~write:int_of_protocol int

let libnl = Dl.dlopen ~filename:"libnl-3.so" ~flags:[Dl.RTLD_NOW]

let socket : socket structure typ = structure "nl_sock"

let socket_alloc = foreign ~from:libnl "nl_socket_alloc" (void @-> returning (ptr socket))
let socket_free = foreign ~from:libnl "nl_socket_free" (ptr socket @-> returning void)
let connect = foreign ~from:libnl "nl_connect" (ptr socket @-> protocol @-> returning int)
let close = foreign ~from:libnl "nl_close" (ptr socket @-> returning int)

module Route = struct
	type link

	let libnl_route = Dl.dlopen ~filename:"libnl-route-3.so" ~flags:[Dl.RTLD_NOW]

	let cache = ptr void
	let link : link structure typ = structure "rtnl_link"

	let link_alloc_cache = foreign ~from:libnl_route "rtnl_link_alloc_cache"
		(ptr socket @-> int @-> ptr cache @-> returning int)

	let link_get_by_name = foreign ~from:libnl_route "rtnl_link_get_by_name"
		(cache @-> string @-> returning (ptr link))

	let link_get_mtu = foreign ~from:libnl_route "rtnl_link_get_mtu"
		(ptr link @-> returning int)
end

