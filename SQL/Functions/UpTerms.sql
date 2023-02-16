USE [WEA]
GO

/****** Object:  UserDefinedFunction [dbo].[upTerms]    Script Date: 6/2/2022 4:35:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[upTerms] ( @InputString varchar(4000) ) 
RETURNS VARCHAR(4000)
AS
BEGIN
DECLARE @Result integer
DECLARE @Term char(2);
DECLARE @OutputString   VARCHAR(4000)
DECLARE @Index          INT
DECLARE @RowsToProcess  INT
DECLARE @Counter		INT = 1
DECLARE @SearchString   VARCHAR(4);
DECLARE @TermList TABLE
( rowId INT identity(1,1),
  term CHAR(2)
)



-- Populate TermList table variable
INSERT INTO @TermList(term)
VALUES ('WI'), ('MD'), ('OD'), ('DO'), ('DC'), ('PC'), ('PT'), ('SC'), ('UW'), ('PA'), ('MS')/*, ('GI')*/;
SET @RowsToProcess=@@ROWCOUNT;

-- Call initCap here
SET @OutputString=dbo.initCap(@InputString);

WHILE(@Counter < @RowsToProcess)
BEGIN
  
  -- Get the next term from the table
  SET @Term=(SELECT term
  FROM @TermList
  WHERE RowID = @Counter);

  -- Search String will have spaces at beginning and end
  set @SearchString = ' ' + @Term + ' ';

  set @Result=CASE WHEN CHARINDEX(@SearchString, replace(replace(upper(@OutputString), '.', ' '), ',', ' ')) = 0
	THEN  -- try it without the trailing space in case it is at the end of the string 
	  CHARINDEX(substring(@SearchString, 1, 3), replace(replace(upper(@OutputString), '.', ' '), ',', ' '))
	ELSE 
	  CHARINDEX(@SearchString, replace(replace(upper(@OutputString), '.', ' '), ',', ' '))
	END;

  if @Result > 0
    set @OutputString=stuff(@OutputString, @Result+1, 2, @Term);

  SET @Counter = @Counter + 1;

END

