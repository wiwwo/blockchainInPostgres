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
          -1 | 1518508125 | VY1234 | took off | 12 mins delay | 2d8b9b759bf9b0dc6fb861ed68414945c8ce3908
          -1 | 1518508125 | VY1234 | landed   | 02 mins delay | 2b34052e3531e7ea544adc8325e25697d660d2c2
          -1 | 1518508125 | VY4321 | landed   |               | 9e835dc91c376ae1d97ae08913d6ead932668664
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
          -1 | 1518508125 | VY4321 | landed   |               | 9e835dc91c376ae1d97ae08913d6ead932668664
           1 | 1518508125 | VY1234 | took off | 12 mins delay | 2d8b9b759bf9b0dc6fb861ed68414945c8ce3908
           1 | 1518508125 | VY1234 | landed   | 02 mins delay | 2b34052e3531e7ea544adc8325e25697d660d2c2
(3 rows)


and at blockchain table
 blockheight | blockepoch |                eventshash                | nonce  | previousblockhash |                blockhash
-------------+------------+------------------------------------------+--------+-------------------+------------------------------------------
           0 |          0 | 0                                        |      0 | 0                 | genesis
           1 | 1518508125 | 6cb23ec944b926f7b31d8cf786e898c216519c91 | 927131 | genesis           | 0eab2377e13d29e69e8c4412f78aaba623c0bd9f
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
          -1 | 1518508125 | VY4321                | landed   |                | 9e835dc91c376ae1d97ae08913d6ead932668664
           1 | 1518508125 | VY1234                | took off | 12 mins delay  | 2d8b9b759bf9b0dc6fb861ed68414945c8ce3908
           1 | 1518508125 | VY1234                | landed   | 02 mins delay  | 2b34052e3531e7ea544adc8325e25697d660d2c2
          -1 | 1518508125 | Product 8896513573165 | Expires  | 2018-09-23     | f135d4cd6f257e619d99ff67565436f2867b35e1
          -1 | 1518508125 | Part 578285471821     | Produced | Factory DE2742 | 48a1fbf23a273fa679e870719a9ad8b5dee22b2c
(5 rows)


 NowGeneratingBlock
--------------------
 t
(1 row)

 blockheight | blockepoch |                eventshash                | nonce  |            previousblockhash             |                blockhash
-------------+------------+------------------------------------------+--------+------------------------------------------+------------------------------------------
           0 |          0 | 0                                        |      0 | 0                                        | genesis
           1 | 1518508125 | 6cb23ec944b926f7b31d8cf786e898c216519c91 | 927131 | genesis                                  | 0eab2377e13d29e69e8c4412f78aaba623c0bd9f
           2 | 1518508125 | 5f828c5b8fadba8d389e641e4c5726dcb00889d6 | 708621 | 0eab2377e13d29e69e8c4412f78aaba623c0bd9f | 0ed1e25d6b1c77bf96656295304c4662be24d3b7
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
           1 | 1518508125 | VY1234 | landed | 02 mins delay | 2b34052e3531e7ea544adc8325e25697d660d2c2
(1 row)

UPDATE 1
 blockheight | eventepoch | info1  | info2  |  info3  |                eventhash
-------------+------------+--------+--------+---------+------------------------------------------
           1 | 1518508125 | VY1234 | landed | on time | 2b34052e3531e7ea544adc8325e25697d660d2c2
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
           1 | 1518508125 | VY1234                | took off | 12 mins delay  | 2d8b9b759bf9b0dc6fb861ed68414945c8ce3908
           2 | 1518508125 | VY4321                | landed   |                | 9e835dc91c376ae1d97ae08913d6ead932668664
           2 | 1518508125 | Product 8896513573165 | Expires  | 2018-09-23     | f135d4cd6f257e619d99ff67565436f2867b35e1
           3 | 1518508125 | Part 578285471821     | Produced | Factory DE2742 | 48a1fbf23a273fa679e870719a9ad8b5dee22b2c
           1 | 1518508125 | VY1234                | landed   | 02 mins delay  | 2b34052e3531e7ea544adc8325e25697d660d2c2
(5 rows)


 blockheight | blockepoch |                eventshash                | nonce  |            previousblockhash             |                blockhash
-------------+------------+------------------------------------------+--------+------------------------------------------+------------------------------------------
           0 |          0 | 0                                        |      0 | 0                                        | genesis
           1 | 1518508125 | 6cb23ec944b926f7b31d8cf786e898c216519c91 | 927131 | genesis                                  | 0eab2377e13d29e69e8c4412f78aaba623c0bd9f
           2 | 1518508125 | 5f828c5b8fadba8d389e641e4c5726dcb00889d6 | 708621 | 0eab2377e13d29e69e8c4412f78aaba623c0bd9f | 0ed1e25d6b1c77bf96656295304c4662be24d3b7
           3 | 1518508125 | 29ad9df72baa094e483d2a1a9a3ccfba274d214c | 611296 | 0ed1e25d6b1c77bf96656295304c4662be24d3b7 | 0ef829bedc3b4232870bfe9c46db25933903f39e
(4 rows)



ALTER TABLE
 blockheight | blockepoch |                eventshash                | nonce  |            previousblockhash             |                blockhash
-------------+------------+------------------------------------------+--------+------------------------------------------+------------------------------------------
           2 | 1518508125 | 5f828c5b8fadba8d389e641e4c5726dcb00889d6 | 708621 | 0eab2377e13d29e69e8c4412f78aaba623c0bd9f | 0ed1e25d6b1c77bf96656295304c4662be24d3b7
(1 row)

UPDATE 1
 blockheight | blockepoch |                eventshash                | nonce  |            previousblockhash             |                blockhash
