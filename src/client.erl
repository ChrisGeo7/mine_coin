-module(client).
-export([call_server/2]).
-import_module(server).


call_server(User, IP)->
    HostName=User++"@"++IP,
    io:fwrite("~s~n",[HostName]),
    
    SuccessValue=net_kernel:connect_node('chris@127.0.0.1'),
    io:fwrite("Connection : ~w",[SuccessValue]),
    server:ping().
