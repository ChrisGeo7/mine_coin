-module(client).
-export([call_server/1]).
-import_module(server).

call_server(Server)->
    io:fwrite("Connecting to ~s~n",[Server]),
    net_kernel:connect_node(Server),
    ClientCores = erlang:system_info(logical_processors_available),
    {serverProcess, Server} ! {self(),node(),ClientCores},
    receive
        {HashZero, ActorCount, CoinCount} ->
            io:fwrite("~n Connected to server, Starting to mine... ~nNumber of Coins to mine ~w~n",[CoinCount]),
            statistics(wall_clock),
            statistics(runtime),
            register(counterProcess, spawn(mine, counter,[CoinCount])),
            mine:spawn_actors(HashZero,ActorCount, Server)
    end.