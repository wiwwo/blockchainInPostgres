-- install package postgresql-contrib-{pg_version}

create extension pgcrypto;


drop schema if exists blockchainInPostgres cascade;
drop role if exists blockchainInPostgres;
create schema blockchainInPostgres;
create role blockchainInPostgres;

--- --- --- --- --- --- ---
--- EVENTS table
--- --- --- --- --- --- ---
drop table if exists blockchainInPostgres.events;
create table blockchainInPostgres.events (
 blockHeight  integer       not null
,eventDate    date          not null
,info1        varchar(100)  not null
,info2        varchar(100)  not null
,info3        varchar(100)  not null
,eventHash    varchar (42)  not null
);

--- COMMENT HERE
create or replace function blockchainInPostgres.doNothign()
returns trigger
language plpgsql as
$$
begin
  return null;
end
$$;

--- COMMENT HERE
create or replace function blockchainInPostgres.eventsInsert()
returns trigger
language plpgsql as
$$
begin
  NEW.blockHeight = -1;
  NEW.eventDate= current_timestamp;
  NEW.eventHash = encode(digest(NEW.info1||'-'||NEW.info2||'-'||NEW.info3, 'sha1'),'hex');
  return NEW;
end
$$;

--- COMMENT HERE
drop trigger if exists readOnlyEvent on blockchainInPostgres.events;
create trigger readOnlyEvent
before delete or update on blockchainInPostgres.events
for each row
execute procedure blockchainInPostgres.doNothign();

--- COMMENT HERE
drop trigger if exists onEventInsert on blockchainInPostgres.events;
create trigger onEventInsert
before insert on blockchainInPostgres.events
for each row
execute procedure blockchainInPostgres.eventsInsert();



--- --- --- --- --- --- ---
--- BLOCKCHAIN table
--- --- --- --- --- --- ---
drop sequence if exists blockchainInPostgres.blockHeightSeq;
create sequence blockchainInPostgres.blockHeightSeq;

create table blockchainInPostgres.blockChain (
 blockHeight  integer       not null
,blockDate    date          not null
,eventsHash   varchar(42)   not null
,nonce        integer       not null
,blockHash    varchar(42)   not null
);


create or replace function blockchainInPostgres.generateBlock()
returns boolean
language plpgsql as
$$
declare
    hashCursor          cursor for
                          select eventHash from blockchainInPostgres.events where blockHeight=-1;
    thisHash            varchar(50) = ' ';
    cumulativeHash      varchar(50) = ' ';

    loopLimit           integer = 999999;
    miningDifficulty    integer = 1;
    thisNonce           integer = 0;
    blockHash           varchar(50) = ' ';

    regExpDifficulty    varchar(50);
    firstBlockHashChar  char(1);

begin

  alter table blockchainInPostgres.events disable trigger readOnlyEvent;

  open hashCursor;
  loop
    fetch hashCursor into thisHash;
    exit when not found;

    raise debug 'thisHash % ', thisHash;
    cumulativeHash = encode(digest(cumulativeHash || '-' || thisHash, 'sha1'),'hex');

  end loop;
  close hashCursor;
  raise debug 'cumulativeHash % ', cumulativeHash;

  --- Proof of Work
  -- "miningDifficulty"-times 0
  --regExpDifficulty = '^([0-9]){'||miningDifficulty||'}'; -- use this to make mining easier
  regExpDifficulty = '^(0){'||miningDifficulty||'}';

  -- Start mining!
  loop

    blockHash = encode(digest(cumulativeHash || '-' || thisNonce, 'sha1'),'hex');
    firstBlockHashChar = substring(blockHash from 1 for 1);

    exit when thisNonce = loopLimit or (substring(firstBlockHashChar from 1 for miningDifficulty) ~ regExpDifficulty );

    thisNonce = thisNonce +1;

  end loop;
  if thisNonce = loopLimit
  then
    thisNonce = -99999;
  end if;

  insert into blockchainInPostgres.blockChain (blockHeight, blockDate, eventsHash, nonce, blockHash)
  values (nextval('blockchainInPostgres.blockHeightSeq'), current_timestamp, cumulativeHash, thisNonce, encode(digest(cumulativeHash||'-'||thisNonce, 'sha1'),'hex'));

  update blockchainInPostgres.events set blockHeight=lastval() where blockHeight=-1;

  --alter table blockchainInPostgres.events enable trigger readOnlyEvent;

  return true;
end
$$;


create or replace function blockchainInPostgres.validateBlock()
returns boolean
language plpgsql as
$$
declare
    eventsCursor      cursor (p_blockHeight integer) for
                        select info1, info2, info3, eventHash
                          from blockchainInPostgres.events
                         where blockHeight=p_blockHeight
                      order by eventDate, blockHeight;
    thisRow           record;

    maxBlock          numeric;

    thisHash          varchar(50);
    cumulativeHash    varchar(50) = ' ';

    thisNonce         integer = 0;
begin

  select max(blockHeight)
  into maxBlock
  from blockchainInPostgres.blockChain;

  for thisBlock in 1..maxblock loop
    open eventsCursor (thisBlock);
    loop
      fetch eventsCursor into thisRow;
      exit when not found;

      raise debug 'thisHash % ', thisRow;

    end loop;

    close eventsCursor;
  end loop; -- for i in 1..maxblock loop
  return true;
end
$$;

--https://stackoverflow.com/questions/25425944/does-postgres-support-nested-or-autonomous-transactions
