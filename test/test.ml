open Ctypes
open PosixTypes
open Foreign

type socket
type link

type protocol = NETLINK_ROUTE

let int_of_protocol = function
	| NETLINK_ROUTE -> 0

let protocol_of_int = function
	| _ -> NETLINK_ROUTE

let protocol = view ~read:protocol_of_int ~write:int_of_protocol int

let _ =
	(* open libnl *)

	let libnl = Dl.dlopen ~filename:"libnl-3.so" ~flags:[Dl.RTLD_NOW] in
	let libnl_route = Dl.dlopen ~filename:"libnl-route-3.so" ~flags:[Dl.RTLD_NOW] in

	(* setup ctypes *)

	let socket : socket structure typ = structure "nl_sock" in

	let nl_socket_alloc = foreign ~from:libnl "nl_socket_alloc" (void @-> returning (ptr socket)) in
	let nl_socket_free = foreign ~from:libnl "nl_socket_free" (ptr socket @-> returning void) in
	let nl_connect = foreign ~from:libnl "nl_connect" (ptr socket @-> protocol @-> returning int) in
	let nl_close = foreign ~from:libnl "nl_close" (ptr socket @-> returning int) in

	let nl_cache = ptr void in
	let link : link structure typ = structure "rtnl_link" in

	let rtnl_link_alloc_cache = foreign ~from:libnl_route "rtnl_link_alloc_cache"
		(ptr socket @-> int @-> ptr nl_cache @-> returning int) in

	let rtnl_link_get_by_name = foreign ~from:libnl_route "rtnl_link_get_by_name"
		(nl_cache @-> string @-> returning (ptr link)) in

	let rtnl_link_get_mtu = foreign ~from:libnl_route "rtnl_link_get_mtu"
		(ptr link @-> returning int) in

	(* main *)

	print_endline "started.";
	let s = nl_socket_alloc () in
	let _ = nl_connect s NETLINK_ROUTE in

	let cache = allocate nl_cache null in
	let _ = rtnl_link_alloc_cache s 0 cache in
	let link = rtnl_link_get_by_name (!@ cache) "eth0" in
	let mtu = rtnl_link_get_mtu link in
	Printf.printf "MTU: %d\n" mtu;

	let _ = nl_close s in
	nl_socket_free s;
	print_endline "done."


