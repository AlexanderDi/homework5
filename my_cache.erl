- module(my_cache).
- export([create/1, insert/3, insert/4, lookup/2, delete_obsolete/1]).

create(TableName) ->
    ets:new(TableName, [set, named_table, public]).

insert(TableName, Key, Value) ->
    ets:insert(TableName, {Key, Value}).

insert(TableName, Key, Value, CacheTime) ->
    TimeNow = erlang:system_time(second),
    ets:insert(TableName, {Key, Value, CacheTime + TimeNow}).

lookup(TableName, Key) ->
    TimeNow = erlang:system_time(second),
    case ets:lookup(TableName, Key) of
        [] ->
            undefined;
        [{Key, Vale}] ->
            [{Key, Vale}];
        [{_, _, CacheTime}] when CacheTime < TimeNow ->
            undefined;
        [{Key, Vale, _}] ->
            [{Key, Vale}]
    end.

delete_obsolete(TableName) ->
    d2(TableName, ets:first(TableName)).

d2(_, '$end_of_table') -> ready;
d2(TableName,Key) ->
    d2(TableName, ets:next(TableName, Key)),
    delete_obsolete(TableName, Key).

delete_obsolete(TableName,Key) ->
TimeNow = erlang:system_time(second),
    case ets:lookup(TableName, Key) of
        [{Key, _, CacheTime}] when CacheTime < TimeNow ->
            ets:delete(TableName, Key);
        _-> ok
end.