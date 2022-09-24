-module(server).
-export([start/2,connect_worker/3,collector/1]).

connect_worker(HashZero, ActorCount, TotalCores)->
    receive
        {Worker,Node, Cores} -> %BUT WHY!!!!!
            counterProcess ! {self()},
            receive
                CoinCount ->
                    WorkRatio = Cores/(TotalCores + Cores),
                    WorkLoad = trunc(WorkRatio * CoinCount),
                    io:fwrite("~nCLIENT CONNECTED...~w~n Cores available :~w Giving workload of ~w",[Node,Cores, WorkLoad]),
                    counterProcess ! CoinCount - WorkLoad,
                    Worker ! {HashZero, ActorCount, WorkLoad}
            end,
            connect_worker(HashZero,ActorCount, TotalCores + Cores)
    end.

collector(CoinCount) when CoinCount==0 ->
    halt();

collector(CoinCount)-> 
    receive
        {Node, RandomString, HashString}->
            io:fwrite("~nInput String: ~s Coin: ~s Found by ~w",[RandomString, HashString, Node]),
            collector(CoinCount -1 )
    end.

start(HashZero, CoinCount) ->
    io:fwrite("~nStarting Server..."),
    ActorCount = 50,
    ServerCores=erlang:system_info(logical_processors_available),
    statistics(wall_clock),
    statistics(runtime),
    register(counterProcess, spawn(mine, counter,[CoinCount])),
    register(collectorProcess,spawn(node(),server,collector,[])),
    register(serverProcess,spawn(node(),server,connect_worker,[HashZero,ActorCount,ServerCores])),
    mine:spawn_actors(HashZero,ActorCount, node()).
    