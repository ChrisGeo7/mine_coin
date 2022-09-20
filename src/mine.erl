-module(mine).
-export([mine_coin/0]).

mine_coin() ->
    % Write a pattern matching function for this regex
    % Have a control over the number of workers to be spawned!
    receive
        {Master, HashZero}->
            % io:fwrite("~nInside MINING from ~w",[Master]),
            Million = "1000000000000",
            NumOfChar= rand:uniform(16),
            RandomString = "christy.george;" ++ base64:encode(crypto:strong_rand_bytes(NumOfChar)),
            HashString = io_lib:format("~64.16.0b", [binary:decode_unsigned(crypto:hash(sha256,RandomString))]),
            SubString = lists:sublist(HashString,HashZero),
            LeadingZeroString = lists:sublist(Million,2,HashZero),
            Status= string:equal(SubString,LeadingZeroString),
            % io:fwrite("~nCompleted MINING Status ~w ~w",[self(),Status]),
            if(Status==true)->
                Master ! {self(), Status, RandomString, HashString}
            ;(Status==false)->
                % io:fwrite("~nCall self ~w ~p",[Master,HashZero]),
                self() ! {Master,HashZero}
                % io:fwrite("OVER")
            end
    end,
    mine_coin().