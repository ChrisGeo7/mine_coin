-module(server).
-export([start/2,connect_worker/2,collector/1]).
-import_module([mine]).

connect_worker(HashZero, ActorCount)->
    receive
        {Worker,Node} -> %BUT WHY!!!!!
            io:fwrite("~nCLIENT CONNECTED... ~w ~w",[Worker,Node]),
            Worker ! {HashZero, ActorCount}
    end,
    connect_worker(HashZero,ActorCount).

collector(CoinCount) when CoinCount == 0->
    io:fwrite("~nCollection done"),
    {_,WallClock} = statistics(wall_clock),
    {_,CPUClock} =  statistics(runtime),
    lists:foreach(fun(Node) ->
                {stopTimer, Node} ! {self(),node()},
                io:fwrite("~nSent stop to Node ~w",[Node])
            end, nodes()),
     
    io:fwrite("~nTIMER : ~w CPU : ~w  Core Ratio : ~w ~n",[WallClock,CPUClock,CPUClock/WallClock]),
    halt();

collector(CoinCount) when CoinCount > 0-> 
    receive
        {Node, RandomString, HashString}->
            io:fwrite("~nNode ~w Random String:~s Coin:~s",[Node,RandomString, HashString])
    end,
    collector(CoinCount - 1).

%add clock
%add provision to get input coin number
%
start(HashZero, CoinCount) ->
    io:fwrite("~nStarting Server..."),
    ActorCount = 50,
    statistics(wall_clock),
    statistics(runtime),
    register(serverProcess,spawn(node(),server,connect_worker,[HashZero,ActorCount])),
    register(collectorProcess,spawn(node(),server,collector,[CoinCount])),
    mine:spawn_actors(node(),HashZero,ActorCount).
    