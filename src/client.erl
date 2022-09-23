-module(client).
-export([call_server/1,stop_timer/0]).
-import_module(server).


stop_timer() ->
    receive
        _ ->
            {_,WallClock} = statistics(wall_clock),
            {_,CPUClock} =  statistics(runtime),
            io:fwrite("~nCLIENT TIMER : ~w CPU : ~w  Core Ratio : ~w ~n",[WallClock,CPUClock,CPUClock/WallClock]),
            halt()
    end.

call_server(User)->
    io:fwrite("Connecting to ~s~n",[User]),
    net_kernel:connect_node(User),
    register(stopTimer,spawn(node(),client,stop_timer,[])),
    {serverProcess, User} ! {self(),node()},
    receive
        {HashZero, ActorCount} ->
            io:fwrite("~n Connected to server, Starting to mine, zeroCount : ~p",[HashZero]),
            statistics(wall_clock),
            statistics(runtime),
            mine:spawn_actors(node(),HashZero,ActorCount)
    end.