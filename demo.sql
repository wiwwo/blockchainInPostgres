\echo
\echo inserting some events...
\echo note the date i try to insert, and what is really inserted..
insert into blockchainInPostgres.events (blockHeight, eventEpoch, info1, info2, info3) values (99, extract(epoch from current_timestamp - interval '10' day), 'VY1234','took off', '12 mins delay');
insert into blockchainInPostgres.events (blockHeight, eventEpoch, info1, info2, info3) values (123456, extract(epoch from current_timestamp - interval '22' day), 'VY1234','landed', '02 mins delay');
insert into blockchainInPostgres.events (blockHeight, eventEpoch, info1, info2, info3) values (987654, extract(epoch from current_timestamp - interval '1' day), 'VY4321','landed', '');

\echo
\echo trying to force events table...
\echo in blockchain, events table is append only!
delete from blockchainInPostgres.events;
update blockchainInPostgres.events set info1='xxx';

\echo
\echo take a look at events table
select * from blockchainInPostgres.events;

\echo
\echo ----------
\echo MINING...
\echo ----------
begin;
select blockchainInPostgres.generateBlock();
commit;
\echo
\echo take a look at events table again
select * from blockchainInPostgres.events;
\echo
\echo and at blockchain table
select * from blockchainInPostgres.blockChain;


\echo
\echo some more inserts...
insert into blockchainInPostgres.events (blockHeight, eventEpoch, info1, info2, info3) values (556, extract(epoch from current_timestamp - interval '50' day), 'Product 8896513573165','Expires', '2018-09-23');
insert into blockchainInPostgres.events (blockHeight, eventEpoch, info1, info2, info3) values (21355, extract(epoch from current_timestamp - interval '9' day), 'Part 578285471821','Produced', 'Factory DE2742');

\echo
\echo trying -AGAIN- to force events table...
\echo in blockchain, events table is append only!
delete from blockchainInPostgres.events;
update blockchainInPostgres.events set info1='xxx';


select * from blockchainInPostgres.events;
\echo
\echo ----------
\echo MINING...
\echo ----------
select blockchainInPostgres.generateBlock();
select * from blockchainInPostgres.blockChain;


