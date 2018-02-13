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
select * from blockchainInPostgres.blockChain order by blockEpoch;


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
select * from blockchainInPostgres.blockChain order by blockEpoch;

\echo

select blockchainInPostgres.generateBlock() as "NowGeneratingBlock";

\echo ----------------------
--select * from blockchainInPostgres.events order by eventEpoch;
--select * from blockchainInPostgres.blockChain order by blockEpoch;

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
select * from blockchainInPostgres.blockChain order by blockEpoch;
\echo
\echo

alter table blockchainInPostgres.blockChain disable trigger readOnlyBlockChain;

select * from blockchainInPostgres.blockChain where blockHeight = 2;
update blockchainInPostgres.blockChain set blockEpoch = 1111111111 where blockHeight = 2;
select * from blockchainInPostgres.blockChain where blockHeight = 2;
select blockchainInPostgres.validateBlock() as "BlockValidationResult";


\echo
\echo
\echo Bitcoin blockchain example
alter table blockchainInPostgres.blockChain disable trigger readOnlyBlockChain;
alter table blockchainInPostgres.events     disable trigger readOnlyEvent;
delete from blockchainInPostgres.events;
delete from blockchainInPostgres.blockChain;
alter table blockchainInPostgres.blockChain enable trigger readOnlyBlockChain;
alter table blockchainInPostgres.events     enable trigger readOnlyEvent;
alter table blockchainInPostgres.events     enable trigger onEventInsert;

drop sequence if exists blockchainInPostgres.blockHeightSeq;
create sequence blockchainInPostgres.blockHeightSeq start 1;
insert into blockchainInPostgres.blockChain (blockHeight, blockEpoch, eventsHash, nonce, previousBlockHash, blockHash)
values (0, 0, 0, 0, 0, 'genesis');



\echo
insert into blockchainInPostgres.events (info1, info2, info3)
values ('FROM GENESIS','TO RobinHood y8c0bbd7ecc77a0924dadce65a09b2ead146ad15', '999 BTC')
     , ('FROM RobinHood xb7a04e27dcbcfe0cedf06faa4f36c084d4a1a29','TO PoorPerson1 y8c0bbd7ecc77a0924dadce65a09b2ead146ad15', '99 BTC')
     , ('FROM RobinHood xb7a04e27dcbcfe0cedf06faa4f36c084d4a1a29','TO PoorPerson2 efb71bb90b344a3495adf3457a8705c178beeb03', '99 BTC')
     , ('FROM RobinHood xb7a04e27dcbcfe0cedf06faa4f36c084d4a1a29','TO PoorPerson3 161897cffdbd367faedc1484f705788001acdbbb', '99 BTC')
     , ('FROM PoorPerson3 161897cffdbd367faedc1484f705788001acdbbb','TO PoorPerson4 27142e2859f95012f45951e47621bfd6153af46e', '9 BTC')
     , ('FROM PoorPerson3 161897cffdbd367faedc1484f705788001acdbbb','TO PoorPerson5 c40caa2ac5de6957097512e61bf0d590c3b7446d', '9 BTC')
;

select * from blockchainInPostgres.events order by eventEpoch;
select blockchainInPostgres.generateBlock() as "NowGeneratingBlock";
select blockchainInPostgres.generateBlock() as "NowGeneratingBlock";
select blockchainInPostgres.generateBlock() as "NowGeneratingBlock";
select blockchainInPostgres.generateBlock() as "NowGeneratingBlock";
select blockchainInPostgres.generateBlock() as "NowGeneratingBlock";
select * from blockchainInPostgres.events order by eventEpoch;
\echo
select * from blockchainInPostgres.blockChain order by blockEpoch;