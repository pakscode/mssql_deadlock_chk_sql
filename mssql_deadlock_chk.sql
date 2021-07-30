----------------------------------------------------------------------------
--- This script is used to check MS SQL Server Deadlock and 
--- show the locking SQL statments so that you are able to 
--- find out what's wrong in your application
---
--- Source URL: https://github.com/happycodefarmer/mssql_deadlock_chk_sql
----------------------------------------------------------------------------
SELECT 	
	TL.request_session_id [Session ID]
	,WT.blocking_session_id [Locked By ID]
	,DB.name [DB_Name]
	,lock_txt.TEXT AS [Locking_SQL]
	,txt.TEXT AS [Waiting SQL]
	,TL.resource_type [Resource Type]
	,TL.resource_database_id [DB ID]

	,TL.resource_associated_entity_id
	,TL.request_mode	
	
	,O.name AS [object name]
	,O.type_desc AS [object descr]
	,P.partition_id AS [partition id]
	,P.rows AS [partition/page rows]
	,AU.type_desc AS [index descr]
	,AU.container_id AS [index/page container_id]
	
FROM sys.dm_tran_locks AS TL
INNER JOIN sys.dm_os_waiting_tasks AS WT ON TL.lock_owner_address = WT.resource_address
INNER JOIN sys.databases DB ON DB.database_id = TL.resource_database_id
LEFT OUTER JOIN sys.objects AS O ON O.object_id = TL.resource_associated_entity_id
LEFT OUTER JOIN sys.partitions AS P ON P.hobt_id = TL.resource_associated_entity_id
LEFT OUTER JOIN sys.allocation_units AS AU ON AU.allocation_unit_id = TL.resource_associated_entity_id
LEFT JOIN sys.dm_exec_connections AS c ON TL.request_session_id = c.session_id
LEFT JOIN sys.dm_exec_connections AS d ON WT.blocking_session_id = d.session_id
CROSS APPLY sys.dm_exec_sql_text(c.most_recent_sql_handle) txt
OUTER APPLY sys.dm_exec_sql_text(d.most_recent_sql_handle) lock_txt