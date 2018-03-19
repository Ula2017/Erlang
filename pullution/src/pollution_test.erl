%%%-------------------------------------------------------------------
%%% @author Ula
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. maj 2017 23:48
%%%-------------------------------------------------------------------
-module(pollution_test).
-author("Ula").

-include_lib("eunit/include/eunit.hrl").

simple_test() ->
  ?assert(true).

getAirQualityIndex_test() ->
  D = [{"war1",2},{"war2",8}, {"war3",5}, {"T1", 10}],
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
  P11 = pollution:addValue({1,1},{10,2},"war2",32,P10),
  P12 = pollution:addValue({1,1},{8,2},"war2",25,P11),
  ?assertEqual(400.0, pollution:getAirQualityIndex({1,1}, 2, P12, D)).


getDailyMean_test() ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("Tarnow",{1,1},P),
  P2 = pollution:addStation("Krakow",{2,2},P1),
  P3 = pollution:addValue({1,1},{1,1},"T1",1,P2),
  P4 = pollution:addValue({1,1},{1,2},"T2",2,P3),
  P5 = pollution:addValue({2,2},{1,1},"T1",2,P4),
  P6 = pollution:addValue({2,2},{3,2},"T1",7,P5),
  P7 = pollution:addValue({1,1},{1,3},"T1",9,P6),
  P8 = pollution:addValue({2,2},{1,1},"war1",1,P7),
  P9 = pollution:addValue({1,1},{1,2},"war2",2,P8),
  P10 = pollution:addValue({1,1},{5,1},"T1",4,P9),
  P11 = pollution:addValue({1,1},{10,2},"war2",32,P10),
  P12 = pollution:addValue({1,1},{8,2},"war2",25,P11),
  ?assertEqual(4.0, pollution:getDailyMean(P12,1, "T1" )).

addStation_test() ->
  M = pollution:createMonitor(),
  M2 = pollution:addStation("Krakow", {30, 20}, M),
  M3 = pollution:addStation("Krakow", {30, 20}, M),
  M4 = pollution:addStation("Krakow", {30, 20}, M2),
  ?assertEqual(M3, M2).


addValue_test() ->
  P = pollution:addStation("Stacja", {5, 10}, pollution:createMonitor()),
  Date = calendar:local_time(),
  % right usage
  P1 = pollution:addValue("Stacja", Date, "PM25", 23, P),
  P2 = pollution:addValue({5, 10}, Date, "PM25", 23, P),
  ?assertEqual(P == P1, false),
  ?assertEqual(P2 == P, false),
  % adding next data
  T = {{1999, 4, 20}, element(2, Date)},
  P3 =pollution:addValue("Stacja", T, "PM25", 18, P1),
  P4 = pollution:addValue("Stacja", T, "PM19", 19.0, P2),
  ?assertEqual(P3 == P1, false),
  ?assertEqual(P4 == P2, false),
  % adding to station that does not exist
  P5 = pollution:addValue("xxx", Date, "PM25", 23, P),
  P6 = pollution:addValue({2,3}, Date, "PM25", 23, P),
  ?assertEqual(P6, P5),
  % adding another data of the same type at one date (the same value)
  P7 = pollution:addValue({5, 10}, Date, "PM25", 23, P1),
  P8 = pollution:addValue("Stacja", Date, "PM25", 23, P1),
  ?assertEqual(P7, P8),
  % adding another data of the same type at one date (other value)
  P9 = pollution:addValue({5, 10}, Date, "PM25", 18, P1),
  P10 = pollution:addValue("Stacja", Date, "PM25", 18, P1),
  ?assertEqual(P10, P9).

getStationMean_test() ->
  M = pollution:createMonitor(),
  M1 = pollution:addStation("Krak", {40.234, 54.234}, M),
  M2 = pollution:addValue("Krak", {{2017,5,1},{20,10,58}}, "PM10", 20, M1),
  M3 = pollution:addValue("Krak", {{2017,5,1},{20,10,59}}, "PM10", 30, M2),
  M4 = pollution:addValue("Krak", {{2017,5,1},{20,11,00}}, "PM2", 400, M3),
  M5 = pollution:addValue("Krak", {{2017,5,1},{20,11,01}}, "PM2", 500, M4),
  ?assertEqual(25.0, pollution:getStationMean("Krak", "PM10", M5)),
  ?assertEqual(450.0, pollution:getStationMean({40.234, 54.234}, "PM2", M5)).

getOneValue_test() ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("Krak_Aleje", {40.23, 54.23}, P),
  P2 = pollution:addValue("Krak_Aleje", {{2017,5,8},{15,11,20}}, "PM10", 250, P1),
  P3 = pollution:addValue("Krak_Aleje", {{2017,5,8},{15,31,20}}, "PM10", 300, P2),
  ?assertEqual(250, pollution:getOneValue(P3, "Krak_Aleje",{{2017,5,8},{15,11,20}},"PM10")),
  ?assertEqual(300, pollution:getOneValue(P3, "Krak_Aleje",{{2017,5,8},{15,31,20}}, "PM10")),
  ?assertEqual(300, pollution:getOneValue(P3, {40.23, 54.23},{{2017,5,8},{15,31,20}}, "PM10")).

removeValue_test() ->
  D  = pollution:createMonitor(),
  D1 = pollution:addStation("Pole1", {12.4, 1.232}, D),
  D2 = pollution:addValue("Pole1", {{2017,4,10},{20,10,15}}, "PM10", 50, D1),
  D4 = pollution:addValue("Pole1", {{2017,4,10},{20,11,15}}, "PM10", 50, D2),
  D5 = pollution:removeValue({12.4, 1.232}, {{2017,4,10},{20,11,15}}, "PM10",D4),
  ?assertEqual(D2, D5).

%version 4
removeValue2_test() ->
  M = pollution:createMonitor(),
  M1 = pollution:addStation("Trzebinia", {50.16,19.47}, M),
  M2 = pollution:addStation("Szymbark", {54.22,18.10}, M1),

  M3 = pollution:addValue("Trzebinia", {{2017,16,5},{17,5,23}}, "PM10", 132, M2),
  M4 = pollution:addValue("Trzebinia", {{2017,16,5},{16,12,2}}, "PM10", 122, M3),
  M5 = pollution:addValue("Trzebinia", {{2017,16,5},{15,33,16}}, "PM10", 101, M4),
  M6 = pollution:addValue("Szymbark", {{2017,16,5},{17,5,17}}, "PM10", 56, M5),
  M7 = pollution:addValue("Szymbark", {{2017,16,5},{16,10,12}}, "PM10", 45, M6),
  M8 = pollution:addValue("Szymbark", {{2017,16,5},{15,38,35}}, "PM10", 55, M7),
  M9 = pollution:removeValue("Szymbark", {{2017,16,5},{15,38,35}}, "PM10", M8),
  M10 = pollution:removeValue({54.22,18.10}, {{2017,16,5},{16,10,12}}, "PM10", M9),

  ?assertEqual(M10, M6).





