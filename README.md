```diff
-WORK IN PROGRESS
+Will code for time to code
```

# Blockchain in Postgresql

The demo is about Mining, the block Size "problem" lead to Bitcoin fork and about integrity check.

<li>Mining function is ` blockchainInPostgres.generateBlock() ` function, in `init.sql`.
<li>Block size is declared in that very same function, `blockSize` variable.
<li>Blockchain and `events` table checking function is `blockchainInPostgres.validateBlock()`, same `init.sql` file.
I do not have time -yet- to comment code, _sorry sorry sorry sorry sorry sorry sorry sorry_.
<br><br>
Of course, distribution is not included here :-P
<br>

## What you need to do and to know:
Prerequisites: any 9.* postgreSql; package `postgresql-contrib` installed (for hashing functions)

`init.sql` installs everything in schema `blockchainInPostgres`, schema which will be **dropped and (re)created each time `init.sql` is called**.

`demo.sql` runs a simple demo

## Execution screenshot
(Subject to heavy changes, just an idea... :-P)
<br>
### `init.sql`
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
<br>
### `demo.sql`
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
DELETE 8
UPDATE 0

take a look at events table
 blockheight | eventepoch | info1 | info2 | info3 | eventhash
-------------+------------+-------+-------+-------+-----------
(0 rows)


BEGIN
 NowGeneratingBlock
--------------------
 t
(1 row)

COMMIT

take a look at events table again
 blockheight | eventepoch | info1 | info2 | info3 | eventhash
-------------+------------+-------+-------+-------+-----------
(0 rows)


and at blockchain table
 blockheight | blockepoch |                eventshash                | nonce  |                blockhash
-------------+------------+------------------------------------------+--------+------------------------------------------
           0 |          0 | 0                                        |      0 | genesis
           2 | 1111111111 | 27e194eacb862a9286d8c4eeda518ce61fc13940 | 792047 | 032e1f12210076b03d7e81c7574dc6e2baa7e9a4
           1 | 1518101869 | c077a2296ca130f5a6f7952f9650cc64877375a6 | 382675 | 0d28402737a1dbf2282a4df3805525e6a19d2353
           3 | 1518101872 | 8dfd232b7907c0e26654945deaa4ec35c6c7b23e | 526744 | 0be55af222e2c4f6cd0df686edf849b8d3607192
           4 | 1518101880 | 1ce0c769a623d6592a96849d361bdca242ab6aa5 | 162412 | 00877aa059ebdc36e76a508b2699a6bdb1a3b298
(5 rows)


some more inserts...
INSERT 0 1
INSERT 0 1

trying -AGAIN- to force events table...
in blockchain, events table is append only!
DELETE 0
UPDATE 0
 blockheight | eventepoch |         info1         |  info2   |     info3      |                eventhash
-------------+------------+-----------------------+----------+----------------+------------------------------------------
          -1 | 1518101880 | Product 8896513573165 | Expires  | 2018-09-23     | 50532418b09bf45f3f34f8ac0a8a1c74f74a93d4
          -1 | 1518101880 | Part 578285471821     | Produced | Factory DE2742 | a04a1e6f1c67172db13e5acf48de2abd0d30ed9f
(2 rows)


 NowGeneratingBlock
--------------------
 t
(1 row)

 blockheight | blockepoch |                eventshash                | nonce  |                blockhash
-------------+------------+------------------------------------------+--------+------------------------------------------
           0 |          0 | 0                                        |      0 | genesis
           2 | 1111111111 | 27e194eacb862a9286d8c4eeda518ce61fc13940 | 792047 | 032e1f12210076b03d7e81c7574dc6e2baa7e9a4
           1 | 1518101869 | c077a2296ca130f5a6f7952f9650cc64877375a6 | 382675 | 0d28402737a1dbf2282a4df3805525e6a19d2353
           3 | 1518101872 | 8dfd232b7907c0e26654945deaa4ec35c6c7b23e | 526744 | 0be55af222e2c4f6cd0df686edf849b8d3607192
           4 | 1518101880 | 1ce0c769a623d6592a96849d361bdca242ab6aa5 | 162412 | 00877aa059ebdc36e76a508b2699a6bdb1a3b298
           5 | 1518101880 | 556eec1a49e3e1b93ce7ae2c51336c4014d520fb | 489517 | 0d8ee12ecf9044f7f77e6e02e099b95e61728bf5
