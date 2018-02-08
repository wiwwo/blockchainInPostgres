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
DELETE 0
UPDATE 0

take a look at events table
 blockheight | eventepoch | info1  |  info2   |     info3     |                eventhash
-------------+------------+--------+----------+---------------+------------------------------------------
          -1 | 1518102164 | VY1234 | took off | 12 mins delay | c99049e77e96eb6f0ce87a5e59ea41a68ba2391a
          -1 | 1518102164 | VY1234 | landed   | 02 mins delay | 3c48acc4576bfb745413338dfbca2aaa60399a21
          -1 | 1518102164 | VY4321 | landed   |               | 10cfd788594e64e242865dd9e1c4eed9d81f7edf
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
          -1 | 1518102164 | VY4321 | landed   |               | 10cfd788594e64e242865dd9e1c4eed9d81f7edf
           1 | 1518102164 | VY1234 | took off | 12 mins delay | c99049e77e96eb6f0ce87a5e59ea41a68ba2391a
           1 | 1518102164 | VY1234 | landed   | 02 mins delay | 3c48acc4576bfb745413338dfbca2aaa60399a21
(3 rows)


and at blockchain table
 blockheight | blockepoch |                eventshash                | nonce  |                blockhash
-------------+------------+------------------------------------------+--------+------------------------------------------
           0 |          0 | 0                                        |      0 | genesis
           1 | 1518102164 | bf659a500d0045df9d0781f1c22cde875fc3c22a | 596928 | 08790e0bac77e77c3ceea5724a5cd9d662a945dd
(2 rows)


some more inserts...
INSERT 0 1
INSERT 0 1

trying -AGAIN- to force events table...
in blockchain, events table is append only!
DELETE 0
UPDATE 0
 blockheight | eventepoch |         info1         |  info2   |     info3      |                eventhash
-------------+------------+-----------------------+----------+----------------+------------------------------------------
          -1 | 1518102164 | VY4321                | landed   |                | 10cfd788594e64e242865dd9e1c4eed9d81f7edf
           1 | 1518102164 | VY1234                | took off | 12 mins delay  | c99049e77e96eb6f0ce87a5e59ea41a68ba2391a
           1 | 1518102164 | VY1234                | landed   | 02 mins delay  | 3c48acc4576bfb745413338dfbca2aaa60399a21
          -1 | 1518102164 | Product 8896513573165 | Expires  | 2018-09-23     | 4b9a5003cacb0fc7a7d506018788c74e070a0b4a
          -1 | 1518102164 | Part 578285471821     | Produced | Factory DE2742 | 82c3a19e2f172cf4c4e565f24ca0c28e67c92670
(5 rows)


 NowGeneratingBlock
--------------------
 t
(1 row)

 blockheight | blockepoch |                eventshash                | nonce  |                blockhash
-------------+------------+------------------------------------------+--------+------------------------------------------
           0 |          0 | 0                                        |      0 | genesis
           1 | 1518102164 | bf659a500d0045df9d0781f1c22cde875fc3c22a | 596928 | 08790e0bac77e77c3ceea5724a5cd9d662a945dd
           2 | 1518102164 | 01162aa3e16c783d0c5198dcc5526ff98c136c80 |  71024 | 0bc24459c2591c38e45e0147e9e52a81c4b0e296
(3 rows)


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
           1 | 1518102164 | VY1234 | landed | 02 mins delay | 3c48acc4576bfb745413338dfbca2aaa60399a21
(1 row)

UPDATE 1
 blockheight | eventepoch | info1  | info2  |  info3  |                eventhash
-------------+------------+--------+--------+---------+------------------------------------------
           1 | 1518102164 | VY1234 | landed | on time | 3c48acc4576bfb745413338dfbca2aaa60399a21
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




 blockheight | eventepoch |         info1         |  info2   |     info3      |                eventhash
-------------+------------+-----------------------+----------+----------------+------------------------------------------
           1 | 1518102164 | VY1234                | took off | 12 mins delay  | c99049e77e96eb6f0ce87a5e59ea41a68ba2391a
           2 | 1518102164 | VY4321                | landed   |                | 10cfd788594e64e242865dd9e1c4eed9d81f7edf
           2 | 1518102164 | Product 8896513573165 | Expires  | 2018-09-23     | 4b9a5003cacb0fc7a7d506018788c74e070a0b4a
           3 | 1518102164 | Part 578285471821     | Produced | Factory DE2742 | 82c3a19e2f172cf4c4e565f24ca0c28e67c92670
           1 | 1518102164 | VY1234                | landed   | 02 mins delay  | 3c48acc4576bfb745413338dfbca2aaa60399a21
(5 rows)


 blockheight | blockepoch |                eventshash                | nonce  |                blockhash
-------------+------------+------------------------------------------+--------+------------------------------------------
           0 |          0 | 0                                        |      0 | genesis
           1 | 1518102164 | bf659a500d0045df9d0781f1c22cde875fc3c22a | 596928 | 08790e0bac77e77c3ceea5724a5cd9d662a945dd
           2 | 1518102164 | 01162aa3e16c783d0c5198dcc5526ff98c136c80 |  71024 | 0bc24459c2591c38e45e0147e9e52a81c4b0e296
           3 | 1518102164 | f71bbfbc0ec2cdfbe8b90211f45555562aff9d3d | 201248 | 07a6e3fa42d389c9ff93319454c9b86a43ce0af6
(4 rows)



 blockheight | blockepoch |                eventshash                | nonce |                blockhash
-------------+------------+------------------------------------------+-------+------------------------------------------
           2 | 1518102164 | 01162aa3e16c783d0c5198dcc5526ff98c136c80 | 71024 | 0bc24459c2591c38e45e0147e9e52a81c4b0e296
(1 row)

UPDATE 1
 blockheight | blockepoch |                eventshash                | nonce |                blockhash
-------------+------------+------------------------------------------+-------+------------------------------------------
           2 | 1111111111 | 01162aa3e16c783d0c5198dcc5526ff98c136c80 | 71024 | 0bc24459c2591c38e45e0147e9e52a81c4b0e296
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
