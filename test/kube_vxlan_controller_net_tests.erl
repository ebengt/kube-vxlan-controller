-module( kube_vxlan_controller_net_tests ).

-include_lib("eunit/include/eunit.hrl").


cmd_test() ->
	Options = [{"aname", #{dev => "adev", id => "anid", name => "aname", type => "atype"}}],
	Pod = #{nets => Options},
	Net = "aname",

	Cmd = kube_vxlan_controller_net:cmd("ip link add ~s type ~s id ~s dev ~s dstport 0", [name, type, id, dev], Pod, Net),

	Expected = "ip link add aname type atype id anid dev adev dstport 0",
	?assert( Cmd =:= Expected ).

link_add_command_test() ->
	Options = #{dev => "adev", id => "anid", name => "aname", type => "atype"},

	Cmd = kube_vxlan_controller_net:link_add_command(Options),

	Expected = "ip link add aname type atype id anid dev adev",
	?assert( Cmd =:= Expected ).

link_add_command_dstport_test() ->
	Options = #{dev => "adev", dstport => "1", id => "anid", name => "aname", type => "atype"},

	Cmd = kube_vxlan_controller_net:link_add_command(Options),

	Expected = "ip link add aname type atype id anid dev adev dstport 1",
	?assert( Cmd =:= Expected ).

link_add_command_srcport_test() ->
	Options = #{dev => "adev", srcport => "1 2", id => "anid", name => "aname", type => "atype"},

	Cmd = kube_vxlan_controller_net:link_add_command(Options),

	Expected = "ip link add aname type atype id anid dev adev srcport 1 2",
	?assert( Cmd =:= Expected ).