(6 rows)


 NowGeneratingBlock
--------------------
 t
(1 row)

----------------------
psql:demo.sql:57: ERROR:  P0001: **** Blockchain table has been altered!!!
LOCATION:  exec_stmt_raise, pl_exec.c:3216


---------------------------------
---------------------------------
Now, force an update, and make validation fail
ALTER TABLE
 blockheight | eventepoch | info1 | info2 | info3 | eventhash
-------------+------------+-------+-------+-------+-----------
(0 rows)

UPDATE 0
 blockheight | eventepoch | info1 | info2 | info3 | eventhash
-------------+------------+-------+-------+-------+-----------
(0 rows)

psql:demo.sql:69: ERROR:  P0001: **** Blockchain table has been altered!!!
LOCATION:  exec_stmt_raise, pl_exec.c:3216

---------------------------------
Now, reset field, check again, then break blockchain table
UPDATE 0
psql:demo.sql:75: ERROR:  P0001: **** Blockchain table has been altered!!!
LOCATION:  exec_stmt_raise, pl_exec.c:3216



 blockheight | eventepoch |         info1         |  info2   |     info3      |                eventhash
-------------+------------+-----------------------+----------+----------------+------------------------------------------
           5 | 1518101880 | Product 8896513573165 | Expires  | 2018-09-23     | 50532418b09bf45f3f34f8ac0a8a1c74f74a93d4
           5 | 1518101880 | Part 578285471821     | Produced | Factory DE2742 | a04a1e6f1c67172db13e5acf48de2abd0d30ed9f
(2 rows)


 blockheight | blockepoch |                eventshash                | nonce  |                blockhash
-------------+------------+------------------------------------------+--------+------------------------------------------
           0 |          0 | 0                                        |      0 | genesis
           2 | 1111111111 | 27e194eacb862a9286d8c4eeda518ce61fc13940 | 792047 | 032e1f12210076b03d7e81c7574dc6e2baa7e9a4
           1 | 1518101869 | c077a2296ca130f5a6f7952f9650cc64877375a6 | 382675 | 0d28402737a1dbf2282a4df3805525e6a19d2353
           3 | 1518101872 | 8dfd232b7907c0e26654945deaa4ec35c6c7b23e | 526744 | 0be55af222e2c4f6cd0df686edf849b8d3607192
           4 | 1518101880 | 1ce0c769a623d6592a96849d361bdca242ab6aa5 | 162412 | 00877aa059ebdc36e76a508b2699a6bdb1a3b298
           5 | 1518101880 | 556eec1a49e3e1b93ce7ae2c51336c4014d520fb | 489517 | 0d8ee12ecf9044f7f77e6e02e099b95e61728bf5
           6 | 1518101880 | b038681a7f749836ae448ad5a76a709dbc9542aa | 520021 | 03d2b8fb46868f97a23086059cb6b8b92f9fe117
(7 rows)



 blockheight | blockepoch |                eventshash                | nonce  |                blockhash
-------------+------------+------------------------------------------+--------+------------------------------------------
           2 | 1111111111 | 27e194eacb862a9286d8c4eeda518ce61fc13940 | 792047 | 032e1f12210076b03d7e81c7574dc6e2baa7e9a4
(1 row)

UPDATE 1
 blockheight | blockepoch |                eventshash                | nonce  |                blockhash
-------------+------------+------------------------------------------+--------+------------------------------------------
           2 | 1111111111 | 27e194eacb862a9286d8c4eeda518ce61fc13940 | 792047 | 032e1f12210076b03d7e81c7574dc6e2baa7e9a4
(1 row)

psql:demo.sql:88: ERROR:  P0001: **** Blockchain table has been altered!!!
LOCATION:  exec_stmt_raise, pl_exec.c:3216

=#
```

# Future...
Well, i need to make ACTUAL stuff more readable and better, buuuuut...<br>
An idea would be to simulate a Ethreum Blockchain, by doing something like
```
| info1  | info2  |  info3  |
+--------+--------+---------+
| 1 + 1  | =      | 2       |
```
And the validation function would execute "code" in `info1`, and check (`info2`) with result (`info3`) in chain.


# Have fun!