-- include exceptions here for three-letter acronyms, abbreviations, and other misspellings

	SET @OutputString = REPLACE(@OutputString,'Belllin','Bellin');
	SET @OutputString = REPLACE(@OutputString, 'Giillett', 'Gillett');
	SET @OutputString = REPLACE(@OutputString, 'Viilage', 'Village');
	SET @OutputString = REPLACE(@OutputString, 'Cliinic', 'Clinic');
	SET @OutputString = REPLACE(@OutputString, 'Cliinc', 'Clinic');
	SET @OutputString = REPLACE(@OutputString, 'Liincolnshire', 'Lincolnshire');
	SET @OutputString = REPLACE(@OutputString, 'Marys', 'Mary''s');
	SET @OutputString = REPLACE(@OutputString, ' Llc', ' LLC');
	SET @OutputString = REPLACE(@OutputString, ' Dmd', ' DMD');
	SET @OutputString = REPLACE(@OutputString, ' Dpm', ' DPM');
	SET @OutputString = REPLACE(@OutputString, ' Dds', ' DDS');
	SET @OutputString = REPLACE(@OutputString, ' Llp', ' LLP');
	SET @OutputString = REPLACE(@OutputString, ' Ltd', ' LTD');
	SET @OutputString = REPLACE(@OutputString, ' Phd', ' PhD');
	SET @OutputString = REPLACE(@OutputString, 'Vhs','VHS');
	SET @OutputString = REPLACE(@OutputString, 'Vpa','VPA');
	SET @OutputString = REPLACE(@OutputString, 'Ghs', 'GHS');
	SET @OutputString = REPLACE(@OutputString, 'Sghs', 'SGHS');
	SET @OutputString = REPLACE(@OutputString, 'Epmg', 'EPMG');
	SET @OutputString = REPLACE(@OutputString, 'Ebi,', 'EBI,');
	SET @OutputString = REPLACE(@OutputString, 'Ht ,', 'HT ,');
	SET @OutputString = REPLACE(@OutputString, 'Hti ', 'HTI ');
	SET @OutputString = REPLACE(@OutputString, 'Nwtx', 'NWTX');
	SET @OutputString = REPLACE(@OutputString, 'Nwct', 'NWCT');
	SET @OutputString = REPLACE(@OutputString, 'Nwa', 'NWA');
	SET @OutputString = REPLACE(@OutputString, 'Nwi', 'NWI');
	SET @OutputString = REPLACE(@OutputString, 'Ssc', 'SSC');
	SET @OutputString = REPLACE(@OutputString, ' Gb', ' GB');
	SET @OutputString = REPLACE(@OutputString, 'Vbems', 'VBEMS');
	SET @OutputString = REPLACE(@OutputString, ' Msw', ' MSW');
	SET @OutputString = REPLACE(@OutputString, ' Lcsw', ' LCSW');
	SET @OutputString = REPLACE(@OutputString, ' Ltd', ' LTD');
	SET @OutputString = REPLACE(@OutputString, 'WiSC', 'Wisc');
	SET @OutputString = REPLACE(@OutputString, 'Mri', 'MRI');
	SET @OutputString = REPLACE(@OutputString, 'Rgh', 'RGH');
	SET @OutputString = REPLACE(@OutputString, 'Cjr', 'CJR');
	SET @OutputString = REPLACE(@OutputString, 'Lcm', 'LCM');
	SET @OutputString = REPLACE(@OutputString, 'Gi ', 'GI ');
	SET @OutputString = REPLACE(@OutputString, 'Ivf', 'IVF');
	SET @OutputString = REPLACE(@OutputString, ' Pmtc', ' PMTC');
	SET @OutputString = REPLACE(@OutputString, ' Pllc', ' PLLC');
	SET @OutputString = REPLACE(@OutputString, ' Dacnb', ' DACNB');
	SET @OutputString = REPLACE(@OutputString, ' At ', ' at ');
	SET @OutputString = REPLACE(@OutputString, ' Of ', ' of ');
	SET @OutputString = REPLACE(@OutputString, ' Ll', ' LL');
	SET @OutputString = REPLACE(@OutputString, ' Lp', ' LP');
	SET @OutputString = REPLACE(@OutputString, 'Ecg', 'ECG');
	SET @OutputString = REPLACE(@OutputString, 'Ccc-A', 'CCC-A');
	SET @OutputString = REPLACE(@OutputString, 'Hma', 'HMA');
	SET @OutputString = REPLACE(@OutputString, 'Phc', 'PHC');
	SET @OutputString = REPLACE(@OutputString, ' Ii', ' II');
	SET @OutputString = REPLACE(@OutputString, ' Iii', ' III');
	SET @OutputString = REPLACE(@OutputString, ' Xi', ' XI');
	SET @OutputString = REPLACE(@OutputString, ' Xii', ' XII');
	SET @OutputString = REPLACE(@OutputString, ' Xiii', ' XIII');
	SET @OutputString = REPLACE(@OutputString, ' Xxiv', ' XXIV');
	SET @OutputString = REPLACE(@OutputString, 'Ecep', 'ECEP');
	SET @OutputString = REPLACE(@OutputString, 'Lj', 'LJ');
	SET @OutputString = REPLACE(@OutputString, 'Rta', 'RTA');

	IF (@OutputString LIKE 'Dme %') OR (@OutputString LIKE '% Dme%')
		SET @OutputString = REPLACE(@OutputString, 'Dme', 'DME');

	IF ((@OutputString LIKE 'Rt %') OR (@OutputString LIKE '%Rt,%'))
		SET @OutputString = REPLACE(@OutputString, 'Rt', 'RT');

	IF (@OutputString LIKE 'Iv %') OR (@OutputString LIKE '% Iv') OR (@OutputString LIKE '%Iv,%')
		SET @OutputString = REPLACE(@OutputString, 'Iv', 'IV');
		
	IF (@OutputString LIKE '% Pa') OR (@OutputString LIKE '%, Pa')
		SET @OutputString = REPLACE(@OutputString, ' Pa', ' PA');

	IF (@OutputString LIKE 'Da %')
		SET @OutputString = REPLACE(@OutputString, 'Da ', 'DA ');
	
	IF (@OutputString LIKE '%PAul%')
		SET @OutputString = REPLACE(@OutputString, 'PAul', 'Paul');

	IF (@OutputString  LIKE '% Mc') OR (@OutputString LIKE '% Mc,%')
		SET @OutputString = REPLACE(@OutputString, ' Mc', ' MC');
	IF (@OutputString LIKE '% Pl')
		SET @OutputString = REPLACE(@OutputString, ' Pl', ' PL');
	IF (@OutputString LIKE '% Er') OR (@OutputString LIKE '% Er%') OR (@OutputString LIKE 'Er %')
		SET @OutputString = REPLACE(@OutputString, 'Er', 'ER');
	IF (@OutputString LIKE '% Lp')
		SET @OutputString = REPLACE(@OutputString, ' Lp', ' LP');
	IF (@OutputString LIKE '% Lb')
		SET @OutputString = REPLACE(@OutputString, ' Lb', ' LB');
	IF (@OutputString NOT LIKE '% DO %') AND (@OutputString NOT LIKE '% DO') AND (@OutputString NOT LIKE '% DO,%')
		SET @OutputString = REPLACE(@OutputString, ' DO', ' Do');
	IF (@OutputString LIKE 'Ems %') OR (@OutputString LIKE '% Ems') OR (@OutputString LIKE '% Ems %') OR (@OutputString LIKE '% Ems,%')
		SET @OutputString = REPLACE(@OutputString, 'Ems', 'EMS');
	IF (@OutputString NOT LIKE '% MD %') AND (@OutputString NOT LIKE '% MD') AND (@OutputString NOT LIKE '% MD,%')
		SET @OutputString = REPLACE(@OutputString, ' MD', ' Md');
	ELSE
		SET @OutputString = REPLACE(@OutputString, ' Md', ' MD');
	IF (@OutputString LIKE '% SC%') AND ((@OutputString NOT LIKE '% SC') AND (@OutputString NOT LIKE '% SC %'))
		SET @OutputString = REPLACE(@OutputString, 'SC', 'Sc');

	IF (@OutputString LIKE 'Ent %') OR (@OutputString LIKE '% Ent %') OR (@OutputString LIKE '% Ent,%')
		SET @OutputString = REPLACE(@OutputString, 'Ent', 'ENT'); 

	IF (@OutputString LIKE '%WiSconsin%' OR @OutputString LIKE '%WiSc%' OR @OutputString LIKE '%ReScu%') AND @OutputString NOT LIKE '% Sc%'
		SET @OutputString = REPLACE(@OutputString, 'Sc', 'sc');

	IF ((@OutputString like '% Fl') OR (@OutputString LIKE '% Fl %') OR (@OutputString LIKE '%Fl,%'))
		SET @OutputString = REPLACE(@OutputString, ' Fl', ' FL');

	IF (@OutputString NOT LIKE '% WI %') OR (@OutputString NOT LIKE 'WI %') OR (@OutputString NOT LIKE '% WI,%') OR (@OutputString NOT LIKE '% WI')
		SET @OutputString = REPLACE(@OutputString, 'WI', 'Wi');

	IF ((@OutputString like '% Wy') OR (@OutputString LIKE '% Wy %') OR (@OutputString LIKE '%Wy,%'))
		SET @OutputString = REPLACE(@OutputString, ' Wy', 'WY');

	IF ((@OutputString like '% Mi') OR (@OutputString LIKE '% Mi %') OR (@OutputString LIKE '%Mi,%'))
		SET @OutputString = REPLACE(@OutputString, ' Mi', 'MI');

	IF ((@OutputString like '% Mn') OR (@OutputString LIKE '% Mn %') OR (@OutputString LIKE '%Mn,%'))
		SET @OutputString = REPLACE(@OutputString, ' Mn', ' MN');

	IF ((@OutputString like '% Wy') OR (@OutputString LIKE '% Nd %') OR (@OutputString LIKE '%Nd,%'))
	SET @OutputString = REPLACE(@OutputString, ' Nd', ' ND');

	IF ((@OutputString like '% Wy') OR (@OutputString LIKE '% Sd %') OR (@OutputString LIKE '%Sd,%'))
		SET @OutputString = REPLACE(@OutputString, ' Sd', ' SD');

	IF ((@OutputString like '% Az') OR (@OutputString LIKE '% Az %') OR (@OutputString LIKE '%Az,%'))
		SET @OutputString = REPLACE(@OutputString, ' Az', ' AZ');

	IF ((@OutputString like '% Pa') OR (@OutputString LIKE '% Pa %') OR (@OutputString LIKE '%Pa,%'))
		SET @OutputString = REPLACE(@OutputString, ' Pa', ' PA');

	IF ((@OutputString like '% Nv') OR (@OutputString LIKE '% Nv %') OR (@OutputString LIKE '%Nv,%'))
		SET @OutputString = REPLACE(@OutputString, ' Nv', ' NV');

	IF ((@OutputString like '% Nw %') OR (@OutputString LIKE '% Nw') OR (@OutputString LIKE 'Nw %'))
		SET @OutputString = REPLACE(@OutputString, 'Nw', 'NW');

	IF ((@OutputString like '% Ne %') OR (@OutputString LIKE '% Ne') OR (@OutputString LIKE 'Ne %'))
		SET @OutputString = REPLACE(@OutputString, 'Ne', 'NE');

	IF ((@OutputString like '% Se %') OR (@OutputString LIKE '% Se') OR (@OutputString LIKE 'Se %'))
		SET @OutputString = REPLACE(@OutputString, 'Se', 'SE');

	IF ((@OutputString like '% Sw %') OR (@OutputString LIKE '% Sw') OR (@OutputString LIKE 'Sw %'))
		SET @OutputString = REPLACE(@OutputString, 'Sw', 'SW');

	IF (@OutputString LIKE 'Uw %')
		SET @OutputString = REPLACE(@OutputString, 'Uw', 'UW')
	


RETURN LTRIM(@OutputString);

END
GO


