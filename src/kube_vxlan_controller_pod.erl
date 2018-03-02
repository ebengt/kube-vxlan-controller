-module(kube_vxlan_controller_pod).

-export([
    filter/4,

    list/1, list/2,
    exec/5,

    vxlan_names/1
]).
    
-define(K8s, kube_vxlan_controller_k8s).
-define(Log, kube_vxlan_controller_log).

-define(LabelSelector, "vxlan=true").

-define(A8nVxlanNames, 'vxlan.travelping.com/names').
-define(A8nVxlanNamesSep, ", \n").

-define(ExecQuery, [
    {"stdout", "true"},
    {"stderr", "true"}
]).

filter(vxlan, VxlanName, PodName, Pods) ->
    [{binary_to_list(Name), binary_to_list(PodIp)} ||
     #{metadata := #{
        name := Name,
        annotations := Annotations
      },
      status := #{
        podIP := PodIp,
        phase := <<"Running">>
      }
     } <- Pods,
     lists:member(VxlanName, vxlan_names(Annotations)) andalso
     binary_to_list(Name) /= PodName
    ].

list(Config) -> list(false, Config).

list(Namespace, Config) ->
    Resource = case Namespace of
        false -> "/api/v1/pods/";
        Namespace -> "/api/v1/namespaces/" ++ Namespace ++ "/pods/"
    end,
    Query = [{"labelSelector", ?LabelSelector}],
    {ok, [#{items := Items}]} = ?K8s:http_request(Resource, Query, Config),
    Items.

exec(Namespace, PodName, ContainerName, Command, Config) ->
    ?Log:info("~s/~s/~s: ~s", [Namespace, PodName, ContainerName, Command]),

    Resource = "/api/v1/namespaces/" ++ Namespace ++
               "/pods/" ++ PodName ++ "/exec",

    Query = lists:foldl(
        fun(Arg, ExecQuery) -> [{"command", Arg}|ExecQuery] end,
        [{"container", ContainerName}|?ExecQuery],
        lists:reverse(string:split(Command, " ", all))
    ),

    case ?K8s:ws_connect(Resource, Query, Config) of
        {ok, Socket} ->
            {ok, Result} = ?K8s:ws_recv(Socket),
            ?K8s:ws_disconnect(Socket),
            ?Log:info("~s", [Result]),
            Result;
        {error, Reason} ->
            ?Log:error(Reason),
            ""
    end.

vxlan_names(Annotations) ->
    VxlanNames = binary_to_list(maps:get(?A8nVxlanNames, Annotations, <<>>)),
    string:lexemes(VxlanNames, ?A8nVxlanNamesSep).
