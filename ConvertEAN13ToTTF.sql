USE [DBNAME]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[ConvertEAN13toTTF]( @barcode nvarchar( 20 ) )
RETURNS nvarchar(30)
AS
BEGIN
	DECLARE @Result nvarchar(30)
	DECLARE @i int, @cur int, @fst int, @lrgType int
	DECLARE @Template char(60)
	DECLARE @chr char(1)
	DECLARE @checkASCII bit
	
	-- L = 1, G = 2, R = 3; digits in the first group of six are encoded using these patterns
	SELECT @Template = '111111' + '112122' + '112212' + '112221' + '121122' + '122112'
			+ '122211' + '121212' + '121221' + '122121'

	SELECT @Result = dbo.ConvertEAN13ToTTFHelper( 4, 0 )
	
	SELECT @checkASCII = 0, @i = 1
	WHILE @i <= len( @barcode )
	BEGIN
		SELECT @chr = SUBSTRING( @barcode, @i, 1 )
		if ( ASCII( @chr ) < 48 ) OR ( ( ASCII( @chr ) > 57 ) ) -- check digit literal
		BEGIN
			SELECT @checkASCII = 1
			BREAK;
		END
		
		SELECT @i = @i + 1
	END
		
	IF ( @checkASCII = 1 ) OR ( len( @barcode ) <> 13 )
	BEGIN
		SELECT @Result = @Result + 'INCORRECT EAN13-BARCODE'
	END 
	ELSE
	BEGIN	
		SELECT @fst = CONVERT( int, SUBSTRING( @barcode, 1, 1 ) ) -- first digit
		
		SELECT @i = 2
		
		WHILE ( @i <= 13 )
		BEGIN
			SELECT @cur = CONVERT( int, SUBSTRING( @barcode, @i, 1 ) )
						
			if ( @i < 8 ) 
				SELECT @lrgType = CONVERT( int, SUBSTRING( @Template, @fst * 6 + @i - 1, 1 ) )
			ELSE SELECT @lrgType = 3 -- Last group of 6 digits = 'RRRRRR'
				
			SELECT @Result = @Result + dbo.ConvertEAN13ToTTFHelper( @lrgType, @cur )
							
			if ( @i = 7 ) 
				SELECT @Result = @Result + dbo.ConvertEAN13ToTTFHelper( 4, 1 )
			
			SELECT @i = @i + 1
		END
	END
	
	SELECT @Result = @Result + dbo.ConvertEAN13ToTTFHelper( 4, 2 )
	
	RETURN @Result
END
