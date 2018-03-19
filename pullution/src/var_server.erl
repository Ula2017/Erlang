%%%-------------------------------------------------------------------
%%% @author Ula
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. maj 2017 12:17
%%%-------------------------------------------------------------------
-module(var_server).
-author("Ula").

-behaviour(gen_server).

%% API
-export([start_link/0,init/1, handle_call/3,  handle_cast/2,terminate/2, handle_info/2,code_change/3, addStation/2, addValue/4, removeValue/3, getOneValue/3, getStationMean/2, getDailyMean/2]).

%% gen_server callbacks
%%-export([init/1,
%%  handle_call/3,
%%  handle_cast/2,
%%  handle_info/2,
%%  terminate/2,
%%  code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {}).

start_link() ->
  gen_server:start_link({local, var_server}, var_server, [], []).

init([]) ->
  {ok, pollution:createMonitor()}.

%%cast
addStation(Name, {X,Y}) ->
  gen_server:call(var_server, {addStation, Name, {X,Y}}).

addValue({X,Y}, {Date, Time}, Type, Value) ->
  gen_server:call(var_server, {addValue, {X,Y}, {Date, Time}, Type, Value});
addValue(Name, {Date, Time}, Type, Value) ->
  gen_server:call(var_server, {addValue, Name, {Date, Time}, Type, Value}).

removeValue({X,Y}, {Date, Time}, Type) ->
  gen_server:cast(var_server, {removeValue,{X,Y}, {Date, Time}, Type});
removeValue(Name, {Date, Time}, Type) ->
  gen_server:cast(var_server, {removeValue,Name, {Date, Time}, Type}).


crash() ->
  gen_server:call(var_server, {crash}).

getOneValue({X,Y},{Date, Time}, Type) ->
  gen_server:call(var_server, {getOneValue,{X,Y},{Date, Time}, Type});
getOneValue(Name,{Date, Time}, Type) ->
  gen_server:call(var_server, {getOneValue, Name,{Date, Time}, Type}).

getStationMean({X,Y}, Type) ->
  gen_server:call(var_server, {getStationMean,{X,Y}, Type});
getStationMean(Name, Type) ->
  gen_server:call(var_server, {getStationMean,Name, Type}).

getDailyMean(Date, Type) ->
  gen_server:call(var_server, {getDailyMean, Date, Type}).

handle_call({addStation, Name, {X,Y}}, _, State ) ->
  P = pollution:addStation(Name, {X,Y}, var_server),
  case  P of
    {error, _} -> {replay, error,state};
    _ -> {replay, ok, P}
  end;
handle_call({addValue, {X,Y}, {Date, Time}, Type, Value}, _, var_server ) ->
  P = pollution:addValue({X,Y}, {Date, Time}, Type, Value, var_server),
  case  P of
    {error, _} -> {replay, {error, "Station exists"},var_server};
    _ -> {replay,  ok, P}
  end;
handle_call({addValue, Name, {Date, Time}, Type, Value}, _, var_server ) ->
  P = pollution:addValue(Name, {Date, Time}, Type, Value, var_server),
  case  P of
    {error, _} -> {replay, {error, "Station exists"},var_server};
    _ -> {replay,  ok, P}
  end;
handle_call({getOneValue,{X,Y},{Date, Time}, Type}, _, var_server ) ->
  P = pollution:getOneValue(var_server, {X,Y},{Date, Time}, Type),
  case  P of
    {error, _} -> {replay, {error, "Station exists"},var_server};
    _ -> {replay, ok, P}
  end;
handle_call({getOneValue,Name,{Date, Time}, Type}, _, var_server ) ->
  P = pollution:getOneValue(var_server, Name,{Date, Time}, Type),
  case  P of
    {error, _} -> {replay, {error, "Station exists"},var_server};
    _ -> {replay,  ok, P}
  end;
handle_call({getStationMean,{X,Y}, Type}, _, var_server ) ->
  P = pollution:getStationMean({X,Y}, Type, var_server),
  case  P of
    {error, _} -> {replay, {error, "Station exists"},var_server};
    _ -> {replay,  ok, P}
end;
handle_call({getStationMean,Name, Type}, _, var_server ) ->
  P = pollution:getStationMean(Name, Type, var_server),
  case  P of
    {error, _} -> {replay, {error, "Station exists"},var_server};
    _ -> {replay,  ok, P}
  end;
handle_call({getDailyMean, Date, Type}, _, var_server ) ->
  P = pollution:getDailyMean(Date, Type, var_server),
  case  P of
    {error, _} -> {replay, {error, "Station exists"},var_server};
    _ -> {replay,  ok, P}
  end;
handle_call({crash}, _, var_server) ->
  {reply, 1/0, var_server}.


handle_cast(_Request, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.


