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

<br>

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
          -1 | 1518521155 | VY1234 | took off | 12 mins delay | 5c2e37b8ec1843f059133b50e73e94321c372129
          -1 | 1518521155 | VY1234 | landed   | 02 mins delay | 264d07ad9908789a13ff057082e60af80aa0d00d
          -1 | 1518521155 | VY4321 | landed   |               | cb112adf2d9349d5fbb5658a6373753974a3340e
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
          -1 | 1518521155 | VY4321 | landed   |               | cb112adf2d9349d5fbb5658a6373753974a3340e
           1 | 1518521155 | VY1234 | took off | 12 mins delay | 5c2e37b8ec1843f059133b50e73e94321c372129
           1 | 1518521155 | VY1234 | landed   | 02 mins delay | 264d07ad9908789a13ff057082e60af80aa0d00d
(3 rows)


and at blockchain table
 blockheight | blockepoch |                eventshash                | nonce  | previousblockhash |                blockhash
-------------+------------+------------------------------------------+--------+-------------------+------------------------------------------
           0 |          0 | 0                                        |      0 | 0                 | genesis
           1 | 1518521155 | 8302b4a6357d0bb9b8fc32b5356ecc1c02868cff | 949579 | genesis           | 077eae18086555f69b9681dda55075d8cdd87ff4
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
          -1 | 1518521155 | VY4321                | landed   |                | cb112adf2d9349d5fbb5658a6373753974a3340e
           1 | 1518521155 | VY1234                | took off | 12 mins delay  | 5c2e37b8ec1843f059133b50e73e94321c372129
           1 | 1518521155 | VY1234                | landed   | 02 mins delay  | 264d07ad9908789a13ff057082e60af80aa0d00d
          -1 | 1518521155 | Product 8896513573165 | Expires  | 2018-09-23     | a98bd6a27302a0d7d1259c01456b174e2aac14ac
          -1 | 1518521155 | Part 578285471821     | Produced | Factory DE2742 | 7dfdeca2cb7d0ee3c400bc6f18e7299049983f05
(5 rows)


 NowGeneratingBlock
--------------------
 t
(1 row)

 blockheight | blockepoch |                eventshash                | nonce  |            previousblockhash             |                blockhash
-------------+------------+------------------------------------------+--------+------------------------------------------+------------------------------------------
           0 |          0 | 0                                        |      0 | 0                                        | genesis
           1 | 1518521155 | 8302b4a6357d0bb9b8fc32b5356ecc1c02868cff | 949579 | genesis                                  | 077eae18086555f69b9681dda55075d8cdd87ff4
           2 | 1518521155 | fed7350b31121a591f95626bf6623837b37759d4 | 645081 | 077eae18086555f69b9681dda55075d8cdd87ff4 | 0c28549bf34e64eb278d3c893d8744490569a6b4
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
           1 | 1518521155 | VY1234 | landed | 02 mins delay | 264d07ad9908789a13ff057082e60af80aa0d00d
(1 row)

UPDATE 1
 blockheight | eventepoch | info1  | info2  |  info3  |                eventhash
-------------+------------+--------+--------+---------+------------------------------------------
           1 | 1518521155 | VY1234 | landed | on time | 264d07ad9908789a13ff057082e60af80aa0d00d
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
           1 | 1518521155 | VY1234                | took off | 12 mins delay  | 5c2e37b8ec1843f059133b50e73e94321c372129
           2 | 1518521155 | VY4321                | landed   |                | cb112adf2d9349d5fbb5658a6373753974a3340e
           2 | 1518521155 | Product 8896513573165 | Expires  | 2018-09-23     | a98bd6a27302a0d7d1259c01456b174e2aac14ac
           3 | 1518521155 | Part 578285471821     | Produced | Factory DE2742 | 7dfdeca2cb7d0ee3c400bc6f18e7299049983f05
           1 | 1518521155 | VY1234                | landed   | 02 mins delay  | 264d07ad9908789a13ff057082e60af80aa0d00d
