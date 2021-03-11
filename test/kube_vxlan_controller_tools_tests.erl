-module( kube_vxlan_controller_tools_tests ).

-include_lib("eunit/include/eunit.hrl").

%% Something, somewhere, removes ':' from config.


pod_nets_test() ->
	Pod_nets = kube_vxlan_controller_tools:pod_nets( "vxeth0: id=1000 dev=tun0\nvxeth1: id=1001 up", #{} ),

	One = proplists:get_value( "vxeth0:", Pod_nets ),
	Expected_1 = #{dev => "tun0", id => "1000", name => "vxeth0:", type => "vxlan"},
	?assert( One =:= Expected_1 ),
	Two = proplists:get_value( "vxeth1:", Pod_nets ),
	Expected_2 = #{dev => "eth0", id => "1001", name => "vxeth1:", type => "vxlan", up => true},
	?assert( Two =:= Expected_2 ).

pod_nets_dstport_test() ->
	Pod_nets = kube_vxlan_controller_tools:pod_nets( "name: id=1 dstport=1234", #{} ),

	Value = proplists:get_value( "name:", Pod_nets ),
	Expected = #{dev => "eth0", id => "1", name => "name:", type => "vxlan", dstport => "1234"},
	?assert( Value =:= Expected ).

pod_read_net_option_srcport_test() ->
	Port = kube_vxlan_controller_tools:pod_read_net_option( "srcport=1-2" ),

	Expected = {srcport, "1 2"},
	?assert( Port =:= Expected ).

pod_nets_srcport_test() ->
	Pod_nets = kube_vxlan_controller_tools:pod_nets( "name: id=1 srcport=1234-2345 up", #{} ),

	Value = proplists:get_value( "name:", Pod_nets ),
	Expected = #{dev => "eth0", id => "1", name => "name:", srcport => "1234 2345", type => "vxlan", up => true},
	?assert( Value =:= Expected ).
