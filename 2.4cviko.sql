
exec PrintIndexes 'Customer';
exec PrintIndexLevelStats 'kuc0396', 'customer', 'PK__Customer__DC501A0CEB937419';
exec PrintPagesIndex 'PK__Customer__DC501A0CEB937419';

exec PrintIndexes 'OrderItem';
exec PrintIndexLevelStats 'kuc0396', 'orderitem', 'pk_orderitem';
exec PrintPagesIndex 'pk_orderitem';

exec PrintIndexes 'Store';
exec PrintIndexLevelStats 'kuc0396', 'store', 'PK__Store__9DBB2CF2D5C7E9F9';
exec PrintIndexStats 'kuc0396', 'store', 'PK__Store__9DBB2CF2D5C7E9F9';
exec PrintPagesIndex 'PK__Store__9DBB2CF2D5C7E9F9';

exec PrintIndexes 'Staff';
exec PrintIndexLevelStats 'kuc0396', 'staff', 'PK__Staff__9DBB2CFCBBD58AE3';
exec PrintPagesIndex 'PK__Staff__9DBB2CFCBBD58AE3';

exec PrintIndexes 'Order';
exec PrintIndexLevelStats 'kuc0396', 'order', 'PK__Order__DC501A00D2BF4AA6';
exec PrintPagesIndex 'PK__Order__DC501A00D2BF4AA6';

exec PrintIndexes 'Product';
exec PrintIndexLevelStats 'kuc0396', 'product', 'PK__Product__DC501A017300682E';
exec PrintPagesIndex 'PK__Product__DC501A017300682E';



--optimalizacia stranok
alter index PK__Store__9DBB2CF2D5C7E9F9
on Store rebuild;

exec PrintIndexLevelStats 'kuc0396', 'store', 'PK__Store__9DBB2CF2D5C7E9F9';
exec PrintIndexStats 'kuc0396', 'store', 'PK__Store__9DBB2CF2D5C7E9F9';

exec PrintPagesIndex 'PK__Store__9DBB2CF2D5C7E9F9';