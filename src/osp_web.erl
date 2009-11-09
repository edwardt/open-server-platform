%% @author Jacob Torrey <torreyji@clarkson.edu>
%% @copyright 2009 Jacob Torrey <torreyji@clarkson.edu>
%% @doc Provides the httpd and web interface for OSP
-module(osp_web).
-export([start/0, reload/0, stop/1, clusterwide/3, upload/3]).

-define(CONF_FILE, "include/httpd.conf").

%% @doc Starts the OSP Web server
%% @spec start() -> {ok, pid()}
start() ->
    {ok, [Conf]} = file:consult(?CONF_FILE),
    {ok, Pid} = inets:start(httpd, Conf),
    Pid.

%% @doc Reloads the webserver configuration from file
%% @spec reload() -> ok
reload() ->
    {ok, [Conf]} = file:consult(?CONF_FILE),
    httpd:reload_config(Conf, non_disturbing).

%% @doc Stops the Inets web service
stop(Pid) ->
    inets:stop(httpd, Pid).

%% @doc Parses an input string into a list of tuples
%% @spec parse_input(string()) -> list()
parse_input(Input) ->
    Args = string:tokens(Input, "&"),
    F = fun(E) ->
		[Key, Value] = string:tokens(E, "="),
		{erlang:list_to_atom(Key), Value}
	end,
    lists:map(F, Args).

%% @doc Converts a UNIX newline to a HTML <br />
%% @spec nl2br(string()) -> string()
nl2br(Str) ->
    Tokens = string:tokens(Str, "$\n"),
    string:join(Tokens, "\n<br />").

%% @doc Adds support for uploading a servlet
%% @spec upload(any(), list(), string()) -> ok, {error, Reason}
upload(Session, _Env, Input) ->
    mod_esi:deliver(Session, io_lib:format("~p", [Input])).

%% @doc Writes a servlet to disk and returns its filename
%% @spec parse_upload(string()) -> string()
parse_upload(Input) ->
    

%% @doc Provides cluster wide ajax callbacks for the web administrative system
%% @spec(any(), list(), string()) -> ok | {error, Reason}
clusterwide(Session, _Env, Input) ->
    Args = parse_input(Input),
    {value, {operation, Op}} = lists:keysearch(operation, 1, Args),
    case Op of
	"shutdown" ->
	    mod_esi:deliver(Session, "Content-type: text/plain\r\n\r\n" ++ "OSP Shutdown"),
	    osp_manager:shutdown_osp();
	"stats" ->
	    mod_esi:deliver(Session, ct_string(html) ++ nl2br(osp_manager:stats()));
	"uptime" ->
	    mod_esi:deliver(Session, ct_string(text) ++ osp_manager:uptime());
	"nodes" ->
	    mod_esi:deliver(Session, ct_string(text) ++ erlang:integer_to_list(length([node() | nodes()])));
	"appnode" ->
	    mod_esi:deliver(Session, ct_string(json) ++ json_nodeapp(osp_manager:nodeapp()));
	"apps" ->
	    mod_esi:deliver(Session, ct_string(json) ++ json_apps());
	_ ->
	    mod_esi:deliver(Session, "")
    end.

%% @doc Returns a Content-Type string for a given MIME type
%% @spec ct_string(atom()) -> string()
ct_string(text) ->
    "Content_type: text/plain\r\n\r\n";
ct_string(html) ->
    "Content_type: text/html\r\n\r\n";
ct_string(json) ->
    "Content_type: application/json\r\n\r\n";
ct_string(_) ->
    "Content_type: text/plain\r\n\r\n"

json_apps() ->
    "".

%% @doc JSONizes the nodeapp information for the web application frontend
%% @spec json_nodeapp(list()) -> string()
json_nodeapp(NA) ->
    F1 = fun({App, Port}, Str) ->
		 Str ++ "{\"name\": \"" ++ erlang:atom_to_list(App) ++ "\", \"port\": \"" ++ erlang:integer_to_list(Port) ++ "\"}"
	 end,
    F2 = fun({Node, Applist}, Str) ->
		 Str ++ "{\"node\": \"" ++ erlang:atom_to_list(Node) ++ "\", \"running_apps\": [" ++ lists:foldl(F1, "", Applist) ++ "]}"
	 end,
    "[" ++ lists:foldl(F2, "", NA) ++ "]".
