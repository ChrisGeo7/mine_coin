-module(server).
-export([ping/0,server_start/1]).
-import_module([mine]).

ping()->
    io:fwrite("~nCLIENT PINGED!!!"),
    ServerProcess = registered(),
    io:fwrite("~n Found Serverprocess ~w",[ServerProcess]),
    ServerProcess ! self(),
    
    receive
        {HashZero} ->
            start_actors(node(),HashZero,10,1000000)
    end.

start_actors(_, _,ActorCount,CoinCount) when ActorCount ==0 ->
     io:fwrite("~n~w Coins mined",[CoinCount]),
     exit;

start_actors(Node, HashZero, ActorCount, CoinCount) when ActorCount > 0  ->
    io:fwrite("~nNode ~w",[Node]),
    Pid = spawn(Node, mine, mine_coin, []),
    io:fwrite("Actor ~w spawned by ~w", [Pid,self()]),
    Pid ! {self(), HashZero},
    receive
        {Pid, Status, RandomString, HashString}->
            if(Status == true) ->
                io:fwrite("~nRandom String:~s Coin:~s",[RandomString, HashString]),
                start_actors(Node,HashZero, ActorCount - 1, CoinCount - 1)
            ; (Status == false) ->
                Pid ! {self()}
            end
    end,
    start_actors(Node, HashZero, ActorCount - 1, CoinCount).

server_start(HashZero) ->
    register(serverProcess, self()),
    start_actors(node(),HashZero,10,1000000),

    receive
        {Worker} -> 
            Worker ! HashZero
    end.
    