(5 rows)


 blockheight | blockepoch |                eventshash                | nonce  |            previousblockhash             |                blockhash
-------------+------------+------------------------------------------+--------+------------------------------------------+------------------------------------------
           0 |          0 | 0                                        |      0 | 0                                        | genesis
           1 | 1518521155 | 8302b4a6357d0bb9b8fc32b5356ecc1c02868cff | 949579 | genesis                                  | 077eae18086555f69b9681dda55075d8cdd87ff4
           2 | 1518521155 | fed7350b31121a591f95626bf6623837b37759d4 | 645081 | 077eae18086555f69b9681dda55075d8cdd87ff4 | 0c28549bf34e64eb278d3c893d8744490569a6b4
           3 | 1518521155 | 0f9dc5f5ac4772ac2366224c0688eab53665afde |  37430 | 0c28549bf34e64eb278d3c893d8744490569a6b4 | 0bae99c6229f55702d11e0dc47355ff66e2035ee
(4 rows)



ALTER TABLE
 blockheight | blockepoch |                eventshash                | nonce  |            previousblockhash             |                blockhash
-------------+------------+------------------------------------------+--------+------------------------------------------+------------------------------------------
           2 | 1518521155 | fed7350b31121a591f95626bf6623837b37759d4 | 645081 | 077eae18086555f69b9681dda55075d8cdd87ff4 | 0c28549bf34e64eb278d3c893d8744490569a6b4
(1 row)

UPDATE 1
 blockheight | blockepoch |                eventshash                | nonce  |            previousblockhash             |                blockhash
-------------+------------+------------------------------------------+--------+------------------------------------------+------------------------------------------
           2 | 1111111111 | fed7350b31121a591f95626bf6623837b37759d4 | 645081 | 077eae18086555f69b9681dda55075d8cdd87ff4 | 0c28549bf34e64eb278d3c893d8744490569a6b4
(1 row)

psql:demo.sql:90: ERROR:  P0001: **** Blockchain table has been altered!!!
LOCATION:  exec_stmt_raise, pl_exec.c:3216


Bitcoin blockchain example
ALTER TABLE
ALTER TABLE
DELETE 5
DELETE 4
ALTER TABLE
ALTER TABLE
ALTER TABLE
DROP SEQUENCE
CREATE SEQUENCE
INSERT 0 1
 NowGeneratingBlock
--------------------
 t
(1 row)


INSERT 0 1
 pg_sleep
----------

(1 row)

INSERT 0 5
 blockheight | eventepoch |                           info1                           |                          info2                          |  info3  |                eventhash
-------------+------------+-----------------------------------------------------------+---------------------------------------------------------+---------+------------------------------------------
          -1 | 1518521155 | FROM GENESIS                                              | TO RobinHood y8c0bbd7ecc77a0924dadce65a09b2ead146ad15   | 999 BTC | 8301bb7d03be996de5de6c07401c363af89818dc
          -1 | 1518521156 | FROM RobinHood xb7a04e27dcbcfe0cedf06faa4f36c084d4a1a29   | TO PoorPerson1 y8c0bbd7ecc77a0924dadce65a09b2ead146ad15 | 99 BTC  | 192bd3198baeea44089ed50fdf03487a7770f207
          -1 | 1518521156 | FROM RobinHood xb7a04e27dcbcfe0cedf06faa4f36c084d4a1a29   | TO PoorPerson2 efb71bb90b344a3495adf3457a8705c178beeb03 | 99 BTC  | dc69e0e16a4a8aeaa8909a3eed11b95df3666861
          -1 | 1518521156 | FROM RobinHood xb7a04e27dcbcfe0cedf06faa4f36c084d4a1a29   | TO PoorPerson3 161897cffdbd367faedc1484f705788001acdbbb | 99 BTC  | 5f530b0a6570b876317b7c75f00f601e326eaaef
          -1 | 1518521156 | FROM PoorPerson3 161897cffdbd367faedc1484f705788001acdbbb | TO PoorPerson4 27142e2859f95012f45951e47621bfd6153af46e | 9 BTC   | c3285e70598fdfa54ca29166371fd46b16029b35
          -1 | 1518521156 | FROM PoorPerson3 161897cffdbd367faedc1484f705788001acdbbb | TO PoorPerson5 c40caa2ac5de6957097512e61bf0d590c3b7446d | 9 BTC   | e2496614f13a822556fa7b4f444ae562180d8a3b