-------------+------------+------------------------------------------+--------+------------------------------------------+------------------------------------------
           2 | 1111111111 | 5f828c5b8fadba8d389e641e4c5726dcb00889d6 | 708621 | 0eab2377e13d29e69e8c4412f78aaba623c0bd9f | 0ed1e25d6b1c77bf96656295304c4662be24d3b7
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

INSERT 0 6
 blockheight | eventepoch |                           info1                           |                          info2                          |  info3  |                eventhash
-------------+------------+-----------------------------------------------------------+---------------------------------------------------------+---------+------------------------------------------
          -1 | 1518508125 | FROM GENESIS                                              | TO RobinHood y8c0bbd7ecc77a0924dadce65a09b2ead146ad15   | 999 BTC | c46c08b6f423f35593ddf2ba97c10e625237499b
          -1 | 1518508125 | FROM RobinHood xb7a04e27dcbcfe0cedf06faa4f36c084d4a1a29   | TO PoorPerson1 y8c0bbd7ecc77a0924dadce65a09b2ead146ad15 | 99 BTC  | e610b5905b0ce861099d9fc0aa2be222551b40b1
          -1 | 1518508125 | FROM RobinHood xb7a04e27dcbcfe0cedf06faa4f36c084d4a1a29   | TO PoorPerson2 efb71bb90b344a3495adf3457a8705c178beeb03 | 99 BTC  | 397835c2eaece6b52ba70d5afd8029da0ec94aea
          -1 | 1518508125 | FROM RobinHood xb7a04e27dcbcfe0cedf06faa4f36c084d4a1a29   | TO PoorPerson3 161897cffdbd367faedc1484f705788001acdbbb | 99 BTC  | e8a3d9e8af4472c2dec2084c5c00dae1c1943dce
          -1 | 1518508125 | FROM PoorPerson3 161897cffdbd367faedc1484f705788001acdbbb | TO PoorPerson4 27142e2859f95012f45951e47621bfd6153af46e | 9 BTC   | 19ab09deaafc72b79dd6999f96624dfd82a466b1
          -1 | 1518508125 | FROM PoorPerson3 161897cffdbd367faedc1484f705788001acdbbb | TO PoorPerson5 c40caa2ac5de6957097512e61bf0d590c3b7446d | 9 BTC   | ab39373683ccfdae1bd3d65703ce32158462bb1f
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

psql:demo.sql:126: ERROR:  P0001: **** Blockchain table has been altered!!!
CONTEXT:  PL/pgSQL function blockchaininpostgres.generateblock() line 23 at IF
LOCATION:  exec_stmt_raise, pl_exec.c:3216
 blockheight | eventepoch |                           info1                           |                          info2                          |  info3  |                eventhash
-------------+------------+-----------------------------------------------------------+---------------------------------------------------------+---------+------------------------------------------
           1 | 1518508125 | FROM RobinHood xb7a04e27dcbcfe0cedf06faa4f36c084d4a1a29   | TO PoorPerson1 y8c0bbd7ecc77a0924dadce65a09b2ead146ad15 | 99 BTC  | e610b5905b0ce861099d9fc0aa2be222551b40b1
           1 | 1518508125 | FROM GENESIS                                              | TO RobinHood y8c0bbd7ecc77a0924dadce65a09b2ead146ad15   | 999 BTC | c46c08b6f423f35593ddf2ba97c10e625237499b
           2 | 1518508125 | FROM RobinHood xb7a04e27dcbcfe0cedf06faa4f36c084d4a1a29   | TO PoorPerson2 efb71bb90b344a3495adf3457a8705c178beeb03 | 99 BTC  | 397835c2eaece6b52ba70d5afd8029da0ec94aea
           2 | 1518508125 | FROM RobinHood xb7a04e27dcbcfe0cedf06faa4f36c084d4a1a29   | TO PoorPerson3 161897cffdbd367faedc1484f705788001acdbbb | 99 BTC  | e8a3d9e8af4472c2dec2084c5c00dae1c1943dce
           3 | 1518508125 | FROM PoorPerson3 161897cffdbd367faedc1484f705788001acdbbb | TO PoorPerson4 27142e2859f95012f45951e47621bfd6153af46e | 9 BTC   | 19ab09deaafc72b79dd6999f96624dfd82a466b1
           3 | 1518508125 | FROM PoorPerson3 161897cffdbd367faedc1484f705788001acdbbb | TO PoorPerson5 c40caa2ac5de6957097512e61bf0d590c3b7446d | 9 BTC   | ab39373683ccfdae1bd3d65703ce32158462bb1f
(6 rows)


 blockheight | blockepoch |                eventshash                | nonce  |            previousblockhash             |                blockhash
-------------+------------+------------------------------------------+--------+------------------------------------------+------------------------------------------
           0 |          0 | 0                                        |      0 | 0                                        | genesis
           1 | 1518508125 | 081b070a137f8e8f66c08117a478f3815522020e | 491481 | genesis                                  | 0dd4c4e253e97dfcabad7c1302cf73f9a9fc0f38
           2 | 1518508125 | 9f3261c52ad2a0cd9539a6c5662e9c72716cc18d | 975633 | 0dd4c4e253e97dfcabad7c1302cf73f9a9fc0f38 | 0333336b6704e5284c317b430d3174756207c3ce
           3 | 1518508125 | ddbb3ac18c8b5cda7b5994f7ac3e72cda6a31be8 | 202485 | 0333336b6704e5284c317b430d3174756207c3ce | 06ea73cad402f3c42fd97fb16b921d78f2e229c9
           4 | 1518508125 | 9142739bc1b7310adb657aa2c53e9973f8753151 | 207390 | 06ea73cad402f3c42fd97fb16b921d78f2e229c9 | 0becc3ddab119f56452db3fe6ad63b896dc2f7c0
(5 rows)

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
