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
,eventEpoch   numeric       not null
,info1        varchar(100)  not null
,info2        varchar(100)  not null
,info3        varchar(100)  not null
,eventHash    varchar (42)  not null
);

--- Proc for trigger; forbids deletes and updates on EVENTS table
-- TODO: change to raise an exception
create or replace function blockchainInPostgres.doNothign()
returns trigger
language plpgsql as
$$
begin
  return null;
end
$$;

--- Proc for trigger; fills in fields not allowed to be populated (AKA manipulated)
create or replace function blockchainInPostgres.eventsInsert()
returns trigger
language plpgsql as
$$
declare
  currentEpoch    integer = extract(epoch from current_timestamp);
begin

  NEW.blockHeight = -1;
  NEW.eventEpoch = currentEpoch;
  NEW.eventHash = encode(digest(NEW.info1||'-'||NEW.info2||'-'||NEW.info3||'-'||currentEpoch, 'sha1'),'hex');
  return NEW;
end
$$;

--- Forbids deletes and updates on EVENTS table
drop trigger if exists readOnlyEvent on blockchainInPostgres.events;
create trigger readOnlyEvent
before delete or update on blockchainInPostgres.events
for each row
execute procedure blockchainInPostgres.doNothign();

--- Fills in fields not allowed to be populated (AKA manipulated) by user
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
,blockEpoch   numeric       not null
,eventsHash   varchar(42)   not null
,nonce        integer       not null
,blockHash    varchar(42)   not null
);


--- Here is the fun!
-- This proc takes pending events (EVENTS.blockHeight = -1),
-- creates new block, associates those transactions to newly created block,
-- and calculates (as in MINES) the block hash
create or replace function blockchainInPostgres.generateBlock()
returns boolean
language plpgsql as
$$
declare
    blockSize           integer = 2;
    hashCursor          cursor for
                          select eventHash from blockchainInPostgres.events where blockHeight=-1 order by eventepoch limit blockSize;
    thisHash            varchar(50) = ' ';
    cumulativeHash      varchar(50) = ' ';

    loopLimit           integer = 999999;
    miningDifficulty    integer = 1;
    thisNonce           integer = 0;
    blockHash           varchar(50) = ' ';

    regExpDifficulty    varchar(50);
    firstBlockHashChar  char(1);

begin

  -- Disables trigger on EVENTS table, to update pending events blockHeight
  alter table blockchainInPostgres.events disable trigger readOnlyEvent;

  -- For every pending event...
  open hashCursor;
  loop
    fetch hashCursor into thisHash;
    exit when not found;

    -- Transaction state put to Pending
    update blockchainInPostgres.events set blockHeight=-99 where eventhash = thisHash;

    -- ... calculate the cumulative hash
    raise debug 'thisHash % ', thisHash;
    cumulativeHash = encode(digest(cumulativeHash || '-' || thisHash, 'sha1'),'hex');

  end loop;
  close hashCursor;
  raise debug 'cumulativeHash % ', cumulativeHash;

  --- Mining now!!!
  --- Proof of Work
  -- A valid block is a block whose hash starts [as many ZEROES as miningDifficulty]
  -- That is
  --  hash(hash(event1+hash(event2+hash(event3))))+nonce) = 0whateverhash   for miningDifficulty = 1
  --  hash(hash(event1+hash(event2+hash(event3))))+nonce) = 00whateverhash  for miningDifficulty = 2
  --  hash(hash(event1+hash(event2+hash(event3))))+nonce) = 000whateverhash for miningDifficulty = 3
  -- etc
  -- In reality, it should be hash(event1)+hash(event2) etc...
  regExpDifficulty = '^(0){'||miningDifficulty||'}';
  --
  -- you might want to use this
  --regExpDifficulty = '^([0-9]){'||miningDifficulty||'}';
  -- to make mining easier; instead of starting with 0, a valid nonce generates an hash with any digit ( regExp [0-9])
  --

  -- Start mining!
  loop

    -- try current nonce
    blockHash = encode(digest(cumulativeHash || '-' || thisNonce, 'sha1'),'hex');
    firstBlockHashChar = substring(blockHash from 1 for 1);

    -- as a safety measure, if i get to loopLimit loops, give up
    exit when thisNonce = loopLimit or (substring(firstBlockHashChar from 1 for miningDifficulty) ~ regExpDifficulty );

    thisNonce = thisNonce +1;

  end loop;
  -- if i gave up, just write down a fake nonce in BLOCKCHAIN table
  if thisNonce = loopLimit
  then
    thisNonce = -99999;
  end if;

  insert into blockchainInPostgres.blockChain (blockHeight, blockEpoch, eventsHash, nonce, blockHash)
  values (nextval('blockchainInPostgres.blockHeightSeq'), extract(epoch from current_timestamp), cumulativeHash, thisNonce, encode(digest(cumulativeHash||'-'||thisNonce, 'sha1'),'hex'));

  -- pending events are assigned to the current block
  update blockchainInPostgres.events set blockHeight=lastval() where blockHeight=-99;

  -- Enable the trigger back
  alter table blockchainInPostgres.events enable trigger readOnlyEvent;

  return true;
end
$$;

-- TODO
create or replace function blockchainInPostgres.validateBlock()
returns boolean
language plpgsql as
$$
declare
    eventsCursor      cursor (p_blockHeight integer) for
                        select info1, info2, info3, eventHash
                          from blockchainInPostgres.events
                         where blockHeight=p_blockHeight
                      order by eventEpoch, blockHeight;
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
