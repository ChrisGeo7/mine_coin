-module(client).
-export([call_server/2]).
-import_module(server).


call_server(User, IP)->
    HostName=User++"@"++IP,
    io:fwrite("~s~n",[HostName]),
    net_kernel:connect_node('chris@127.0.0.1'),

    {serverProcess, 'chris@127.0.0.1'} ! {self(),node()},
    receive
        HashZero ->
            io:fwrite("~nCLIENT PINGED!!! Got HASHZERO ~p",[HashZero]),
            main:spawn_actors(node(),HashZero,10)
    end.