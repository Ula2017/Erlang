%%%-------------------------------------------------------------------
%%% @author Ula
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. kwi 2017 13:07
%%%-------------------------------------------------------------------
-module(pollution).
-author("Ula").

%% API
-export([findName/2, findCore/2, createMonitor/0, addStation/3, addValue/5, removeValue/4,
  getOneValue/4, getTypeList/2, getStationMean/3, getDailyMean/3, getDateList/1, getList/4,
  mForOneStation/4, test/0, getAllStation/4, getNorm/2, getTupleVal/1, computeIndex/4, getAirQualityIndex/4]).

-record(station, {name, coordinates, list }).
-record(information, {date, time, type, value} ).

createMonitor() -> [].

findName(Name, L) -> lists:keymember(Name,2,L).

findCore({X,Y}, L) -> lists:keymember({X,Y}, 3, L).

addStation(Name, {X,Y}, L) ->
  case findName(Name, L) orelse findCore({X,Y}, L) of
    true ->io:format('The station exists.'), {error, "The station exists"};
    false -> [#station{ name = Name, coordinates ={X, Y}, list = [] }] ++ L
  end.

isMeasurementExist(L, Date, Time, Type, {_,_} )  ->
  ((lists:keymember(Date,2, L) and lists:keymember(Time, 3, L)) and lists:keymember(Type, 4, L )).


addValue({X,Y}, {Date, Time}, Type, Value, L) ->
  case lists:keyfind({X,Y},3, L) of
    false -> io:format("The station doesn't exist."), {error, "The station doesn't exist"};
    {station, Name, {X,Y}, L1 } -> case isMeasurementExist(L1, Date, Time, Type, {X,Y} ) of
                                        true -> io:format ('The value exists'), {error, "The value exists"};
                                        false -> lists:keyreplace({X,Y}, 3, L,#station{name=Name, coordinates={X,Y},
                                        list=[#information{date=Date, time=Time, type=Type, value=Value} | L1]} )

                                      end
  end;
addValue(Name, {Date, Time}, Type, Value, L) ->
  case lists:keyfind(Name,2, L) of
    false -> io:format("The station doesn't exist."), {error, "The station doesn't exist"};
    {station, Name, {X,Y}, L1 } -> case isMeasurementExist(L1, Date, Time, Type, {X,Y} ) of
                                     true -> io:format ('The value exists'), {error, "The value exists"};
                                     false -> lists:keyreplace({X,Y}, 3, L,#station{name=Name, coordinates={X,Y},
                                     list=[#information{date=Date, time=Time, type=Type, value=Value} | L1]} )

                                   end
  end.

getValue(Date, Time, Type, [{information, D, Ti, Ty, V} |_]) when ((D =:= Date) andalso (Ti =:=Time) andalso (Ty =:= Type)) -> V;
getValue(Date, Time, Type, [_| T]) -> getValue(Date, Time, Type, T).

removeValue({X,Y}, {Date, Time}, Type, L) ->
case lists:keyfind({X,Y},3, L) of
  false -> io:format('The station exists.'), {error, "The station exists"};
  {station, Name, {X,Y}, L1 } -> lists:keyreplace({X,Y}, 3, L,#station{name=Name,
  coordinates={X,Y}, list= L1 -- [#information{date=Date, time=Time, type=Type, value = getValue(Date, Time, Type, L1 )}]} )
end;
removeValue(Name, {Date, Time}, Type, L) ->
  case lists:keyfind(Name,2, L) of
    false -> io:format('The station exists.'), {error, "The station exists"};
    {station, Name, {X,Y}, L1 } -> lists:keyreplace({X,Y}, 3, L,#station{name=Name,
    coordinates={X,Y}, list= L1 -- [#information{date=Date, time=Time, type=Type, value = getValue(Date, Time, Type, L1 )}]} )
  end.

getOneValue(L,{X,Y},{Date, Time}, Type) ->
  case lists:keyfind({X,Y},3, L) of
    false -> io:format('The station exists.'), {error, "The station doent exist"};
    {station, _, {X,Y}, L1 } -> getValue(Date, Time, Type, L1)

  end;
getOneValue(L,Name,{Date, Time}, Type) ->
  case lists:keyfind(Name,2, L) of
    false -> io:format('The station exists.'), {error, "The station doent exist"};
    {station, Name, {_,_}, L1 } -> getValue(Date, Time, Type, L1)

  end.

getTypeList(L, Type) -> ([X#information.value || X<-L, X#information.type == Type]).

lengthOfList(L) -> lists:foldl(fun(_, Acc) -> 1 + Acc end, 0, L).
getStationMean({X,Y}, Type, L) ->
  case lists:keyfind({X,Y},3, L) of
    false -> io:format('The  jgbjbjk jbh station doent exists.'), {error, "The station doent exist"};
    {station, _, {X,Y}, L1 } -> lists:sum(getTypeList(L1, Type))/lengthOfList(getTypeList(L1,Type))
  end;
getStationMean(Name, Type, L) ->
  case lists:keyfind(Name,2, L) of
    false -> io:format('The  dududu station doent exists.'), {error, "The station doent exist"};
    {station, Name, {_,_}, L1 } -> lists:sum(getTypeList(L1, Type))/lengthOfList(getTypeList(L1,Type))

  end.

%% odtad co jeszcze nie zrobione

getAllStation([], L2, _, _) -> L2;
getAllStation([{station, _, _, List}], L2, D, Ty) -> mForOneStation(List, L2, D,Ty);
getAllStation([{station, _, _, List} |T], L2, D, Ty) -> mForOneStation(List, L2, D, Ty) ++ getAllStation(T, L2, D, Ty).

test() ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("Tarnow",{1,1},P),
  P2 = pollution:addStation("Krakow",{2,2},P1),
  P3 = pollution:addValue({1,1},{1,1},"T1",1,P2),
  P4 = pollution:addValue({1,1},{1,2},"T1",2,P3),
  P5 = pollution:addValue({1,1},{2,1},"T1",4,P4),
  P6 = pollution:addValue({1,1},{3,2},"T1",7,P5),
  P7 = pollution:addValue({1,1},{1,3},"T1",9,P6),
  P8 = pollution:addValue({1,1},{1,1},"war1",1,P7),
  P9 = pollution:addValue({1,1},{1,2},"war2",2,P8),
  P10 = pollution:addValue({1,1},{5,1},"T1",4,P9),
  P11 = pollution:addValue({1,1},{10,2},"war2",70,P10),
  P12 = pollution:addValue({1,1},{8,2},"war2",25,P11).


getDateList(L) ->([X#station.list || X <- L, X#station.list =/= [] ])

mForOneStation([], L2, _, _) -> L2;
mForOneStation([{information, Day, _, Type, Value}], L2, DayA, TypeA) when ((Day == DayA) andalso (Type == TypeA)) -> [Value] ++ L2;
mForOneStation([{information, Day, _, Type, Value} | T], L2, DayA, TypeA) when (Day =:= DayA andalso Type =:= TypeA) ->
  [Value] ++ mForOneStation(T, L2, DayA, TypeA);
mForOneStation( [_| T], L2, DayA, TypeA) -> mForOneStation(T, L2, DayA, TypeA).



getList([[]|T],Date, Time, Type ) -> getList(T, Date, Time, Type);
getList(L,Date, Time, Type ) -> ([X#information.value || X<-getDateList(L), X#information.type == Type, X#information.date == Date , X#information.time == Time]).
 when H =/= [] -> L ++ [H] ++ getLis


getDailyMean(L, Date, Type) -> lists:sum(getAllStation(L, [], Date, Type))/lengthOfList(getAllStation(L, [], Date, Type)).

getNorm(Name, PollutionList) -> lists:keysearch(Name, 1, PollutionList).

getTupleVal({value,{X,Y}}) -> Y.


computeIndex([],L1, PollutionList, Hour) -> L1;
computeIndex([{information, Day, Time, Type, Value}], L1, PollutionList, Hour)
when (Time =:= Hour) -> L1 ++ [(Value /getTupleVal(getNorm(Type, PollutionList))) * 100];
computeIndex([{information, Day, Time, Type, Value} | T], L1, PollutionList, Hour)
when (Time =:= Hour) -> L1 ++ [(Value /getTupleVal(getNorm(Type, PollutionList))) * 100] ++ computeIndex(T, L1, PollutionList, Hour);
computeIndex([_ | T], L1, PollutionList, Hour) -> computeIndex(T, L1, PollutionList, Hour);
computeIndex([H], L1, PollutionList, Hour) -> computeIndex([], L1, PollutionList, Hour).


getAirQualityIndex({X,Y}, Time, L, PollutionList ) ->
  case lists:keyfind({X,Y},3, L) of
    false -> io:format('The station exists.'), {error, "The station doent exist"};
    {station, Name, {X,Y}, L1 } -> lists:max(computeIndex(L1, [], PollutionList, Time))
  end.












