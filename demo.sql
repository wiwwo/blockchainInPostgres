insert into blockchainInPostgres.events (blockHeight, eventDate, info1, info2, info3) values (99, current_timestamp - interval '10' day, 'VY1234','took off', '12 mins delay');
insert into blockchainInPostgres.events (blockHeight, eventDate, info1, info2, info3) values (123456, current_timestamp - interval '22' day, 'VY1234','landed', '02 mins delay');
insert into blockchainInPostgres.events (blockHeight, eventDate, info1, info2, info3) values (987654, current_timestamp - interval '1' day, 'VY4321','landed', '');
delete from blockchainInPostgres.events;
update blockchainInPostgres.events set info1='xxx';

select * from blockchainInPostgres.events;

\echo
\echo
\echo MINING...
\echo
select blockchainInPostgres.generateBlock();
-- https://duckduckgo.com/?q=sha1+%224c054602d5420490806e042b4b9e2375c695c264-7%22
-- Need to do this outside
alter table blockchainInPostgres.events enable trigger readOnlyEvent;
--
select * from blockchainInPostgres.blockChain;



insert into blockchainInPostgres.events (blockHeight, eventDate, info1, info2, info3) values (556, current_timestamp - interval '50' day, 'Product 8896513573165','Expires', '2018-09-23');
insert into blockchainInPostgres.events (blockHeight, eventDate, info1, info2, info3) values (21355, current_timestamp - interval '9' day, 'Part 578285471821','Produced', 'Factory DE2742');



select * from blockchainInPostgres.events;
\echo
\echo
\echo MINING...
\echo
select blockchainInPostgres.generateBlock();
-- Need to do this outside
alter table blockchainInPostgres.events enable trigger readOnlyEvent;
--
select * from blockchainInPostgres.blockChain;
