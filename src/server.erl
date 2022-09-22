-module(server).
-export([start/1,connect_worker/1,collector/0]).
-import_module([mine]).

connect_worker(HashZero)->
    receive
        {Worker,Node} -> %BUT WHY!!!!!
            io:fwrite("~nCLIENT CONNECTED... ~w ~w",[Worker,Node]),
            Worker ! HashZero
    end,
    connect_worker(HashZero).

collector()->
    receive
        {Node, RandomString, HashString}->
            io:fwrite("~nNode ~w Random String:~s Coin:~s",[Node,RandomString, HashString])
    end,
    collector().

%add clock
%add provision to get input coin number
%
start(HashZero) ->
    io:fwrite("~nStarting Server..."),
    register(serverProcess,spawn(node(),server,connect_worker,[HashZero])),
    register(collectorProcess,spawn(node(),server,collector,[])),
    mine:spawn_actors(node(),HashZero,10).
    