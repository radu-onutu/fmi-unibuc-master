select * from secbd0.keys_table;

create table t (x number);
grant select on t to public;
select * from secbd0.t;

insert into t values (1);

select * from secbd0.t;

alter table t add(y number);
