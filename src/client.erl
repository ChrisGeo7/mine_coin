-module(client).
-export([call_server/2]).
-import_module(server).


call_server(User, IP)->
    HostName=User++"@"++IP,
    io:fwrite("~s~n",[HostName]),
    
    SuccessValue=net_kernel:connect_node('chris@127.0.0.1'),
    io:fwrite("Connection : ~w",[SuccessValue]),

    {serverProcess, 'chris@127.0.0.1'} ! {self(),node()},
    io:fwrite("Yayyyyyyy : ~w",[SuccessValue]),
    receive
        HashZero ->
            io:fwrite("~nCLIENT PINGED!!! Got HASHZERO ~p",[HashZero]),
            server:start_actors(node(),HashZero,10,1000000)
    end.