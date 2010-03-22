-behavior(osp_servlet).

% Export OSP server callback
-export([start_mnesia/0, server/1, init/0, cleanup/0, proto/0]).

% Import the OSP socket library
-import(osp_socket, [send/2, recv/2, sendf/3, close/1]).
% Import the OSP shared state library
-import(osp_mnesia, [start_atomic/0]).
% Import a configuration helper function
-import(osp, [get_conf/2]).

% Define the Mnesia record
-record(osp_table, {key, val}).

-define(MODULE_table, erlang:list_to_atom(?MODULE_STRING ++ "_table")).

%% @doc Opens a file for reading or writing
fopen(Filename, Flags) ->
    osp_file:fopen(?MODULE, Filename, Flags).

%% @doc Stores a value in the mnesia database
store(Key, Val) ->
    osp_mnesia:store(?MODULE_table, Key, Val).

%% @doc Gets a value from the mnesia database
retrieve(Key) ->
    osp_mnesia:retrieve(?MODULE_table, Key).

%% @doc Flushes the transactional variables
flush() ->
    osp_mnesia:flush(?MODULE_table).

%% @doc The mnesia startup routine
start_mnesia() ->
    case lists:member(mnesia_sup, erlang:registered()) of
	true ->
	    ok;
	false ->
	    mnesia:start()
    end,
    case catch(mnesia:table_info(?MODULE_table, all)) of
	{'EXIT', _} ->
	    mnesia:create_table(?MODULE_table, [{record_name, osp_table}, {attributes, record_info(fields, osp_table)}]);
	_ ->
	    ok
    end,
    ok.

%% @doc The main server loop
