-module(mine).
-export([mine_coin/0,spawn_actors/3,start_actors/2]).

match(ZeroCount,String) ->
    Pattern = "^0{"++integer_to_list(ZeroCount)++"}.*$",
    case re:run(String,Pattern) of 
        {match,_} -> true;
        nomatch -> false
        end.

mine_coin() ->
    % Write a pattern matching function for this regex
    receive
        {Master, HashZero}->
            % io:fwrite("~nInside MINING from ~w",[Master]),
            % Million = "1000000000000",
            NumOfChar= rand:uniform(16),
            RandomString = "christy.george;" ++ base64:encode(crypto:strong_rand_bytes(NumOfChar)),
            HashString = io_lib:format("~64.16.0b", [binary:decode_unsigned(crypto:hash(sha256,RandomString))]),
            % SubString = lists:sublist(HashString,HashZero),
            % LeadingZeroString = lists:sublist(Million,2,HashZero),
            % Status= string:equal(SubString,LeadingZeroString),
            % io:fwrite("~nCompleted MINING Status ~w ~w",[self(),Status]),
            Status = match(HashZero,HashString),
            if(Status==true)->
                Master ! {self(), RandomString, HashString}
            ;(Status==false)->
                self() ! {Master,HashZero},
                mine_coin()
            end
    end.

spawn_actors(_, _,ActorCount) when ActorCount ==0 ->
    true;

spawn_actors(Node, HashZero, ActorCount) when ActorCount > 0 ->
    Pid = spawn(Node, mine, start_actors, [Node, HashZero]),
    io:fwrite("~nSpawned : ~w",[Pid]),
    spawn_actors(Node, HashZero, ActorCount - 1).

start_actors(Node, HashZero)  ->
    Pid = spawn(Node, mine, mine_coin, []),
    Pid ! {self(), HashZero},
    receive
        {Pid, RandomString, HashString}->
                io:fwrite("~n PID: ~w found a coin", [self()]),
                {collectorProcess, node()} ! {node(),RandomString, HashString}
    end,
    start_actors(Node,HashZero).