(6 rows)

 NowGeneratingBlock
--------------------
 t
(1 row)

 NowGeneratingBlock
--------------------
 t
(1 row)

 NowGeneratingBlock
--------------------
 t
(1 row)

 NowGeneratingBlock
--------------------
 t
(1 row)

 NowGeneratingBlock
--------------------
 t
(1 row)

 NowGeneratingBlock
--------------------
 t
(1 row)

 blockheight | eventepoch |                           info1                           |                          info2                          |  info3  |                eventhash
-------------+------------+-----------------------------------------------------------+---------------------------------------------------------+---------+------------------------------------------
           1 | 1518521155 | FROM GENESIS                                              | TO RobinHood y8c0bbd7ecc77a0924dadce65a09b2ead146ad15   | 999 BTC | 8301bb7d03be996de5de6c07401c363af89818dc
           1 | 1518521156 | FROM RobinHood xb7a04e27dcbcfe0cedf06faa4f36c084d4a1a29   | TO PoorPerson1 y8c0bbd7ecc77a0924dadce65a09b2ead146ad15 | 99 BTC  | 192bd3198baeea44089ed50fdf03487a7770f207
           2 | 1518521156 | FROM RobinHood xb7a04e27dcbcfe0cedf06faa4f36c084d4a1a29   | TO PoorPerson2 efb71bb90b344a3495adf3457a8705c178beeb03 | 99 BTC  | dc69e0e16a4a8aeaa8909a3eed11b95df3666861
           2 | 1518521156 | FROM RobinHood xb7a04e27dcbcfe0cedf06faa4f36c084d4a1a29   | TO PoorPerson3 161897cffdbd367faedc1484f705788001acdbbb | 99 BTC  | 5f530b0a6570b876317b7c75f00f601e326eaaef
           3 | 1518521156 | FROM PoorPerson3 161897cffdbd367faedc1484f705788001acdbbb | TO PoorPerson4 27142e2859f95012f45951e47621bfd6153af46e | 9 BTC   | c3285e70598fdfa54ca29166371fd46b16029b35
           3 | 1518521156 | FROM PoorPerson3 161897cffdbd367faedc1484f705788001acdbbb | TO PoorPerson5 c40caa2ac5de6957097512e61bf0d590c3b7446d | 9 BTC   | e2496614f13a822556fa7b4f444ae562180d8a3b
(6 rows)


 blockheight | blockepoch |                eventshash                | nonce  |            previousblockhash             |                blockhash
-------------+------------+------------------------------------------+--------+------------------------------------------+------------------------------------------
           0 |          0 | 0                                        |      0 | 0                                        | genesis
           1 | 1518521156 | ac3f84eb830bf4006ecd263e21395cf1a8960596 | 760753 | genesis                                  | 0106129ac4680d724b37f803d6a81ecadbd0f559
           2 | 1518521156 | 34b1ab4ccb6c570c6fe484431bee3b85c440b6ba | 735718 | 0106129ac4680d724b37f803d6a81ecadbd0f559 | 03c954f4b2bf83ba753223c268b4aca637bdcd71
           3 | 1518521156 | 456082acfaca77c95bbfa0698ca556cd5c63437d | 231024 | 03c954f4b2bf83ba753223c268b4aca637bdcd71 | 096709b19a1f3248acb3b02e624aeb338414692d
(4 rows)


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
