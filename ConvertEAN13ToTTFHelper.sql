USE [DBNAME]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].ConvertEAN13ToTTFHelper( @NType int, @NNum int )
RETURNS char(1)
AS
BEGIN
	DECLARE @Result char(1)
	
	DECLARE @Template char(33)		

	-- L-code: 0-9 +  G-code: 0-9 + R-code: 0-9 + start symbol + middle symbol + end symbol
	SELECT @Template = '0123456789' + 'ABCDEFGHIJ' + '&''()*+,-./' + '[=]'
		
	SELECT @Result = SUBSTRING( @Template, 10* (@NType - 1) + @NNum + 1, 1)
	
	RETURN @Result
END
