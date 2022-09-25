-module(mine).
-export([mine_coin/0,spawn_actors/3,start_actors/2,counter/1]).

match(ZeroCount,String) ->
    Pattern = "^0{"++integer_to_list(ZeroCount)++"}.*$",
    case re:run(String,Pattern) of 
        {match,_} -> true;
        nomatch -> false
        end.

mine_coin() ->
    receive
        {Caller, HashZero}->
            NumOfChar= rand:uniform(16),
            RandomString = "christy.george;" ++ base64:encode(crypto:strong_rand_bytes(NumOfChar)),
            HashString = io_lib:format("~64.16.0b", [binary:decode_unsigned(crypto:hash(sha256,RandomString))]),
            Status = match(HashZero,HashString),
            if(Status==true)->
                Caller ! {self(), RandomString, HashString},
                {counterProcess,node()} ! {true,1}
            ;(Status==false)->
                self() ! {Caller,HashZero},
                mine_coin()
            end
    end.

spawn_actors(_,ActorCount, _) when ActorCount ==0 ->
    true;

spawn_actors(HashZero, ActorCount, CollectorNode) when ActorCount > 0 ->
    spawn(mine, start_actors, [HashZero, CollectorNode]),
    spawn_actors(HashZero, ActorCount - 1, CollectorNode).

start_actors(HashZero, CollectorNode)  ->
    Pid = spawn(mine, mine_coin, []),
    Pid ! {self(), HashZero},
    receive
        {Pid, RandomString, HashString}->
                {collectorProcess, CollectorNode} ! {node(),RandomString, HashString}
    end,
    start_actors(HashZero, CollectorNode).

counter(CoinCount) when CoinCount ==0 ->
    io:fwrite("~nMining completed..."),
    {_,WallClock} = statistics(wall_clock),
    {_,CPUClock} =  statistics(runtime),
    io:fwrite("~nTIMER : ~w CPU : ~w  Core Ratio : ~w ~n",[WallClock,CPUClock,CPUClock/WallClock]);
    halt();


counter(CoinCount) -> 
    receive
        {Caller}->
            Caller ! CoinCount,
            counter(CoinCount);
        {true,1}->
            counter(CoinCount-1);
        NewCoinCount->
            counter(NewCoinCount)
    end.