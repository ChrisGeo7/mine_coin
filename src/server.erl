-module(server).
-export([start_actors/4,server_start/1,connect_worker/1,collector/0]).
-import_module([mine]).

start_actors(_, _,ActorCount,_) when ActorCount ==0 ->
    %  io:fwrite("~n~w Coins mined",[CoinCount]),
     exit;

start_actors(Node, HashZero, ActorCount, CoinCount) when ActorCount > 0  ->
    Pid = spawn(Node, mine, mine_coin, []),
    % io:fwrite("Actor ~w spawned by ~w", [Pid,self()]),
    Pid ! {self(), HashZero},
    receive
        {Pid, Status, RandomString, HashString}->
            if(Status == true) ->
                {collectorProcess, 'chris@127.0.0.1'} ! {node(),RandomString, HashString},
                start_actors(Node,HashZero, ActorCount - 1, CoinCount - 1)
            ; (Status == false) ->
                Pid ! {self()}
            end
    end,
    start_actors(Node, HashZero, ActorCount - 1, CoinCount).

connect_worker(HashZero)->
    io:fwrite("~nWAITING FOR WORKER..."),
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

server_start(HashZero) ->
    io:fwrite("~nStarting Server..."),
    register(serverProcess,spawn(node(),server,connect_worker,[HashZero])),
    register(collectorProcess,spawn(node(),server,collector,[])),
    start_actors(node(),HashZero,10,14).

    