\timing off
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
select * from blockchainInPostgres.events order by eventEpoch;

\echo

begin;
select blockchainInPostgres.generateBlock() as "NowGeneratingBlock";
commit;
\echo
\echo take a look at events table again
select * from blockchainInPostgres.events order by eventEpoch;
\echo
\echo and at blockchain table
select * from blockchainInPostgres.blockChain order by blockepoch;


\echo
\echo some more inserts...
insert into blockchainInPostgres.events (blockHeight, eventEpoch, info1, info2, info3) values (556, extract(epoch from current_timestamp - interval '50' day), 'Product 8896513573165','Expires', '2018-09-23');
insert into blockchainInPostgres.events (blockHeight, eventEpoch, info1, info2, info3) values (21355, extract(epoch from current_timestamp - interval '9' day), 'Part 578285471821','Produced', 'Factory DE2742');

\echo
\echo trying -AGAIN- to force events table...
\echo in blockchain, events table is append only!
delete from blockchainInPostgres.events;
update blockchainInPostgres.events set info1='xxx';


select * from blockchainInPostgres.events order by eventEpoch;
\echo
select blockchainInPostgres.generateBlock() as "NowGeneratingBlock";
select * from blockchainInPostgres.blockChain order by blockepoch;

\echo

select blockchainInPostgres.generateBlock() as "NowGeneratingBlock";

\echo ----------------------
--select * from blockchainInPostgres.events order by eventEpoch;
--select * from blockchainInPostgres.blockChain order by blockepoch;

select blockchainInPostgres.validateBlock() as "BlockValidationResult";


\echo
\echo
\echo ---------------------------------
\echo ---------------------------------
\echo Now, force an update, and make validation fail
alter table blockchainInPostgres.events disable trigger readOnlyEvent;
select * from blockchainInPostgres.events where info1='VY1234' and info2='landed';
update blockchainInPostgres.events set info3='on time' where info1='VY1234' and info2='landed';
select * from blockchainInPostgres.events where info1='VY1234' and info2='landed';
select blockchainInPostgres.validateBlock() as "BlockValidationResult";

\echo
\echo ---------------------------------
\echo Now, reset field, check again, then break blockchain table
update blockchainInPostgres.events set info3='02 mins delay' where info1='VY1234' and info2='landed';
select blockchainInPostgres.validateBlock() as "BlockValidationResult";
\echo
\echo
\echo
select * from blockchainInPostgres.events order by eventEpoch;
\echo
select * from blockchainInPostgres.blockChain order by blockepoch;
\echo
\echo

select * from blockchainInPostgres.blockChain where blockHeight = 2;
update blockchainInPostgres.blockChain set blockEpoch = 1111111111 where blockHeight = 2;
select * from blockchainInPostgres.blockChain where blockHeight = 2;
select blockchainInPostgres.validateBlock() as "BlockValidationResult";

