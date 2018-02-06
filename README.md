# Blockchain in Postgresql

The demo is about Mining, the block Size "problem" lead to Bitcoin fork and about integrity check.

<li>Mining function is `blockchainInPostgres.generateBlock()` function, in `init.sql`.
<li>Block size is declared in that very same function, `blockSize` variable.
<li>Blockchain and `events` table checking function is `blockchainInPostgres.validateBlock()`, same `init.sql` file.
I do not have time -yet- to comment code, _sorry sorry sorry sorry sorry sorry sorry sorry_.


<br>

## What you need to do and to know:
Prerequisites: any 9.* postgreSql; package `postgresql-contrib` installed (for hashing functions)

`init.sql` installs everything in schema `blockchainInPostgres`, schema which will be **dropped and (re)created each time `init.sql` is called**.

`demo.sql` runs a simple demo

## Execution screenshot
(Subject to heavy changes, just an idea... :-P)
<br>
`init.sql`
```
=# \i init.sql
psql:init.sql:3: ERROR:  42710: extension "pgcrypto" already exists
LOCATION:  CreateExtension, extension.c:1216
Time: 1.001 ms
psql:init.sql:6: NOTICE:  00000: drop cascades to 7 other objects
DETAIL:  drop cascades to table blockchaininpostgres.events
drop cascades to function blockchaininpostgres.donothign()
drop cascades to function blockchaininpostgres.eventsinsert()
drop cascades to sequence blockchaininpostgres.blockheightseq
drop cascades to table blockchaininpostgres.blockchain
drop cascades to function blockchaininpostgres.validateblock()
drop cascades to function blockchaininpostgres.generateblock()
LOCATION:  reportDependentObjects, dependency.c:1003
DROP SCHEMA
Time: 1.000 ms
DROP ROLE
Time: 5.501 ms
CREATE SCHEMA
Time: 1.000 ms
CREATE ROLE
Time: 1.501 ms
psql:init.sql:14: NOTICE:  00000: table "events" does not exist, skipping
LOCATION:  DropErrorMsgNonExistent, tablecmds.c:760
DROP TABLE
Time: 0.000 ms
CREATE TABLE
Time: 4.000 ms
CREATE FUNCTION
Time: 2.001 ms
CREATE FUNCTION
Time: 1.500 ms
psql:init.sql:52: NOTICE:  00000: trigger "readonlyevent" for relation "blockchaininpostgres.events" does not exist, skipping
LOCATION:  does_not_exist_skipping, dropcmds.c:448
DROP TRIGGER
Time: 0.000 ms
CREATE TRIGGER
Time: 1.000 ms
psql:init.sql:59: NOTICE:  00000: trigger "oneventinsert" for relation "blockchaininpostgres.events" does not exist, skipping
LOCATION:  does_not_exist_skipping, dropcmds.c:448
DROP TRIGGER
Time: 0.000 ms
CREATE TRIGGER
Time: 1.000 ms
psql:init.sql:70: NOTICE:  00000: sequence "blockheightseq" does not exist, skipping
LOCATION:  DropErrorMsgNonExistent, tablecmds.c:760
DROP SEQUENCE
Time: 0.501 ms
CREATE SEQUENCE
Time: 1.000 ms
CREATE TABLE
Time: 7.501 ms
CREATE FUNCTION
Time: 1.501 ms
CREATE FUNCTION
Time: 1.000 ms
```
<br><br>
`demo.sql`
```
=# \i demo.sql
Timing is off.

inserting some events...
note the date i try to insert, and what is really inserted..
INSERT 0 1
INSERT 0 1
INSERT 0 1

trying to force events table...
in blockchain, events table is append only!
DELETE 0
UPDATE 0

take a look at events table
 blockheight | eventepoch | info1  |  info2   |     info3     |                eventhash
-------------+------------+--------+----------+---------------+------------------------------------------
          -1 | 1517918615 | VY1234 | took off | 12 mins delay | 2683fd9166eec162415d8ab81542aafa9d1fa221
          -1 | 1517918615 | VY1234 | landed   | 02 mins delay | a2717a4a08bd12e4062efa695cef2592231123b9
          -1 | 1517918615 | VY4321 | landed   |               | a35958a5a79febe8915d03e56970c45daef7e27f
(3 rows)


BEGIN
 NowGeneratingBlock
--------------------
 t
(1 row)

COMMIT

take a look at events table again
 blockheight | eventepoch | info1  |  info2   |     info3     |                eventhash
-------------+------------+--------+----------+---------------+------------------------------------------
          -1 | 1517918615 | VY4321 | landed   |               | a35958a5a79febe8915d03e56970c45daef7e27f
           1 | 1517918615 | VY1234 | took off | 12 mins delay | 2683fd9166eec162415d8ab81542aafa9d1fa221
           1 | 1517918615 | VY1234 | landed   | 02 mins delay | a2717a4a08bd12e4062efa695cef2592231123b9
(3 rows)


and at blockchain table
 blockheight | blockepoch |                eventshash                | nonce |                blockhash
-------------+------------+------------------------------------------+-------+------------------------------------------
           1 | 1517918615 | bcea8f9506d2a34c6820bcd1f2df3f0b800f421f |     0 | 06a336d0b72048c24fb08435156b6f96ae2e3317
(1 row)


some more inserts...
INSERT 0 1
INSERT 0 1

trying -AGAIN- to force events table...
in blockchain, events table is append only!
DELETE 0
UPDATE 0
 blockheight | eventepoch |         info1         |  info2   |     info3      |                eventhash
-------------+------------+-----------------------+----------+----------------+------------------------------------------
          -1 | 1517918615 | VY4321                | landed   |                | a35958a5a79febe8915d03e56970c45daef7e27f
           1 | 1517918615 | VY1234                | took off | 12 mins delay  | 2683fd9166eec162415d8ab81542aafa9d1fa221
           1 | 1517918615 | VY1234                | landed   | 02 mins delay  | a2717a4a08bd12e4062efa695cef2592231123b9
          -1 | 1517918615 | Product 8896513573165 | Expires  | 2018-09-23     | a24c8cadf95c54e2de6713ff6318bbdaa9d61d6f
          -1 | 1517918615 | Part 578285471821     | Produced | Factory DE2742 | e6a5fc91d53157d28ebc421c0594bcdfa42ac9f2
(5 rows)


 NowGeneratingBlock
--------------------
 t
(1 row)

 blockheight | blockepoch |                eventshash                | nonce |                blockhash
-------------+------------+------------------------------------------+-------+------------------------------------------
           1 | 1517918615 | bcea8f9506d2a34c6820bcd1f2df3f0b800f421f |     0 | 06a336d0b72048c24fb08435156b6f96ae2e3317
           2 | 1517918615 | 468facbcfa517efa105e70ce95d5e859316f7144 |     9 | 0101545bba4fadb4e3b5e9abdb250498cba5c4bc
(2 rows)


 NowGeneratingBlock
--------------------
 t
(1 row)

----------------------
 BlockValidationResult
-----------------------
 t
(1 row)



---------------------------------
---------------------------------
Now, force an update, and make validation fail
ALTER TABLE
 blockheight | eventepoch | info1  | info2  |     info3     |                eventhash
-------------+------------+--------+--------+---------------+------------------------------------------
           1 | 1517918615 | VY1234 | landed | 02 mins delay | a2717a4a08bd12e4062efa695cef2592231123b9
(1 row)

UPDATE 1
 blockheight | eventepoch | info1  | info2  |  info3  |                eventhash
-------------+------------+--------+--------+---------+------------------------------------------
           1 | 1517918615 | VY1234 | landed | on time | a2717a4a08bd12e4062efa695cef2592231123b9
(1 row)

psql:demo.sql:69: ERROR:  P0001: **** Event table has been altered!!!
LOCATION:  exec_stmt_raise, pl_exec.c:3216

---------------------------------
Now, reset field, check again, then break blockchain table
UPDATE 1
 BlockValidationResult
-----------------------
 t
(1 row)

 blockheight | blockepoch |                eventshash                | nonce |                blockhash
-------------+------------+------------------------------------------+-------+------------------------------------------
           2 | 1517918615 | 468facbcfa517efa105e70ce95d5e859316f7144 |     9 | 0101545bba4fadb4e3b5e9abdb250498cba5c4bc
(1 row)

UPDATE 1
 blockheight | blockepoch |                eventshash                | nonce |                blockhash
-------------+------------+------------------------------------------+-------+------------------------------------------
           2 | 1111111111 | 468facbcfa517efa105e70ce95d5e859316f7144 |     9 | 0101545bba4fadb4e3b5e9abdb250498cba5c4bc
(1 row)

psql:demo.sql:80: ERROR:  P0001: **** Blockchain table has been altered!!!
LOCATION:  exec_stmt_raise, pl_exec.c:3216

=#
```

# Have fun!