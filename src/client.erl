-module(client).
-export([call_server/1]).
-import_module(server).


call_server(User)->
    io:fwrite("Connecting to ~s~n",[User]),
    net_kernel:connect_node(User),
    {serverProcess, User} ! {self(),node()},
    receive
        HashZero ->
            io:fwrite("~n Connected to server, Starting to mine, zeroCount : ~p",[HashZero]),
            mine:spawn_actors(node(),HashZero,10)
    end.