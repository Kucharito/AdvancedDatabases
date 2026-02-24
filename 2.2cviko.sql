exec PrintIndexes 'OrderItem';

alter table OrderItem
drop constraint pk_orderitem;

exec PrintIndexes 'OrderItem';

alter table OrderItem
add constraint pk_orderitem
primary key clustered(ido, idp);