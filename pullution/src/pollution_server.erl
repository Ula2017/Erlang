%%%-------------------------------------------------------------------
%%% @author Ula
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. maj 2017 16:11
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("Ula").

%% API
-import(pollution,[createMonitor/0,isMeasurementExist/5,addValue/5, findName/2, findCore/2, createMonitor/0, addStation/3, addValue/5, removeValue/4, getOneValue/4, getTypeList/2, getStationMean/3, getDailyMean/3, getDateList/1, getList/4,mForOneStation/4, test/0, getAllStation/4]).

-export([start/0, stop/0, loop/1]).
start() ->
  register(svPollution,  spawn(fun() -> loop(pollution:createMonitor()) end)).

loop(Monitor) ->
  receive
    {addStation,Name,{X,Y}} ->
      P = addStation(Name,{X,Y},Monitor),
      case P of
        {error, _} ->
          ("~n not ok.~n"),
          loop(Monitor);
        _ ->
          io:format("ok.~n"),
          loop(P)
      end;

    {addValue,{X,Y},{Day,Hour},Type,Value} ->
      P = addValue({X,Y},{Day,Hour},Type,Value,Monitor),
      case P of
        {error, _} ->
        io:format("~n not ok.~n"),
        loop(Monitor);
        _ ->
          io:format("ok.~n"),
          loop(P)
      end;

    {addValue,Name,{Day,Hour},Type,Value} ->
      P = addValue(Name,{Day,Hour},Type,Value,Monitor),
      case P of
        {error, _} ->
          io:format("~n not ok.~n"),
          loop(Monitor);
        _ ->
          io:format("ok.~n"),
          loop(P)
      end;
    {getOneValue,{X,Y},{Day,Hour}, Type } ->
      P = getOneValue(Monitor,{X,Y},{Day,Hour}, Type ),
      case P of
        {error, _} ->
          io:format("~n not ok.~n"),
          loop(Monitor);
        _ ->
          io:format("ok.~n"),
          loop(P)
      end;
    {getOneValue,Name,{Day,Hour}, Type } ->
      P = getOneValue(Monitor,Name,{Day,Hour}, Type ),
      case P of
        {error, _} ->
          io:format("~n not ok.~n"),
          loop(Monitor);
        _ ->
          io:format("ok.~n"),
          loop(P)
      end;
    {removeValue,{X,Y},{Day,Hour},Type} ->
      P = removeValue({X,Y}, {Day,Hour}, Type, Monitor),
      case P of
        {error, _} ->
          io:format("~n not ok.~n"),
          loop(Monitor);
        _ ->
          io:format("ok.~n"),
          loop(P)
      end;
    {removeValue,Name,{Day,Hour},Type} ->
      P = removeValue(Name, {Day,Hour}, Type, Monitor),
      case P of
        {error, _} ->
          io:format("~n not ok.~n"),
          loop(Monitor);
        _ ->
          io:format("ok.~n"),
          loop(P)
      end;
    printMonitor ->
      io:format("ok~n"),
      [io:format("~p ~n",[X])|| X <- Monitor],
      loop(Monitor);
    {getDailyMean,Day,Type} ->
      io:format("ok.~n"),
      getDailyMean(Monitor,Day, Type),
      loop(Monitor);
    {getStationMean,{X,Y},Type} ->
      P = getStationMean(Monitor, {X,Y}, Type),
      case P of
        {error, _} ->
          io:format("~n not ok.~n"),
          loop(Monitor);
        {N} ->
          io:fwrite("~p ~n",[N]),
          loop(P)
      end;
    {getStationMean,Name,Type} ->
      P = getStationMean(Monitor, Name, Type),
      case P of
        {error, _} ->
          io:format("~n not ok.~n"),
          loop(Monitor);
        {N} ->
          io:fwrite("~p ~n",[N]),
          loop(P)
      end;
    quit -> io:format("stop")
  end.

stop() ->
  svPollution ! quit.