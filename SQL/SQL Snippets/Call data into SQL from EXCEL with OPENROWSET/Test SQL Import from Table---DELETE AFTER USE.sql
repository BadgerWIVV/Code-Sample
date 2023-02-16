SELECT *
FROM OPENROWSET( 'Microsoft.ACE.OLEDB.12.0',
'Excel 12.0 Xml; HDR= YES;
Database = FullFilePath\Test SQL Import from Table---DELETE AFTER USE.xlsx',
'SELECT * FROM [TestWorkbookInput$]');