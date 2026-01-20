-- CLR ----------------------------------------------------------------------------------------------------------------
--
-- The MD5 function is used to calculate hashes on which comparisons are made for data types that do
-- not support equality checking, and for which 'checksum' has been selected. The reason for not
-- using the built in HashBytes is that it is limited to inputs up to 8000 bytes.
--
-- MD5 function -------------------------------------------------------------------------------------------------------
-- MD5 hashing function
-----------------------------------------------------------------------------------------------------------------------
DECLARE @version smallint =
    CASE 
        WHEN patindex('% 2[0-2][0-9][0-9] %', @@VERSION) > 0
        THEN substring(@@VERSION, patindex('% 2[0-2][0-9][0-9] %', @@VERSION) + 1, 4)
        ELSE 0
    END
IF Object_Id('dbo.MD5') IS NULL
BEGIN
    IF(@version >= 2016)
    BEGIN
        EXEC('
        CREATE FUNCTION dbo.MD5(@binaryData AS varbinary(max))
        RETURNS varbinary(16) 
        WITH SCHEMABINDING AS
        BEGIN
            RETURN HASHBYTES(''MD5'', @binaryData)
        END
        ');
    END
    ELSE
    BEGIN
        -- since some version of 2017 assemblies must be explicitly whitelisted
        IF(@version >= 2017 AND OBJECT_ID('sys.sp_add_trusted_assembly') IS NOT NULL) 
            IF NOT EXISTS(SELECT [hash] FROM sys.trusted_assemblies WHERE [hash] = 0x57C34E8101BA13D5E5132DCEDCBBFAE8E9DCBA2F679A47766F50E5E723970186593B3C8B55F93378A91D226D7BAC82DD95D4074D841F5DFB92AA53228334E636)
                EXEC sys.sp_add_trusted_assembly @hash = 0x57C34E8101BA13D5E5132DCEDCBBFAE8E9DCBA2F679A47766F50E5E723970186593B3C8B55F93378A91D226D7BAC82DD95D4074D841F5DFB92AA53228334E636, @description = N'Anchor';
        CREATE ASSEMBLY Anchor
        AUTHORIZATION dbo
        -- you can use the DLL instead if you substitute for your path:
        -- FROM 'path_to_Anchor.dll'
        -- or you can use the binary representation of the compiled code:
        FROM 0x4D5A90000300000004000000FFFF0000B800000000000000400000000000000000000000000000000000000000000000000000000000000000000000800000000E1FBA0E00B409CD21B8014CCD21546869732070726F6772616D2063616E6E6F742062652072756E20696E20444F53206D6F64652E0D0D0A2400000000000000504500004C010300E7B633540000000000000000E00002210B010800000600000006000000000000CE2500000020000000400000000040000020000000020000040000000000000004000000000000000080000000020000000000000300408500001000001000000000100000100000000000001000000000000000000000007C2500004F00000000400000A002000000000000000000000000000000000000006000000C00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000080000000000000000000000082000004800000000000000000000002E74657874000000D4050000002000000006000000020000000000000000000000000000200000602E72737263000000A0020000004000000004000000080000000000000000000000000000400000402E72656C6F6300000C0000000060000000020000000C00000000000000000000000000004000004200000000000000000000000000000000B025000000000000480000000200050080200000FC040000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000096026F0400000A2D16280500000A026F0600000A6F0700000A730800000A2A14280900000A2A1E02280A00000A2A000042534A4201000100000000000C00000076322E302E35303732370000000005006C00000048010000237E0000B40100009001000023537472696E6773000000004403000008000000235553004C0300001000000023475549440000005C030000A001000023426C6F620000000000000002000001471500000900000000FA01330016000001000000090000000200000002000000010000000A00000003000000010000000200000000000A0001000000000006002F0028000A00570042000A00610042000600A30083000600C30083000A000301E800060040012301060055014B010600670123010000000001000000000001000100010010001500000005000100010050200000000096006A000A000100762000000000861872001100020000000100780021007200150029007200110031007200110019001801550139004401590119005C015E01490075016301110072006A0111008101700109007200110020001B001A002E000B0077012E0013008001048000000000000000000000000000000000E100000002000000000000000000000001001F000000000002000000000000000000000001003600000000000000003C4D6F64756C653E00416E63686F722E646C6C005574696C6974696573006D73636F726C69620053797374656D004F626A6563740053797374656D2E446174610053797374656D2E446174612E53716C54797065730053716C42696E6172790053716C427974657300486173684D4435002E63746F720062696E617279446174610053797374656D2E52756E74696D652E436F6D70696C6572536572766963657300436F6D70696C6174696F6E52656C61786174696F6E734174747269627574650052756E74696D65436F6D7061746962696C69747941747472696275746500416E63686F72004D6963726F736F66742E53716C5365727665722E5365727665720053716C46756E6374696F6E417474726962757465006765745F49734E756C6C0053797374656D2E53656375726974792E43727970746F677261706879004D4435004372656174650053797374656D2E494F0053747265616D006765745F53747265616D0048617368416C676F726974686D00436F6D7075746548617368006F705F496D706C69636974000000000003200000000000C7641B1E7755B04A8FCCCA2F22950BF30008B77A5C561934E0890600011109120D0320000104200101088139010003005455794D6963726F736F66742E53716C5365727665722E5365727665722E446174614163636573734B696E642C2053797374656D2E446174612C2056657273696F6E3D322E302E302E302C2043756C747572653D6E65757472616C2C205075626C69634B6579546F6B656E3D623737613563353631393334653038390A446174614163636573730000000054020F497344657465726D696E69737469630154557F4D6963726F736F66742E53716C5365727665722E5365727665722E53797374656D446174614163636573734B696E642C2053797374656D2E446174612C2056657273696F6E3D322E302E302E302C2043756C747572653D6E65757472616C2C205075626C69634B6579546F6B656E3D623737613563353631393334653038391053797374656D446174614163636573730000000003200002040000121D04200012210620011D051221052001011D0506000111091D050801000800000000001E01000100540216577261704E6F6E457863657074696F6E5468726F77730100A42500000000000000000000BE250000002000000000000000000000000000000000000000000000B0250000000000000000000000005F436F72446C6C4D61696E006D73636F7265652E646C6C0000000000FF2500204000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100100000001800008000000000000000000000000000000100010000003000008000000000000000000000000000000100000000004800000058400000440200000000000000000000440234000000560053005F00560045005200530049004F004E005F0049004E0046004F0000000000BD04EFFE00000100000000000000000000000000000000003F000000000000000400000002000000000000000000000000000000440000000100560061007200460069006C00650049006E0066006F00000000002400040000005400720061006E0073006C006100740069006F006E00000000000000B004A4010000010053007400720069006E006700460069006C00650049006E0066006F0000008001000001003000300030003000300034006200300000002C0002000100460069006C0065004400650073006300720069007000740069006F006E000000000020000000300008000100460069006C006500560065007200730069006F006E000000000030002E0030002E0030002E003000000038000B00010049006E007400650072006E0061006C004E0061006D006500000041006E00630068006F0072002E0064006C006C00000000002800020001004C006500670061006C0043006F00700079007200690067006800740000002000000040000B0001004F0072006900670069006E0061006C00460069006C0065006E0061006D006500000041006E00630068006F0072002E0064006C006C0000000000340008000100500072006F006400750063007400560065007200730069006F006E00000030002E0030002E0030002E003000000038000800010041007300730065006D0062006C0079002000560065007200730069006F006E00000030002E0030002E0030002E00300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000C000000D03500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
        WITH PERMISSION_SET = SAFE;
        EXEC('
        CREATE FUNCTION dbo.MD5(@binaryData AS varbinary(max))
        RETURNS varbinary(16) AS EXTERNAL NAME Anchor.Utilities.HashMD5
        ');
        EXEC sys.sp_configure 'clr enabled', 1;
        reconfigure with override;
    END 
END
GO
-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are used to store finite sets of values, normally used to describe states
-- of entities (through knotted attributes) or relationships (through knotted ties).
-- Knots have their own surrogate identities and are therefore immutable.
-- Values can be added to the set over time though.
-- Knots should have values that are mutually exclusive and exhaustive.
-- Knots are unfolded when using equivalence.
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PAT_ParentalType table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PAT_ParentalType', 'U') IS NULL
CREATE TABLE [dbo].[PAT_ParentalType] (
    PAT_ID tinyint not null,
    PAT_ParentalType varchar(42) not null,
    Metadata_PAT int not null,
    constraint pkPAT_ParentalType primary key (
        PAT_ID asc
    ),
    constraint uqPAT_ParentalType unique (
        PAT_ParentalType
    )
);
GO
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Gender table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.GEN_Gender', 'U') IS NULL
CREATE TABLE [dbo].[GEN_Gender] (
    GEN_ID bit not null,
    GEN_Gender varchar(42) not null,
    Metadata_GEN int not null,
    constraint pkGEN_Gender primary key (
        GEN_ID asc
    ),
    constraint uqGEN_Gender unique (
        GEN_Gender
    )
);
GO
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PLV_ProfessionalLevel', 'U') IS NULL
CREATE TABLE [dbo].[PLV_ProfessionalLevel] (
    PLV_ID tinyint not null,
    PLV_ProfessionalLevel varchar(max) not null,
    PLV_Checksum as cast(dbo.MD5(cast(PLV_ProfessionalLevel as varbinary(max))) as varbinary(16)) persisted,
    Metadata_PLV int not null,
    constraint pkPLV_ProfessionalLevel primary key (
        PLV_ID asc
    ),
    constraint uqPLV_ProfessionalLevel unique (
        PLV_Checksum 
    )
);
GO
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utilization table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.UTL_Utilization', 'U') IS NULL
CREATE TABLE [dbo].[UTL_Utilization] (
    UTL_ID tinyint not null,
    UTL_Utilization tinyint not null,
    Metadata_UTL int not null,
    constraint pkUTL_Utilization primary key (
        UTL_ID asc
    ),
    constraint uqUTL_Utilization unique (
        UTL_Utilization
    )
);
GO
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ONG_Ongoing table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ONG_Ongoing', 'U') IS NULL
CREATE TABLE [dbo].[ONG_Ongoing] (
    ONG_ID tinyint not null,
    ONG_Ongoing varchar(3) not null,
    Metadata_ONG int not null,
    constraint pkONG_Ongoing primary key (
        ONG_ID asc
    ),
    constraint uqONG_Ongoing unique (
        ONG_Ongoing
    )
);
GO
-- Knot table ---------------------------------------------------------------------------------------------------------
-- RAT_Rating table
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.RAT_Rating', 'U') IS NULL
CREATE TABLE [dbo].[RAT_Rating] (
    RAT_ID tinyint not null,
    RAT_Rating varchar(42) not null,
    Metadata_RAT int not null,
    constraint pkRAT_Rating primary key (
        RAT_ID asc
    ),
    constraint uqRAT_Rating unique (
        RAT_Rating
    )
);
GO
-- ANCHORS AND ATTRIBUTES ---------------------------------------------------------------------------------------------
--
-- Anchors are used to store the identities of entities.
-- Anchors are immutable.
-- Attributes are used to store values for properties of entities.
-- Attributes are mutable, their values may change over one or more types of time.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
-- Anchors may have zero or more adjoined attributes.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PE_Performance table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PE_Performance', 'U') IS NULL
CREATE TABLE [dbo].[PE_Performance] (
    PE_ID int IDENTITY(1,1) not null,
    Metadata_PE int not null, 
    constraint pkPE_Performance primary key (
        PE_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PE_DAT_Performance_Date table (on PE_Performance)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PE_DAT_Performance_Date', 'U') IS NULL
CREATE TABLE [dbo].[PE_DAT_Performance_Date] (
    PE_DAT_PE_ID int not null,
    PE_DAT_Performance_Date datetime not null,
    Metadata_PE_DAT int not null,
    constraint fkPE_DAT_Performance_Date foreign key (
        PE_DAT_PE_ID
    ) references [dbo].[PE_Performance](PE_ID),
    constraint pkPE_DAT_Performance_Date primary key (
        PE_DAT_PE_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PE_AUD_Performance_Audience table (on PE_Performance)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PE_AUD_Performance_Audience', 'U') IS NULL
CREATE TABLE [dbo].[PE_AUD_Performance_Audience] (
    PE_AUD_PE_ID int not null,
    PE_AUD_Performance_Audience int not null,
    Metadata_PE_AUD int not null,
    constraint fkPE_AUD_Performance_Audience foreign key (
        PE_AUD_PE_ID
    ) references [dbo].[PE_Performance](PE_ID),
    constraint pkPE_AUD_Performance_Audience primary key (
        PE_AUD_PE_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PE_REV_Performance_Revenue table (on PE_Performance)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PE_REV_Performance_Revenue', 'U') IS NULL
CREATE TABLE [dbo].[PE_REV_Performance_Revenue] (
    PE_REV_PE_ID int not null,
    PE_REV_Performance_Revenue money not null,
    Metadata_PE_REV int not null,
    constraint fkPE_REV_Performance_Revenue foreign key (
        PE_REV_PE_ID
    ) references [dbo].[PE_Performance](PE_ID),
    constraint pkPE_REV_Performance_Revenue primary key (
        PE_REV_PE_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PN_Person table (with 0 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PN_Person', 'U') IS NULL
CREATE TABLE [dbo].[PN_Person] (
    PN_ID int IDENTITY(1,1) not null,
    Metadata_PN int not null, 
    constraint pkPN_Person primary key (
        PN_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Stage table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_Stage', 'U') IS NULL
CREATE TABLE [dbo].[ST_Stage] (
    ST_ID int IDENTITY(1,1) not null,
    Metadata_ST int not null, 
    constraint pkST_Stage primary key (
        ST_ID asc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_NAM_Stage_Name', 'U') IS NULL
CREATE TABLE [dbo].[ST_NAM_Stage_Name] (
    ST_NAM_ST_ID int not null,
    ST_NAM_Stage_Name varchar(42) not null,
    ST_NAM_ChangedAt datetime not null,
    Metadata_ST_NAM int not null,
    constraint fkST_NAM_Stage_Name foreign key (
        ST_NAM_ST_ID
    ) references [dbo].[ST_Stage](ST_ID),
    constraint pkST_NAM_Stage_Name primary key (
        ST_NAM_ST_ID asc,
        ST_NAM_ChangedAt desc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_LOC_Stage_Location', 'U') IS NULL
CREATE TABLE [dbo].[ST_LOC_Stage_Location] (
    ST_LOC_ST_ID int not null,
    ST_LOC_Stage_Location geography not null,
    ST_LOC_Checksum as cast(dbo.MD5(cast(ST_LOC_Stage_Location as varbinary(max))) as varbinary(16)) persisted,
    Metadata_ST_LOC int not null,
    constraint fkST_LOC_Stage_Location foreign key (
        ST_LOC_ST_ID
    ) references [dbo].[ST_Stage](ST_ID),
    constraint pkST_LOC_Stage_Location primary key (
        ST_LOC_ST_ID asc
    )
);
GO
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- ST_AVG_Stage_Average table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_AVG_Stage_Average', 'U') IS NULL
CREATE TABLE [dbo].[ST_AVG_Stage_Average] (
    ST_AVG_ST_ID int not null,
    ST_AVG_UTL_ID tinyint not null,
    ST_AVG_ChangedAt datetime not null,
    Metadata_ST_AVG int not null,
    constraint fk_A_ST_AVG_Stage_Average foreign key (
        ST_AVG_ST_ID
    ) references [dbo].[ST_Stage](ST_ID),
    constraint fk_K_ST_AVG_Stage_Average foreign key (
        ST_AVG_UTL_ID
    ) references [dbo].[UTL_Utilization](UTL_ID),
    constraint pkST_AVG_Stage_Average primary key (
        ST_AVG_ST_ID asc,
        ST_AVG_ChangedAt desc
    )
);
GO
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_MIN_Stage_Minimum', 'U') IS NULL
CREATE TABLE [dbo].[ST_MIN_Stage_Minimum] (
    ST_MIN_ST_ID int not null,
    ST_MIN_UTL_ID tinyint not null,
    Metadata_ST_MIN int not null,
    constraint fk_A_ST_MIN_Stage_Minimum foreign key (
        ST_MIN_ST_ID
    ) references [dbo].[ST_Stage](ST_ID),
    constraint fk_K_ST_MIN_Stage_Minimum foreign key (
        ST_MIN_UTL_ID
    ) references [dbo].[UTL_Utilization](UTL_ID),
    constraint pkST_MIN_Stage_Minimum primary key (
        ST_MIN_ST_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Actor table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_Actor', 'U') IS NULL
CREATE TABLE [dbo].[AC_Actor] (
    AC_ID int IDENTITY(1,1) not null,
    Metadata_AC int not null, 
    constraint pkAC_Actor primary key (
        AC_ID asc
    )
);
GO
-- Historized attribute table -----------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_NAM_Actor_Name', 'U') IS NULL
CREATE TABLE [dbo].[AC_NAM_Actor_Name] (
    AC_NAM_AC_ID int not null,
    AC_NAM_Actor_Name varchar(42) not null,
    AC_NAM_ChangedAt datetime not null,
    Metadata_AC_NAM int not null,
    constraint fkAC_NAM_Actor_Name foreign key (
        AC_NAM_AC_ID
    ) references [dbo].[AC_Actor](AC_ID),
    constraint pkAC_NAM_Actor_Name primary key (
        AC_NAM_AC_ID asc,
        AC_NAM_ChangedAt desc
    )
);
GO
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_GEN_Actor_Gender', 'U') IS NULL
CREATE TABLE [dbo].[AC_GEN_Actor_Gender] (
    AC_GEN_AC_ID int not null,
    AC_GEN_GEN_ID bit not null,
    Metadata_AC_GEN int not null,
    constraint fk_A_AC_GEN_Actor_Gender foreign key (
        AC_GEN_AC_ID
    ) references [dbo].[AC_Actor](AC_ID),
    constraint fk_K_AC_GEN_Actor_Gender foreign key (
        AC_GEN_GEN_ID
    ) references [dbo].[GEN_Gender](GEN_ID),
    constraint pkAC_GEN_Actor_Gender primary key (
        AC_GEN_AC_ID asc
    )
);
GO
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_PLV_Actor_ProfessionalLevel', 'U') IS NULL
CREATE TABLE [dbo].[AC_PLV_Actor_ProfessionalLevel] (
    AC_PLV_AC_ID int not null,
    AC_PLV_PLV_ID tinyint not null,
    AC_PLV_ChangedAt datetime not null,
    Metadata_AC_PLV int not null,
    constraint fk_A_AC_PLV_Actor_ProfessionalLevel foreign key (
        AC_PLV_AC_ID
    ) references [dbo].[AC_Actor](AC_ID),
    constraint fk_K_AC_PLV_Actor_ProfessionalLevel foreign key (
        AC_PLV_PLV_ID
    ) references [dbo].[PLV_ProfessionalLevel](PLV_ID),
    constraint pkAC_PLV_Actor_ProfessionalLevel primary key (
        AC_PLV_AC_ID asc,
        AC_PLV_ChangedAt desc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Program table (with 1 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_Program', 'U') IS NULL
CREATE TABLE [dbo].[PR_Program] (
    PR_ID int IDENTITY(1,1) not null,
    Metadata_PR int not null, 
    constraint pkPR_Program primary key (
        PR_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_NAM_Program_Name', 'U') IS NULL
CREATE TABLE [dbo].[PR_NAM_Program_Name] (
    PR_NAM_PR_ID int not null,
    PR_NAM_Program_Name varchar(42) not null,
    Metadata_PR_NAM int not null,
    constraint fkPR_NAM_Program_Name foreign key (
        PR_NAM_PR_ID
    ) references [dbo].[PR_Program](PR_ID),
    constraint pkPR_NAM_Program_Name primary key (
        PR_NAM_PR_ID asc
    )
);
GO
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- Ties are used to represent relationships between entities.
-- They come in four flavors: static, historized, knotted static, and knotted historized.
-- Ties have cardinality, constraining how members may participate in the relationship.
-- Every entity that is a member in a tie has a specified role in the relationship.
-- Ties must have at least two anchor roles and zero or more knot roles.
--
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_exclusive_AC_with_ONG_currently table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_exclusive_AC_with_ONG_currently', 'U') IS NULL
CREATE TABLE [dbo].[AC_exclusive_AC_with_ONG_currently] (
    AC_ID_exclusive int not null, 
    AC_ID_with int not null, 
    ONG_ID_currently tinyint not null,
    AC_exclusive_AC_with_ONG_currently_ChangedAt datetime not null,
    Metadata_AC_exclusive_AC_with_ONG_currently int not null,
    constraint AC_exclusive_AC_with_ONG_currently_fkAC_exclusive foreign key (
        AC_ID_exclusive
    ) references [dbo].[AC_Actor](AC_ID), 
    constraint AC_exclusive_AC_with_ONG_currently_fkAC_with foreign key (
        AC_ID_with
    ) references [dbo].[AC_Actor](AC_ID), 
    constraint AC_exclusive_AC_with_ONG_currently_fkONG_currently foreign key (
        ONG_ID_currently
    ) references [dbo].[ONG_Ongoing](ONG_ID),
    constraint AC_exclusive_AC_with_ONG_currently_uqAC_exclusive unique (
        AC_ID_exclusive,
        AC_exclusive_AC_with_ONG_currently_ChangedAt
    ),
    constraint AC_exclusive_AC_with_ONG_currently_uqAC_with unique (
        AC_ID_with,
        AC_exclusive_AC_with_ONG_currently_ChangedAt
    ),
    constraint pkAC_exclusive_AC_with_ONG_currently primary key (
        AC_ID_exclusive asc,
        AC_ID_with asc,
        ONG_ID_currently asc,
        AC_exclusive_AC_with_ONG_currently_ChangedAt desc
    )
);
GO
-- Static tie table ---------------------------------------------------------------------------------------------------
-- PE_wasHeld_ST_at table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PE_wasHeld_ST_at', 'U') IS NULL
CREATE TABLE [dbo].[PE_wasHeld_ST_at] (
    PE_ID_wasHeld int not null, 
    ST_ID_at int not null, 
    Metadata_PE_wasHeld_ST_at int not null,
    constraint PE_wasHeld_ST_at_fkPE_wasHeld foreign key (
        PE_ID_wasHeld
    ) references [dbo].[PE_Performance](PE_ID), 
    constraint PE_wasHeld_ST_at_fkST_at foreign key (
        ST_ID_at
    ) references [dbo].[ST_Stage](ST_ID), 
    constraint pkPE_wasHeld_ST_at primary key (
        PE_ID_wasHeld asc
    )
);
GO
-- Static tie table ---------------------------------------------------------------------------------------------------
-- AC_subset_PN_of table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_subset_PN_of', 'U') IS NULL
CREATE TABLE [dbo].[AC_subset_PN_of] (
    AC_ID_subset int not null, 
    PN_ID_of int not null, 
    Metadata_AC_subset_PN_of int not null,
    constraint AC_subset_PN_of_fkAC_subset foreign key (
        AC_ID_subset
    ) references [dbo].[AC_Actor](AC_ID), 
    constraint AC_subset_PN_of_fkPN_of foreign key (
        PN_ID_of
    ) references [dbo].[PN_Person](PN_ID), 
    constraint AC_subset_PN_of_uqAC_subset unique (
        AC_ID_subset
    ),
    constraint AC_subset_PN_of_uqPN_of unique (
        PN_ID_of
    ),
    constraint pkAC_subset_PN_of primary key (
        AC_ID_subset asc,
        PN_ID_of asc
    )
);
GO
-- Static tie table ---------------------------------------------------------------------------------------------------
-- PE_at_PR_wasPlayed table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PE_at_PR_wasPlayed', 'U') IS NULL
CREATE TABLE [dbo].[PE_at_PR_wasPlayed] (
    PE_ID_at int not null, 
    PR_ID_wasPlayed int not null, 
    Metadata_PE_at_PR_wasPlayed int not null,
    constraint PE_at_PR_wasPlayed_fkPE_at foreign key (
        PE_ID_at
    ) references [dbo].[PE_Performance](PE_ID), 
    constraint PE_at_PR_wasPlayed_fkPR_wasPlayed foreign key (
        PR_ID_wasPlayed
    ) references [dbo].[PR_Program](PR_ID), 
    constraint pkPE_at_PR_wasPlayed primary key (
        PE_ID_at asc
    )
);
GO
-- Static tie table ---------------------------------------------------------------------------------------------------
-- PE_in_AC_wasCast table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PE_in_AC_wasCast', 'U') IS NULL
CREATE TABLE [dbo].[PE_in_AC_wasCast] (
    PE_ID_in int not null, 
    AC_ID_wasCast int not null, 
    Metadata_PE_in_AC_wasCast int not null,
    constraint PE_in_AC_wasCast_fkPE_in foreign key (
        PE_ID_in
    ) references [dbo].[PE_Performance](PE_ID), 
    constraint PE_in_AC_wasCast_fkAC_wasCast foreign key (
        AC_ID_wasCast
    ) references [dbo].[AC_Actor](AC_ID), 
    constraint pkPE_in_AC_wasCast primary key (
        PE_ID_in asc,
        AC_ID_wasCast asc
    )
);
GO
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_part_PR_in_RAT_got', 'U') IS NULL
CREATE TABLE [dbo].[AC_part_PR_in_RAT_got] (
    AC_ID_part int not null, 
    PR_ID_in int not null, 
    RAT_ID_got tinyint not null,
    AC_part_PR_in_RAT_got_ChangedAt datetime not null,
    Metadata_AC_part_PR_in_RAT_got int not null,
    constraint AC_part_PR_in_RAT_got_fkAC_part foreign key (
        AC_ID_part
    ) references [dbo].[AC_Actor](AC_ID), 
    constraint AC_part_PR_in_RAT_got_fkPR_in foreign key (
        PR_ID_in
    ) references [dbo].[PR_Program](PR_ID), 
    constraint AC_part_PR_in_RAT_got_fkRAT_got foreign key (
        RAT_ID_got
    ) references [dbo].[RAT_Rating](RAT_ID),
    constraint pkAC_part_PR_in_RAT_got primary key (
        AC_ID_part asc,
        PR_ID_in asc,
        AC_part_PR_in_RAT_got_ChangedAt desc
    )
);
GO
-- Historized tie table -----------------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.ST_at_PR_isPlaying', 'U') IS NULL
CREATE TABLE [dbo].[ST_at_PR_isPlaying] (
    ST_ID_at int not null, 
    PR_ID_isPlaying int not null, 
    ST_at_PR_isPlaying_ChangedAt datetime not null,
    Metadata_ST_at_PR_isPlaying int not null,
    constraint ST_at_PR_isPlaying_fkST_at foreign key (
        ST_ID_at
    ) references [dbo].[ST_Stage](ST_ID), 
    constraint ST_at_PR_isPlaying_fkPR_isPlaying foreign key (
        PR_ID_isPlaying
    ) references [dbo].[PR_Program](PR_ID), 
    constraint pkST_at_PR_isPlaying primary key (
        ST_ID_at asc,
        PR_ID_isPlaying asc,
        ST_at_PR_isPlaying_ChangedAt desc
    )
);
GO
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.AC_parent_AC_child_PAT_having', 'U') IS NULL
CREATE TABLE [dbo].[AC_parent_AC_child_PAT_having] (
    AC_ID_parent int not null, 
    AC_ID_child int not null, 
    PAT_ID_having tinyint not null,
    Metadata_AC_parent_AC_child_PAT_having int not null,
    constraint AC_parent_AC_child_PAT_having_fkAC_parent foreign key (
        AC_ID_parent
    ) references [dbo].[AC_Actor](AC_ID), 
    constraint AC_parent_AC_child_PAT_having_fkAC_child foreign key (
        AC_ID_child
    ) references [dbo].[AC_Actor](AC_ID), 
    constraint AC_parent_AC_child_PAT_having_fkPAT_having foreign key (
        PAT_ID_having
    ) references [dbo].[PAT_ParentalType](PAT_ID),
    constraint pkAC_parent_AC_child_PAT_having primary key (
        AC_ID_parent asc,
        AC_ID_child asc,
        PAT_ID_having asc
    )
);
GO
-- Static tie table ---------------------------------------------------------------------------------------------------
-- PR_content_ST_location_PE_of table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.PR_content_ST_location_PE_of', 'U') IS NULL
CREATE TABLE [dbo].[PR_content_ST_location_PE_of] (
    PR_ID_content int not null, 
    ST_ID_location int not null, 
    PE_ID_of int not null, 
    Metadata_PR_content_ST_location_PE_of int not null,
    constraint PR_content_ST_location_PE_of_fkPR_content foreign key (
        PR_ID_content
    ) references [dbo].[PR_Program](PR_ID), 
    constraint PR_content_ST_location_PE_of_fkST_location foreign key (
        ST_ID_location
    ) references [dbo].[ST_Stage](ST_ID), 
    constraint PR_content_ST_location_PE_of_fkPE_of foreign key (
        PE_ID_of
    ) references [dbo].[PE_Performance](PE_ID), 
    constraint pkPR_content_ST_location_PE_of primary key (
        PE_ID_of asc
    )
);
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key view for lookups of identities in PE_Performance
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_PE_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[key_PE_1st];
GO
CREATE VIEW [dbo].[key_PE_1st] WITH SCHEMABINDING AS
SELECT
    twine.PE_DAT_Performance_Date,
    twine.at_ST_LOC_Stage_Location,
    twine.wasPlayed_PR_NAM_Program_Name,
    [PE].PE_ID
FROM
    [dbo].[PE_Performance] [PE]
LEFT JOIN (
    SELECT TOP 1 WITH TIES
        CAST(
            MAX(CASE
                WHEN [QualifiedType] = 'PE_DAT_Performance_Date'
                THEN [Value] END
            ) OVER (
                PARTITION BY 
                    PE_ID, 
                    PE_DAT_Performance_Date_ChangedAt
            ) AS datetime
        ) AS PE_DAT_Performance_Date,
        CAST(
            MAX(CASE
                WHEN [QualifiedType] = 'at_ST_LOC_Stage_Location'
                THEN [Value] END
            ) OVER (
                PARTITION BY 
                    PE_ID, 
                    at_ST_LOC_Stage_Location_ChangedAt
            ) AS geography
        ) AS at_ST_LOC_Stage_Location,
        CAST(
            MAX(CASE
                WHEN [QualifiedType] = 'wasPlayed_PR_NAM_Program_Name'
                THEN [Value] END
            ) OVER (
                PARTITION BY 
                    PE_ID, 
                    wasPlayed_PR_NAM_Program_Name_ChangedAt
            ) AS varchar(42)
        ) AS wasPlayed_PR_NAM_Program_Name,
        PE_ID,
        [ChangedAt]
    FROM (
        SELECT
            MAX(CASE
                WHEN [QualifiedType] = 'PE_DAT_Performance_Date' 
                 AND [Value] is not null
                THEN [ChangedAt] END
            ) OVER (
                PARTITION BY PE_ID 
                ORDER BY [ChangedAt]
            ) AS PE_DAT_Performance_Date_ChangedAt,
            MAX(CASE
                WHEN [QualifiedType] = 'at_ST_LOC_Stage_Location' 
                 AND [Value] is not null
                THEN [ChangedAt] END
            ) OVER (
                PARTITION BY PE_ID 
                ORDER BY [ChangedAt]
            ) AS at_ST_LOC_Stage_Location_ChangedAt,
            MAX(CASE
                WHEN [QualifiedType] = 'wasPlayed_PR_NAM_Program_Name' 
                 AND [Value] is not null
                THEN [ChangedAt] END
            ) OVER (
                PARTITION BY PE_ID 
                ORDER BY [ChangedAt]
            ) AS wasPlayed_PR_NAM_Program_Name_ChangedAt,
            PE_ID,
            [Value],
            [QualifiedType],
            [ChangedAt]
        FROM (
            SELECT
                PE_DAT_PE_ID AS PE_ID, 
                CAST(PE_DAT_Performance_Date AS VARBINARY(max)) AS [Value],
                'PE_DAT_Performance_Date' AS [QualifiedType],
                CAST(NULL AS datetime2(7)) AS [ChangedAt]
            FROM
                [dbo].[PE_DAT_Performance_Date] 
            UNION ALL
            SELECT
                PE_ID_wasHeld AS PE_ID, 
                CAST(ST_LOC_Stage_Location AS VARBINARY(max)) AS [Value],
                'at_ST_LOC_Stage_Location' AS [QualifiedType],
                CAST(NULL AS datetime2(7)) AS [ChangedAt]
            FROM
                [dbo].[PE_wasHeld_ST_at] [S2S3] 
            JOIN 
                [dbo].[ST_Stage] [ST] 
            ON
                [ST].ST_ID = [S2S3].ST_ID_at
            JOIN
                [dbo].[ST_LOC_Stage_Location] [LOC] 
            ON
                [LOC].ST_LOC_ST_ID = [ST].ST_ID
            UNION ALL
            SELECT
                PE_ID_at AS PE_ID, 
                CAST(PR_NAM_Program_Name AS VARBINARY(max)) AS [Value],
                'wasPlayed_PR_NAM_Program_Name' AS [QualifiedType],
                CAST(NULL AS datetime2(7)) AS [ChangedAt]
            FROM
                [dbo].[PE_at_PR_wasPlayed] [S5S6] 
            JOIN 
                [dbo].[PR_Program] [PR] 
            ON
                [PR].PR_ID = [S5S6].PR_ID_wasPlayed
            JOIN
                [dbo].[PR_NAM_Program_Name] [NAM] 
            ON
                [NAM].PR_NAM_PR_ID = [PR].PR_ID
        ) unified_timelines
    ) resolved_changes
    ORDER BY 
        ROW_NUMBER() OVER (
            PARTITION BY 
                PE_ID, 
                [ChangedAt] 
            ORDER BY
                (select 1)
        )
) twine
ON
    twine.PE_ID = [PE].PE_ID;
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key view for lookups of identities in ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_ST_2nd', 'V') IS NOT NULL
DROP VIEW [dbo].[key_ST_2nd];
GO
CREATE VIEW [dbo].[key_ST_2nd] WITH SCHEMABINDING AS
SELECT
    twine.ST_NAM_Stage_Name,
    twine.ST_NAM_ChangedAt AS [ChangedAt],
    [ST].ST_ID
FROM
    [dbo].[ST_Stage] [ST]
LEFT JOIN 
    [dbo].[ST_NAM_Stage_Name] twine
ON
    twine.ST_NAM_ST_ID = [ST].ST_ID;
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key view for lookups of identities in ST_Stage
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_ST_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[key_ST_1st];
GO
CREATE VIEW [dbo].[key_ST_1st] WITH SCHEMABINDING AS
SELECT
    twine.ST_LOC_Stage_Location,
    [ST].ST_ID
FROM
    [dbo].[ST_Stage] [ST]
LEFT JOIN 
    [dbo].[ST_LOC_Stage_Location] twine
ON
    twine.ST_LOC_ST_ID = [ST].ST_ID;
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key view for lookups of identities in AC_Actor
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_AC_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[key_AC_1st];
GO
CREATE VIEW [dbo].[key_AC_1st] WITH SCHEMABINDING AS
SELECT
    twine.AC_NAM_Actor_Name,
    twine.AC_NAM_ChangedAt AS [ChangedAt],
    [AC].AC_ID
FROM
    [dbo].[AC_Actor] [AC]
LEFT JOIN 
    [dbo].[AC_NAM_Actor_Name] twine
ON
    twine.AC_NAM_AC_ID = [AC].AC_ID;
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key view for lookups of identities in PR_Program
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.key_PR_1st', 'V') IS NOT NULL
DROP VIEW [dbo].[key_PR_1st];
GO
CREATE VIEW [dbo].[key_PR_1st] WITH SCHEMABINDING AS
SELECT
    twine.PR_NAM_Program_Name,
    [PR].PR_ID
FROM
    [dbo].[PR_Program] [PR]
LEFT JOIN 
    [dbo].[PR_NAM_Program_Name] twine
ON
    twine.PR_NAM_PR_ID = [PR].PR_ID;
GO
-- KNOT EQUIVALENCE VIEWS ---------------------------------------------------------------------------------------------
--
-- Equivalence views combine the identity and equivalent parts of a knot into a single view, making
-- it look and behave like a regular knot. They also make it possible to retrieve data for only the
-- given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
-- ATTRIBUTE EQUIVALENCE VIEWS ----------------------------------------------------------------------------------------
--
-- Equivalence views of attributes make it possible to retrieve data for only the given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
-- KEY GENERATORS -----------------------------------------------------------------------------------------------------
--
-- These stored procedures can be used to generate identities of entities.
-- Corresponding anchors must have an incrementing identity column.
--
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kPE_Performance identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kPE_Performance', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kPE_Performance] (
        @requestedNumberOfIdentities bigint,
        @metadata int
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT
                    1
                UNION ALL
                SELECT
                    idNumber + 1
                FROM
                    idGenerator
                WHERE
                    idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [dbo].[PE_Performance] (
                Metadata_PE
            )
            OUTPUT
                inserted.PE_ID
            SELECT
                @metadata
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kPN_Person identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kPN_Person', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kPN_Person] (
        @requestedNumberOfIdentities bigint,
        @metadata int
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT
                    1
                UNION ALL
                SELECT
                    idNumber + 1
                FROM
                    idGenerator
                WHERE
                    idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [dbo].[PN_Person] (
                Metadata_PN
            )
            OUTPUT
                inserted.PN_ID
            SELECT
                @metadata
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kST_Stage identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kST_Stage', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kST_Stage] (
        @requestedNumberOfIdentities bigint,
        @metadata int
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT
                    1
                UNION ALL
                SELECT
                    idNumber + 1
                FROM
                    idGenerator
                WHERE
                    idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [dbo].[ST_Stage] (
                Metadata_ST
            )
            OUTPUT
                inserted.ST_ID
            SELECT
                @metadata
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kAC_Actor identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kAC_Actor', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kAC_Actor] (
        @requestedNumberOfIdentities bigint,
        @metadata int
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT
                    1
                UNION ALL
                SELECT
                    idNumber + 1
                FROM
                    idGenerator
                WHERE
                    idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [dbo].[AC_Actor] (
                Metadata_AC
            )
            OUTPUT
                inserted.AC_ID
            SELECT
                @metadata
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kPR_Program identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.kPR_Program', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[kPR_Program] (
        @requestedNumberOfIdentities bigint,
        @metadata int
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT
                    1
                UNION ALL
                SELECT
                    idNumber + 1
                FROM
                    idGenerator
                WHERE
                    idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [dbo].[PR_Program] (
                Metadata_PR
            )
            OUTPUT
                inserted.PR_ID
            SELECT
                @metadata
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- ATTRIBUTE REWINDERS ------------------------------------------------------------------------------------------------
--
-- These table valued functions rewind an attribute table to the given
-- point in changing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time.
--
-- @changingTimepoint the point in changing time to rewind to
--
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_NAM_Stage_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_NAM_Stage_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_NAM_Stage_Name] (
        @changingTimepoint datetime
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_ST_NAM,
        ST_NAM_ST_ID,
        ST_NAM_Stage_Name,
        ST_NAM_ChangedAt
    FROM
        [dbo].[ST_NAM_Stage_Name]
    WHERE
        ST_NAM_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_AVG_Stage_Average','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_AVG_Stage_Average] (
        @changingTimepoint datetime
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_ST_AVG,
        ST_AVG_ST_ID,
        ST_AVG_UTL_ID,
        ST_AVG_ChangedAt
    FROM
        [dbo].[ST_AVG_Stage_Average]
    WHERE
        ST_AVG_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_NAM_Actor_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_NAM_Actor_Name] (
        @changingTimepoint datetime
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_AC_NAM,
        AC_NAM_AC_ID,
        AC_NAM_Actor_Name,
        AC_NAM_ChangedAt
    FROM
        [dbo].[AC_NAM_Actor_Name]
    WHERE
        AC_NAM_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_PLV_Actor_ProfessionalLevel','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_PLV_Actor_ProfessionalLevel] (
        @changingTimepoint datetime
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_AC_PLV,
        AC_PLV_AC_ID,
        AC_PLV_PLV_ID,
        AC_PLV_ChangedAt
    FROM
        [dbo].[AC_PLV_Actor_ProfessionalLevel]
    WHERE
        AC_PLV_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each anchor. There are four types of perspectives: latest,
-- point-in-time, difference, and now. They also denormalize the anchor, its attributes,
-- and referenced knots from sixth to third normal form.
--
-- The latest perspective shows the latest available information for each anchor.
-- The now perspective shows the information as it is right now.
-- The point-in-time perspective lets you travel through the information to the given timepoint.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints, and for
-- changes in all or a selection of attributes.
--
-- @intervalStart the start of the interval for finding changes
-- @intervalEnd the end of the interval for finding changes
-- @selection a list of mnemonics for tracked attributes, ie 'MNE MON ICS', or null for all
--
-- Under equivalence all these views default to equivalent = 0, however, corresponding
-- prepended-e perspectives are provided in order to select a specific equivalent.
--
-- @equivalent the equivalent for which to retrieve data
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dPE_Performance', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dPE_Performance];
IF Object_ID('dbo.nPE_Performance', 'V') IS NOT NULL
DROP VIEW [dbo].[nPE_Performance];
IF Object_ID('dbo.pPE_Performance', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pPE_Performance];
IF Object_ID('dbo.lPE_Performance', 'V') IS NOT NULL
DROP VIEW [dbo].[lPE_Performance];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lPE_Performance viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lPE_Performance] WITH SCHEMABINDING AS
SELECT
    [PE].PE_ID,
    [PE].Metadata_PE,
    [DAT].PE_DAT_PE_ID,
    [DAT].Metadata_PE_DAT,
    [DAT].PE_DAT_Performance_Date,
    [AUD].PE_AUD_PE_ID,
    [AUD].Metadata_PE_AUD,
    [AUD].PE_AUD_Performance_Audience,
    [REV].PE_REV_PE_ID,
    [REV].Metadata_PE_REV,
    [REV].PE_REV_Performance_Revenue
FROM
    [dbo].[PE_Performance] [PE]
LEFT JOIN
    [dbo].[PE_DAT_Performance_Date] [DAT]
ON
    [DAT].PE_DAT_PE_ID = [PE].PE_ID
LEFT JOIN
    [dbo].[PE_AUD_Performance_Audience] [AUD]
ON
    [AUD].PE_AUD_PE_ID = [PE].PE_ID
LEFT JOIN
    [dbo].[PE_REV_Performance_Revenue] [REV]
ON
    [REV].PE_REV_PE_ID = [PE].PE_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pPE_Performance viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pPE_Performance] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [PE].PE_ID,
    [PE].Metadata_PE,
    [DAT].PE_DAT_PE_ID,
    [DAT].Metadata_PE_DAT,
    [DAT].PE_DAT_Performance_Date,
    [AUD].PE_AUD_PE_ID,
    [AUD].Metadata_PE_AUD,
    [AUD].PE_AUD_Performance_Audience,
    [REV].PE_REV_PE_ID,
    [REV].Metadata_PE_REV,
    [REV].PE_REV_Performance_Revenue
FROM
    [dbo].[PE_Performance] [PE]
LEFT JOIN
    [dbo].[PE_DAT_Performance_Date] [DAT]
ON
    [DAT].PE_DAT_PE_ID = [PE].PE_ID
LEFT JOIN
    [dbo].[PE_AUD_Performance_Audience] [AUD]
ON
    [AUD].PE_AUD_PE_ID = [PE].PE_ID
LEFT JOIN
    [dbo].[PE_REV_Performance_Revenue] [REV]
ON
    [REV].PE_REV_PE_ID = [PE].PE_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nPE_Performance viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nPE_Performance]
AS
SELECT
    *
FROM
    [dbo].[pPE_Performance](sysdatetime());
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dST_Stage];
IF Object_ID('dbo.nST_Stage', 'V') IS NOT NULL
DROP VIEW [dbo].[nST_Stage];
IF Object_ID('dbo.pST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pST_Stage];
IF Object_ID('dbo.lST_Stage', 'V') IS NOT NULL
DROP VIEW [dbo].[lST_Stage];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lST_Stage viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lST_Stage] WITH SCHEMABINDING AS
SELECT
    [ST].ST_ID,
    [ST].Metadata_ST,
    [NAM].ST_NAM_ST_ID,
    [NAM].Metadata_ST_NAM,
    [NAM].ST_NAM_ChangedAt,
    [NAM].ST_NAM_Stage_Name,
    [LOC].ST_LOC_ST_ID,
    [LOC].Metadata_ST_LOC,
    [LOC].ST_LOC_Checksum,
    [LOC].ST_LOC_Stage_Location,
    [AVG].ST_AVG_ST_ID,
    [AVG].Metadata_ST_AVG,
    [AVG].ST_AVG_ChangedAt,
    [kAVG].UTL_Utilization AS ST_AVG_UTL_Utilization,
    [kAVG].Metadata_UTL AS ST_AVG_Metadata_UTL,
    [AVG].ST_AVG_UTL_ID,
    [MIN].ST_MIN_ST_ID,
    [MIN].Metadata_ST_MIN,
    [kMIN].UTL_Utilization AS ST_MIN_UTL_Utilization,
    [kMIN].Metadata_UTL AS ST_MIN_Metadata_UTL,
    [MIN].ST_MIN_UTL_ID
FROM
    [dbo].[ST_Stage] [ST]
LEFT JOIN
    [dbo].[ST_NAM_Stage_Name] [NAM]
ON
    [NAM].ST_NAM_ST_ID = [ST].ST_ID
AND
    [NAM].ST_NAM_ChangedAt = (
        SELECT
            max(sub.ST_NAM_ChangedAt)
        FROM
            [dbo].[ST_NAM_Stage_Name] sub
        WHERE
            sub.ST_NAM_ST_ID = [ST].ST_ID
   )
LEFT JOIN
    [dbo].[ST_LOC_Stage_Location] [LOC]
ON
    [LOC].ST_LOC_ST_ID = [ST].ST_ID
LEFT JOIN
    [dbo].[ST_AVG_Stage_Average] [AVG]
ON
    [AVG].ST_AVG_ST_ID = [ST].ST_ID
AND
    [AVG].ST_AVG_ChangedAt = (
        SELECT
            max(sub.ST_AVG_ChangedAt)
        FROM
            [dbo].[ST_AVG_Stage_Average] sub
        WHERE
            sub.ST_AVG_ST_ID = [ST].ST_ID
   )
LEFT JOIN
    [dbo].[UTL_Utilization] [kAVG]
ON
    [kAVG].UTL_ID = [AVG].ST_AVG_UTL_ID
LEFT JOIN
    [dbo].[ST_MIN_Stage_Minimum] [MIN]
ON
    [MIN].ST_MIN_ST_ID = [ST].ST_ID
LEFT JOIN
    [dbo].[UTL_Utilization] [kMIN]
ON
    [kMIN].UTL_ID = [MIN].ST_MIN_UTL_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pST_Stage viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pST_Stage] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [ST].ST_ID,
    [ST].Metadata_ST,
    [NAM].ST_NAM_ST_ID,
    [NAM].Metadata_ST_NAM,
    [NAM].ST_NAM_ChangedAt,
    [NAM].ST_NAM_Stage_Name,
    [LOC].ST_LOC_ST_ID,
    [LOC].Metadata_ST_LOC,
    [LOC].ST_LOC_Checksum,
    [LOC].ST_LOC_Stage_Location,
    [AVG].ST_AVG_ST_ID,
    [AVG].Metadata_ST_AVG,
    [AVG].ST_AVG_ChangedAt,
    [kAVG].UTL_Utilization AS ST_AVG_UTL_Utilization,
    [kAVG].Metadata_UTL AS ST_AVG_Metadata_UTL,
    [AVG].ST_AVG_UTL_ID,
    [MIN].ST_MIN_ST_ID,
    [MIN].Metadata_ST_MIN,
    [kMIN].UTL_Utilization AS ST_MIN_UTL_Utilization,
    [kMIN].Metadata_UTL AS ST_MIN_Metadata_UTL,
    [MIN].ST_MIN_UTL_ID
FROM
    [dbo].[ST_Stage] [ST]
LEFT JOIN
    [dbo].[rST_NAM_Stage_Name](@changingTimepoint) [NAM]
ON
    [NAM].ST_NAM_ST_ID = [ST].ST_ID
AND
    [NAM].ST_NAM_ChangedAt = (
        SELECT
            max(sub.ST_NAM_ChangedAt)
        FROM
            [dbo].[rST_NAM_Stage_Name](@changingTimepoint) sub
        WHERE
            sub.ST_NAM_ST_ID = [ST].ST_ID
   )
LEFT JOIN
    [dbo].[ST_LOC_Stage_Location] [LOC]
ON
    [LOC].ST_LOC_ST_ID = [ST].ST_ID
LEFT JOIN
    [dbo].[rST_AVG_Stage_Average](@changingTimepoint) [AVG]
ON
    [AVG].ST_AVG_ST_ID = [ST].ST_ID
AND
    [AVG].ST_AVG_ChangedAt = (
        SELECT
            max(sub.ST_AVG_ChangedAt)
        FROM
            [dbo].[rST_AVG_Stage_Average](@changingTimepoint) sub
        WHERE
            sub.ST_AVG_ST_ID = [ST].ST_ID
   )
LEFT JOIN
    [dbo].[UTL_Utilization] [kAVG]
ON
    [kAVG].UTL_ID = [AVG].ST_AVG_UTL_ID
LEFT JOIN
    [dbo].[ST_MIN_Stage_Minimum] [MIN]
ON
    [MIN].ST_MIN_ST_ID = [ST].ST_ID
LEFT JOIN
    [dbo].[UTL_Utilization] [kMIN]
ON
    [kMIN].UTL_ID = [MIN].ST_MIN_UTL_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nST_Stage viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nST_Stage]
AS
SELECT
    *
FROM
    [dbo].[pST_Stage](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dST_Stage showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dST_Stage] (
    @intervalStart datetime2(7),
    @intervalEnd datetime2(7),
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    [pST].*
FROM (
    SELECT DISTINCT
        ST_NAM_ST_ID AS ST_ID,
        ST_NAM_ChangedAt AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        [dbo].[ST_NAM_Stage_Name]
    WHERE
        (@selection is null OR @selection like '%NAM%')
    AND
        ST_NAM_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        ST_AVG_ST_ID AS ST_ID,
        ST_AVG_ChangedAt AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        [dbo].[ST_AVG_Stage_Average]
    WHERE
        (@selection is null OR @selection like '%AVG%')
    AND
        ST_AVG_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [dbo].[pST_Stage](timepoints.inspectedTimepoint) [pST]
WHERE
    [pST].ST_ID = timepoints.ST_ID;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dAC_Actor];
IF Object_ID('dbo.nAC_Actor', 'V') IS NOT NULL
DROP VIEW [dbo].[nAC_Actor];
IF Object_ID('dbo.pAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pAC_Actor];
IF Object_ID('dbo.lAC_Actor', 'V') IS NOT NULL
DROP VIEW [dbo].[lAC_Actor];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_Actor viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lAC_Actor] WITH SCHEMABINDING AS
SELECT
    [AC].AC_ID,
    [AC].Metadata_AC,
    [NAM].AC_NAM_AC_ID,
    [NAM].Metadata_AC_NAM,
    [NAM].AC_NAM_ChangedAt,
    [NAM].AC_NAM_Actor_Name,
    [GEN].AC_GEN_AC_ID,
    [GEN].Metadata_AC_GEN,
    [kGEN].GEN_Gender AS AC_GEN_GEN_Gender,
    [kGEN].Metadata_GEN AS AC_GEN_Metadata_GEN,
    [GEN].AC_GEN_GEN_ID,
    [PLV].AC_PLV_AC_ID,
    [PLV].Metadata_AC_PLV,
    [PLV].AC_PLV_ChangedAt,
    [kPLV].PLV_Checksum AS AC_PLV_PLV_Checksum,
    [kPLV].PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
    [kPLV].Metadata_PLV AS AC_PLV_Metadata_PLV,
    [PLV].AC_PLV_PLV_ID
FROM
    [dbo].[AC_Actor] [AC]
LEFT JOIN
    [dbo].[AC_NAM_Actor_Name] [NAM]
ON
    [NAM].AC_NAM_AC_ID = [AC].AC_ID
AND
    [NAM].AC_NAM_ChangedAt = (
        SELECT
            max(sub.AC_NAM_ChangedAt)
        FROM
            [dbo].[AC_NAM_Actor_Name] sub
        WHERE
            sub.AC_NAM_AC_ID = [AC].AC_ID
   )
LEFT JOIN
    [dbo].[AC_GEN_Actor_Gender] [GEN]
ON
    [GEN].AC_GEN_AC_ID = [AC].AC_ID
LEFT JOIN
    [dbo].[GEN_Gender] [kGEN]
ON
    [kGEN].GEN_ID = [GEN].AC_GEN_GEN_ID
LEFT JOIN
    [dbo].[AC_PLV_Actor_ProfessionalLevel] [PLV]
ON
    [PLV].AC_PLV_AC_ID = [AC].AC_ID
AND
    [PLV].AC_PLV_ChangedAt = (
        SELECT
            max(sub.AC_PLV_ChangedAt)
        FROM
            [dbo].[AC_PLV_Actor_ProfessionalLevel] sub
        WHERE
            sub.AC_PLV_AC_ID = [AC].AC_ID
   )
LEFT JOIN
    [dbo].[PLV_ProfessionalLevel] [kPLV]
ON
    [kPLV].PLV_ID = [PLV].AC_PLV_PLV_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_Actor viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pAC_Actor] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [AC].AC_ID,
    [AC].Metadata_AC,
    [NAM].AC_NAM_AC_ID,
    [NAM].Metadata_AC_NAM,
    [NAM].AC_NAM_ChangedAt,
    [NAM].AC_NAM_Actor_Name,
    [GEN].AC_GEN_AC_ID,
    [GEN].Metadata_AC_GEN,
    [kGEN].GEN_Gender AS AC_GEN_GEN_Gender,
    [kGEN].Metadata_GEN AS AC_GEN_Metadata_GEN,
    [GEN].AC_GEN_GEN_ID,
    [PLV].AC_PLV_AC_ID,
    [PLV].Metadata_AC_PLV,
    [PLV].AC_PLV_ChangedAt,
    [kPLV].PLV_Checksum AS AC_PLV_PLV_Checksum,
    [kPLV].PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
    [kPLV].Metadata_PLV AS AC_PLV_Metadata_PLV,
    [PLV].AC_PLV_PLV_ID
FROM
    [dbo].[AC_Actor] [AC]
LEFT JOIN
    [dbo].[rAC_NAM_Actor_Name](@changingTimepoint) [NAM]
ON
    [NAM].AC_NAM_AC_ID = [AC].AC_ID
AND
    [NAM].AC_NAM_ChangedAt = (
        SELECT
            max(sub.AC_NAM_ChangedAt)
        FROM
            [dbo].[rAC_NAM_Actor_Name](@changingTimepoint) sub
        WHERE
            sub.AC_NAM_AC_ID = [AC].AC_ID
   )
LEFT JOIN
    [dbo].[AC_GEN_Actor_Gender] [GEN]
ON
    [GEN].AC_GEN_AC_ID = [AC].AC_ID
LEFT JOIN
    [dbo].[GEN_Gender] [kGEN]
ON
    [kGEN].GEN_ID = [GEN].AC_GEN_GEN_ID
LEFT JOIN
    [dbo].[rAC_PLV_Actor_ProfessionalLevel](@changingTimepoint) [PLV]
ON
    [PLV].AC_PLV_AC_ID = [AC].AC_ID
AND
    [PLV].AC_PLV_ChangedAt = (
        SELECT
            max(sub.AC_PLV_ChangedAt)
        FROM
            [dbo].[rAC_PLV_Actor_ProfessionalLevel](@changingTimepoint) sub
        WHERE
            sub.AC_PLV_AC_ID = [AC].AC_ID
   )
LEFT JOIN
    [dbo].[PLV_ProfessionalLevel] [kPLV]
ON
    [kPLV].PLV_ID = [PLV].AC_PLV_PLV_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_Actor viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nAC_Actor]
AS
SELECT
    *
FROM
    [dbo].[pAC_Actor](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dAC_Actor showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dAC_Actor] (
    @intervalStart datetime2(7),
    @intervalEnd datetime2(7),
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    [pAC].*
FROM (
    SELECT DISTINCT
        AC_NAM_AC_ID AS AC_ID,
        AC_NAM_ChangedAt AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        [dbo].[AC_NAM_Actor_Name]
    WHERE
        (@selection is null OR @selection like '%NAM%')
    AND
        AC_NAM_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        AC_PLV_AC_ID AS AC_ID,
        AC_PLV_ChangedAt AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        [dbo].[AC_PLV_Actor_ProfessionalLevel]
    WHERE
        (@selection is null OR @selection like '%PLV%')
    AND
        AC_PLV_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [dbo].[pAC_Actor](timepoints.inspectedTimepoint) [pAC]
WHERE
    [pAC].AC_ID = timepoints.AC_ID;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dPR_Program];
IF Object_ID('dbo.nPR_Program', 'V') IS NOT NULL
DROP VIEW [dbo].[nPR_Program];
IF Object_ID('dbo.pPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pPR_Program];
IF Object_ID('dbo.lPR_Program', 'V') IS NOT NULL
DROP VIEW [dbo].[lPR_Program];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lPR_Program viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lPR_Program] WITH SCHEMABINDING AS
SELECT
    [PR].PR_ID,
    [PR].Metadata_PR,
    [NAM].PR_NAM_PR_ID,
    [NAM].Metadata_PR_NAM,
    [NAM].PR_NAM_Program_Name
FROM
    [dbo].[PR_Program] [PR]
LEFT JOIN
    [dbo].[PR_NAM_Program_Name] [NAM]
ON
    [NAM].PR_NAM_PR_ID = [PR].PR_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pPR_Program viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pPR_Program] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [PR].PR_ID,
    [PR].Metadata_PR,
    [NAM].PR_NAM_PR_ID,
    [NAM].Metadata_PR_NAM,
    [NAM].PR_NAM_Program_Name
FROM
    [dbo].[PR_Program] [PR]
LEFT JOIN
    [dbo].[PR_NAM_Program_Name] [NAM]
ON
    [NAM].PR_NAM_PR_ID = [PR].PR_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nPR_Program viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nPR_Program]
AS
SELECT
    *
FROM
    [dbo].[pPR_Program](sysdatetime());
GO
-- ATTRIBUTE TRIGGERS ------------------------------------------------------------------------------------------------
--
-- The following triggers on the attributes make them behave like tables.
-- There is one 'instead of' trigger for: insert.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_NAM_Stage_Name instead of INSERT trigger on ST_NAM_Stage_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_NAM_Stage_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_NAM_Stage_Name];
GO
CREATE TRIGGER [dbo].[it_ST_NAM_Stage_Name] ON [dbo].[ST_NAM_Stage_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @ST_NAM_Stage_Name TABLE (
        ST_NAM_ST_ID int not null,
        Metadata_ST_NAM int not null,
        ST_NAM_ChangedAt datetime not null,
        ST_NAM_Stage_Name varchar(42) not null,
        ST_NAM_StatementType char(1) not null,
        primary key (
            ST_NAM_ST_ID asc, 
            ST_NAM_ChangedAt desc
        )
    );
    INSERT INTO @ST_NAM_Stage_Name
    SELECT
        i.ST_NAM_ST_ID,
        i.Metadata_ST_NAM,
        i.ST_NAM_ChangedAt,
        i.ST_NAM_Stage_Name,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.ST_NAM_ST_ID
        FROM
            [dbo].[ST_NAM_Stage_Name] x
        WHERE
            x.ST_NAM_ST_ID = i.ST_NAM_ST_ID
        AND
            x.ST_NAM_ChangedAt = i.ST_NAM_ChangedAt
        AND
            x.ST_NAM_Stage_Name = i.ST_NAM_Stage_Name
    ); -- the posit must be different (exclude the identical)
    INSERT INTO [dbo].[ST_NAM_Stage_Name] (
        Metadata_ST_NAM,
        ST_NAM_ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    )
    SELECT
        Metadata_ST_NAM,
        ST_NAM_ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    FROM
        @ST_NAM_Stage_Name
    WHERE
        ST_NAM_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_AVG_Stage_Average instead of INSERT trigger on ST_AVG_Stage_Average
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_AVG_Stage_Average', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_AVG_Stage_Average];
GO
CREATE TRIGGER [dbo].[it_ST_AVG_Stage_Average] ON [dbo].[ST_AVG_Stage_Average]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @ST_AVG_Stage_Average TABLE (
        ST_AVG_ST_ID int not null,
        Metadata_ST_AVG int not null,
        ST_AVG_ChangedAt datetime not null,
        ST_AVG_UTL_ID tinyint not null, 
        ST_AVG_StatementType char(1) not null,
        primary key (
            ST_AVG_ST_ID asc, 
            ST_AVG_ChangedAt desc
        )
    );
    INSERT INTO @ST_AVG_Stage_Average
    SELECT
        i.ST_AVG_ST_ID,
        i.Metadata_ST_AVG,
        i.ST_AVG_ChangedAt,
        i.ST_AVG_UTL_ID,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.ST_AVG_ST_ID
        FROM
            [dbo].[ST_AVG_Stage_Average] x
        WHERE
            x.ST_AVG_ST_ID = i.ST_AVG_ST_ID
        AND
            x.ST_AVG_ChangedAt = i.ST_AVG_ChangedAt
        AND
            x.ST_AVG_UTL_ID = i.ST_AVG_UTL_ID
    ); -- the posit must be different (exclude the identical)
    INSERT INTO [dbo].[ST_AVG_Stage_Average] (
        Metadata_ST_AVG,
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_UTL_ID
    )
    SELECT
        Metadata_ST_AVG,
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_UTL_ID
    FROM
        @ST_AVG_Stage_Average
    WHERE
        ST_AVG_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_NAM_Actor_Name instead of INSERT trigger on AC_NAM_Actor_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_AC_NAM_Actor_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_NAM_Actor_Name];
GO
CREATE TRIGGER [dbo].[it_AC_NAM_Actor_Name] ON [dbo].[AC_NAM_Actor_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @AC_NAM_Actor_Name TABLE (
        AC_NAM_AC_ID int not null,
        Metadata_AC_NAM int not null,
        AC_NAM_ChangedAt datetime not null,
        AC_NAM_Actor_Name varchar(42) not null,
        AC_NAM_StatementType char(1) not null,
        primary key (
            AC_NAM_AC_ID asc, 
            AC_NAM_ChangedAt desc
        )
    );
    INSERT INTO @AC_NAM_Actor_Name
    SELECT
        i.AC_NAM_AC_ID,
        i.Metadata_AC_NAM,
        i.AC_NAM_ChangedAt,
        i.AC_NAM_Actor_Name,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.AC_NAM_AC_ID
        FROM
            [dbo].[AC_NAM_Actor_Name] x
        WHERE
            x.AC_NAM_AC_ID = i.AC_NAM_AC_ID
        AND
            x.AC_NAM_ChangedAt = i.AC_NAM_ChangedAt
        AND
            x.AC_NAM_Actor_Name = i.AC_NAM_Actor_Name
    ); -- the posit must be different (exclude the identical)
    INSERT INTO [dbo].[AC_NAM_Actor_Name] (
        Metadata_AC_NAM,
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    )
    SELECT
        Metadata_AC_NAM,
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    FROM
        @AC_NAM_Actor_Name
    WHERE
        AC_NAM_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_PLV_Actor_ProfessionalLevel instead of INSERT trigger on AC_PLV_Actor_ProfessionalLevel
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_AC_PLV_Actor_ProfessionalLevel', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_PLV_Actor_ProfessionalLevel];
GO
CREATE TRIGGER [dbo].[it_AC_PLV_Actor_ProfessionalLevel] ON [dbo].[AC_PLV_Actor_ProfessionalLevel]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @AC_PLV_Actor_ProfessionalLevel TABLE (
        AC_PLV_AC_ID int not null,
        Metadata_AC_PLV int not null,
        AC_PLV_ChangedAt datetime not null,
        AC_PLV_PLV_ID tinyint not null, 
        AC_PLV_StatementType char(1) not null,
        primary key (
            AC_PLV_AC_ID asc, 
            AC_PLV_ChangedAt desc
        )
    );
    INSERT INTO @AC_PLV_Actor_ProfessionalLevel
    SELECT
        i.AC_PLV_AC_ID,
        i.Metadata_AC_PLV,
        i.AC_PLV_ChangedAt,
        i.AC_PLV_PLV_ID,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.AC_PLV_AC_ID
        FROM
            [dbo].[AC_PLV_Actor_ProfessionalLevel] x
        WHERE
            x.AC_PLV_AC_ID = i.AC_PLV_AC_ID
        AND
            x.AC_PLV_ChangedAt = i.AC_PLV_ChangedAt
        AND
            x.AC_PLV_PLV_ID = i.AC_PLV_PLV_ID
    ); -- the posit must be different (exclude the identical)
    INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel] (
        Metadata_AC_PLV,
        AC_PLV_AC_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PLV_ID
    )
    SELECT
        Metadata_AC_PLV,
        AC_PLV_AC_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PLV_ID
    FROM
        @AC_PLV_Actor_ProfessionalLevel
    WHERE
        AC_PLV_StatementType = 'P';
END
GO
-- ANCHOR TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPE_Performance instead of INSERT trigger on lPE_Performance
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lPE_Performance] ON [dbo].[lPE_Performance]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @PE TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        PE_ID int not null
    );
    INSERT INTO [dbo].[PE_Performance] (
        Metadata_PE 
    )
    OUTPUT
        inserted.PE_ID
    INTO
        @PE
    SELECT
        Metadata_PE 
    FROM
        inserted
    WHERE
        inserted.PE_ID is null;
    DECLARE @inserted TABLE (
        PE_ID int not null,
        Metadata_PE int not null,
        PE_DAT_PE_ID int null,
        Metadata_PE_DAT int null,
        PE_DAT_Performance_Date datetime null,
        PE_AUD_PE_ID int null,
        Metadata_PE_AUD int null,
        PE_AUD_Performance_Audience int null,
        PE_REV_PE_ID int null,
        Metadata_PE_REV int null,
        PE_REV_Performance_Revenue money null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.PE_ID, a.PE_ID),
        i.Metadata_PE,
        ISNULL(ISNULL(i.PE_DAT_PE_ID, i.PE_ID), a.PE_ID),
        ISNULL(i.Metadata_PE_DAT, i.Metadata_PE),
        i.PE_DAT_Performance_Date,
        ISNULL(ISNULL(i.PE_AUD_PE_ID, i.PE_ID), a.PE_ID),
        ISNULL(i.Metadata_PE_AUD, i.Metadata_PE),
        i.PE_AUD_Performance_Audience,
        ISNULL(ISNULL(i.PE_REV_PE_ID, i.PE_ID), a.PE_ID),
        ISNULL(i.Metadata_PE_REV, i.Metadata_PE),
        i.PE_REV_Performance_Revenue
    FROM (
        SELECT
            PE_ID,
            Metadata_PE,
            PE_DAT_PE_ID,
            Metadata_PE_DAT,
            PE_DAT_Performance_Date,
            PE_AUD_PE_ID,
            Metadata_PE_AUD,
            PE_AUD_Performance_Audience,
            PE_REV_PE_ID,
            Metadata_PE_REV,
            PE_REV_Performance_Revenue,
            ROW_NUMBER() OVER (PARTITION BY PE_ID ORDER BY PE_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @PE a
    ON
        a.Row = i.Row;
    INSERT INTO [dbo].[PE_DAT_Performance_Date] (
        Metadata_PE_DAT,
        PE_DAT_PE_ID,
        PE_DAT_Performance_Date
    )
    SELECT DISTINCT
        i.Metadata_PE_DAT,
        i.PE_DAT_PE_ID,
        i.PE_DAT_Performance_Date
    FROM
        @inserted i
    WHERE
        i.PE_DAT_Performance_Date is not null;
    INSERT INTO [dbo].[PE_AUD_Performance_Audience] (
        Metadata_PE_AUD,
        PE_AUD_PE_ID,
        PE_AUD_Performance_Audience
    )
    SELECT DISTINCT
        i.Metadata_PE_AUD,
        i.PE_AUD_PE_ID,
        i.PE_AUD_Performance_Audience
    FROM
        @inserted i
    WHERE
        i.PE_AUD_Performance_Audience is not null;
    INSERT INTO [dbo].[PE_REV_Performance_Revenue] (
        Metadata_PE_REV,
        PE_REV_PE_ID,
        PE_REV_Performance_Revenue
    )
    SELECT DISTINCT
        i.Metadata_PE_REV,
        i.PE_REV_PE_ID,
        i.PE_REV_Performance_Revenue
    FROM
        @inserted i
    WHERE
        i.PE_REV_Performance_Revenue is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPE_Performance instead of UPDATE trigger on lPE_Performance
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lPE_Performance] ON [dbo].[lPE_Performance]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(PE_ID))
        RAISERROR('The identity column PE_ID is not updatable.', 16, 1);
    IF(UPDATE(PE_DAT_PE_ID))
        RAISERROR('The foreign key column PE_DAT_PE_ID is not updatable.', 16, 1);
    IF(UPDATE(PE_DAT_Performance_Date))
    BEGIN
        INSERT INTO [dbo].[PE_DAT_Performance_Date] (
            Metadata_PE_DAT,
            PE_DAT_PE_ID,
            PE_DAT_Performance_Date
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_PE) AND NOT UPDATE(Metadata_PE_DAT)
                THEN i.Metadata_PE
                ELSE i.Metadata_PE_DAT
            END, i.Metadata_PE),
            ISNULL(i.PE_DAT_PE_ID, i.PE_ID),
            i.PE_DAT_Performance_Date
        FROM
            inserted i
        WHERE
            i.PE_DAT_Performance_Date is not null;
    END
    IF(UPDATE(PE_AUD_PE_ID))
        RAISERROR('The foreign key column PE_AUD_PE_ID is not updatable.', 16, 1);
    IF(UPDATE(PE_AUD_Performance_Audience))
    BEGIN
        INSERT INTO [dbo].[PE_AUD_Performance_Audience] (
            Metadata_PE_AUD,
            PE_AUD_PE_ID,
            PE_AUD_Performance_Audience
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_PE) AND NOT UPDATE(Metadata_PE_AUD)
                THEN i.Metadata_PE
                ELSE i.Metadata_PE_AUD
            END, i.Metadata_PE),
            ISNULL(i.PE_AUD_PE_ID, i.PE_ID),
            i.PE_AUD_Performance_Audience
        FROM
            inserted i
        WHERE
            i.PE_AUD_Performance_Audience is not null;
    END
    IF(UPDATE(PE_REV_PE_ID))
        RAISERROR('The foreign key column PE_REV_PE_ID is not updatable.', 16, 1);
    IF(UPDATE(PE_REV_Performance_Revenue))
    BEGIN
        INSERT INTO [dbo].[PE_REV_Performance_Revenue] (
            Metadata_PE_REV,
            PE_REV_PE_ID,
            PE_REV_Performance_Revenue
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_PE) AND NOT UPDATE(Metadata_PE_REV)
                THEN i.Metadata_PE
                ELSE i.Metadata_PE_REV
            END, i.Metadata_PE),
            ISNULL(i.PE_REV_PE_ID, i.PE_ID),
            i.PE_REV_Performance_Revenue
        FROM
            inserted i
        WHERE
            i.PE_REV_Performance_Revenue is not null;
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPE_Performance instead of DELETE trigger on lPE_Performance
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lPE_Performance] ON [dbo].[lPE_Performance]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [DAT]
    FROM
        [dbo].[PE_DAT_Performance_Date] [DAT]
    JOIN
        deleted d
    ON
        d.PE_DAT_PE_ID = [DAT].PE_DAT_PE_ID;
    DELETE [AUD]
    FROM
        [dbo].[PE_AUD_Performance_Audience] [AUD]
    JOIN
        deleted d
    ON
        d.PE_AUD_PE_ID = [AUD].PE_AUD_PE_ID;
    DELETE [REV]
    FROM
        [dbo].[PE_REV_Performance_Revenue] [REV]
    JOIN
        deleted d
    ON
        d.PE_REV_PE_ID = [REV].PE_REV_PE_ID;
    DECLARE @deleted TABLE (
        PE_ID int NOT NULL PRIMARY KEY
    );
    INSERT INTO @deleted (PE_ID)
    SELECT a.PE_ID
    FROM (
        SELECT [PE].PE_ID
        FROM [dbo].[PE_Performance] [PE] WITH(NOLOCK)
        WHERE
        NOT EXISTS (
            SELECT TOP 1 PE_DAT_PE_ID
            FROM [dbo].[PE_DAT_Performance_Date] WITH(NOLOCK)
            WHERE PE_DAT_PE_ID = [PE].PE_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 PE_AUD_PE_ID
            FROM [dbo].[PE_AUD_Performance_Audience] WITH(NOLOCK)
            WHERE PE_AUD_PE_ID = [PE].PE_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 PE_REV_PE_ID
            FROM [dbo].[PE_REV_Performance_Revenue] WITH(NOLOCK)
            WHERE PE_REV_PE_ID = [PE].PE_ID
        )
    ) a
    JOIN deleted d
    ON d.PE_ID = a.PE_ID;
    DELETE [PE]
    FROM [dbo].[PE_Performance] [PE]
    JOIN @deleted d
    ON d.PE_ID = [PE].PE_ID;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_Stage instead of INSERT trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lST_Stage] ON [dbo].[lST_Stage]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @ST TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        ST_ID int not null
    );
    INSERT INTO [dbo].[ST_Stage] (
        Metadata_ST 
    )
    OUTPUT
        inserted.ST_ID
    INTO
        @ST
    SELECT
        Metadata_ST 
    FROM
        inserted
    WHERE
        inserted.ST_ID is null;
    DECLARE @inserted TABLE (
        ST_ID int not null,
        Metadata_ST int not null,
        ST_NAM_ST_ID int null,
        Metadata_ST_NAM int null,
        ST_NAM_ChangedAt datetime null,
        ST_NAM_Stage_Name varchar(42) null,
        ST_LOC_ST_ID int null,
        Metadata_ST_LOC int null,
        ST_LOC_Stage_Location geography null,
        ST_AVG_ST_ID int null,
        Metadata_ST_AVG int null,
        ST_AVG_ChangedAt datetime null,
        ST_AVG_UTL_Utilization tinyint null,
        ST_AVG_Metadata_UTL int null,
        ST_AVG_UTL_ID tinyint null,
        ST_MIN_ST_ID int null,
        Metadata_ST_MIN int null,
        ST_MIN_UTL_Utilization tinyint null,
        ST_MIN_Metadata_UTL int null,
        ST_MIN_UTL_ID tinyint null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.ST_ID, a.ST_ID),
        i.Metadata_ST,
        ISNULL(ISNULL(i.ST_NAM_ST_ID, i.ST_ID), a.ST_ID),
        ISNULL(i.Metadata_ST_NAM, i.Metadata_ST),
        ISNULL(i.ST_NAM_ChangedAt, @now),
        i.ST_NAM_Stage_Name,
        ISNULL(ISNULL(i.ST_LOC_ST_ID, i.ST_ID), a.ST_ID),
        ISNULL(i.Metadata_ST_LOC, i.Metadata_ST),
        i.ST_LOC_Stage_Location,
        ISNULL(ISNULL(i.ST_AVG_ST_ID, i.ST_ID), a.ST_ID),
        ISNULL(i.Metadata_ST_AVG, i.Metadata_ST),
        ISNULL(i.ST_AVG_ChangedAt, @now),
        i.ST_AVG_UTL_Utilization,
        ISNULL(i.ST_AVG_Metadata_UTL, i.Metadata_ST),
        i.ST_AVG_UTL_ID,
        ISNULL(ISNULL(i.ST_MIN_ST_ID, i.ST_ID), a.ST_ID),
        ISNULL(i.Metadata_ST_MIN, i.Metadata_ST),
        i.ST_MIN_UTL_Utilization,
        ISNULL(i.ST_MIN_Metadata_UTL, i.Metadata_ST),
        i.ST_MIN_UTL_ID
    FROM (
        SELECT
            ST_ID,
            Metadata_ST,
            ST_NAM_ST_ID,
            Metadata_ST_NAM,
            ST_NAM_ChangedAt,
            ST_NAM_Stage_Name,
            ST_LOC_ST_ID,
            Metadata_ST_LOC,
            ST_LOC_Stage_Location,
            ST_AVG_ST_ID,
            Metadata_ST_AVG,
            ST_AVG_ChangedAt,
            ST_AVG_UTL_Utilization,
            ST_AVG_Metadata_UTL,
            ST_AVG_UTL_ID,
            ST_MIN_ST_ID,
            Metadata_ST_MIN,
            ST_MIN_UTL_Utilization,
            ST_MIN_Metadata_UTL,
            ST_MIN_UTL_ID,
            ROW_NUMBER() OVER (PARTITION BY ST_ID ORDER BY ST_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @ST a
    ON
        a.Row = i.Row;
    INSERT INTO [dbo].[ST_NAM_Stage_Name] (
        Metadata_ST_NAM,
        ST_NAM_ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    )
    SELECT DISTINCT
        i.Metadata_ST_NAM,
        i.ST_NAM_ST_ID,
        i.ST_NAM_ChangedAt,
        i.ST_NAM_Stage_Name
    FROM
        @inserted i
    WHERE
        i.ST_NAM_Stage_Name is not null;
    INSERT INTO [dbo].[ST_LOC_Stage_Location] (
        Metadata_ST_LOC,
        ST_LOC_ST_ID,
        ST_LOC_Stage_Location
    )
    SELECT 
        i.Metadata_ST_LOC,
        i.ST_LOC_ST_ID,
        i.ST_LOC_Stage_Location
    FROM
        @inserted i
    WHERE
        i.ST_LOC_Stage_Location is not null;
    INSERT INTO [dbo].[ST_AVG_Stage_Average] (
        Metadata_ST_AVG,
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_UTL_ID
    )
    SELECT DISTINCT
        i.Metadata_ST_AVG,
        i.ST_AVG_ST_ID,
        i.ST_AVG_ChangedAt,
        ISNULL(i.ST_AVG_UTL_ID, [kUTL].UTL_ID) 
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[UTL_Utilization] [kUTL]
    ON
        [kUTL].UTL_Utilization = i.ST_AVG_UTL_Utilization
    WHERE
        ISNULL(i.ST_AVG_UTL_ID, [kUTL].UTL_ID) is not null;
    INSERT INTO [dbo].[ST_MIN_Stage_Minimum] (
        Metadata_ST_MIN,
        ST_MIN_ST_ID,
        ST_MIN_UTL_ID
    )
    SELECT DISTINCT
        i.Metadata_ST_MIN,
        i.ST_MIN_ST_ID,
        ISNULL(i.ST_MIN_UTL_ID, [kUTL].UTL_ID) 
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[UTL_Utilization] [kUTL]
    ON
        [kUTL].UTL_Utilization = i.ST_MIN_UTL_Utilization
    WHERE
        ISNULL(i.ST_MIN_UTL_ID, [kUTL].UTL_ID) is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lST_Stage instead of UPDATE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lST_Stage] ON [dbo].[lST_Stage]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(ST_ID))
        RAISERROR('The identity column ST_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_NAM_ST_ID))
        RAISERROR('The foreign key column ST_NAM_ST_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_NAM_Stage_Name))
    BEGIN
        INSERT INTO [dbo].[ST_NAM_Stage_Name] (
            Metadata_ST_NAM,
            ST_NAM_ST_ID,
            ST_NAM_ChangedAt,
            ST_NAM_Stage_Name
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_ST) AND NOT UPDATE(Metadata_ST_NAM)
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_NAM
            END, i.Metadata_ST),
            ISNULL(i.ST_NAM_ST_ID, i.ST_ID),
            cast(ISNULL(CASE
                WHEN i.ST_NAM_Stage_Name is null THEN i.ST_NAM_ChangedAt
                WHEN UPDATE(ST_NAM_ChangedAt) THEN i.ST_NAM_ChangedAt
            END, @now) as datetime),
            i.ST_NAM_Stage_Name
        FROM
            inserted i
        WHERE
            i.ST_NAM_Stage_Name is not null;
    END
    IF(UPDATE(ST_LOC_ST_ID))
        RAISERROR('The foreign key column ST_LOC_ST_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_LOC_Stage_Location))
    BEGIN
        INSERT INTO [dbo].[ST_LOC_Stage_Location] (
            Metadata_ST_LOC,
            ST_LOC_ST_ID,
            ST_LOC_Stage_Location
        )
        SELECT 
            ISNULL(CASE
                WHEN UPDATE(Metadata_ST) AND NOT UPDATE(Metadata_ST_LOC)
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_LOC
            END, i.Metadata_ST),
            ISNULL(i.ST_LOC_ST_ID, i.ST_ID),
            i.ST_LOC_Stage_Location
        FROM
            inserted i
        WHERE
            i.ST_LOC_Stage_Location is not null;
    END
    IF(UPDATE(ST_AVG_ST_ID))
        RAISERROR('The foreign key column ST_AVG_ST_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_AVG_UTL_ID) OR UPDATE(ST_AVG_UTL_Utilization))
    BEGIN
        INSERT INTO [dbo].[ST_AVG_Stage_Average] (
            Metadata_ST_AVG,
            ST_AVG_ST_ID,
            ST_AVG_ChangedAt,
            ST_AVG_UTL_ID
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_ST) AND NOT UPDATE(Metadata_ST_AVG)
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_AVG
            END, i.Metadata_ST),
            ISNULL(i.ST_AVG_ST_ID, i.ST_ID),
            cast(ISNULL(CASE
                WHEN i.ST_AVG_UTL_ID is null AND [kUTL].UTL_ID is null THEN i.ST_AVG_ChangedAt
                WHEN UPDATE(ST_AVG_ChangedAt) THEN i.ST_AVG_ChangedAt
            END, @now) as datetime),
            CASE WHEN UPDATE(ST_AVG_UTL_ID) THEN i.ST_AVG_UTL_ID ELSE [kUTL].UTL_ID END
        FROM
            inserted i
        LEFT JOIN
            [dbo].[UTL_Utilization] [kUTL]
        ON
            [kUTL].UTL_Utilization = i.ST_AVG_UTL_Utilization
        WHERE
            CASE WHEN UPDATE(ST_AVG_UTL_ID) THEN i.ST_AVG_UTL_ID ELSE [kUTL].UTL_ID END is not null;
    END
    IF(UPDATE(ST_MIN_ST_ID))
        RAISERROR('The foreign key column ST_MIN_ST_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_MIN_UTL_ID) OR UPDATE(ST_MIN_UTL_Utilization))
    BEGIN
        INSERT INTO [dbo].[ST_MIN_Stage_Minimum] (
            Metadata_ST_MIN,
            ST_MIN_ST_ID,
            ST_MIN_UTL_ID
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_ST) AND NOT UPDATE(Metadata_ST_MIN)
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_MIN
            END, i.Metadata_ST),
            ISNULL(i.ST_MIN_ST_ID, i.ST_ID),
            CASE WHEN UPDATE(ST_MIN_UTL_ID) THEN i.ST_MIN_UTL_ID ELSE [kUTL].UTL_ID END
        FROM
            inserted i
        LEFT JOIN
            [dbo].[UTL_Utilization] [kUTL]
        ON
            [kUTL].UTL_Utilization = i.ST_MIN_UTL_Utilization
        WHERE
            CASE WHEN UPDATE(ST_MIN_UTL_ID) THEN i.ST_MIN_UTL_ID ELSE [kUTL].UTL_ID END is not null;
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_Stage instead of DELETE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lST_Stage] ON [dbo].[lST_Stage]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [NAM]
    FROM
        [dbo].[ST_NAM_Stage_Name] [NAM]
    JOIN
        deleted d
    ON
        d.ST_NAM_ChangedAt = [NAM].ST_NAM_ChangedAt
    AND
        d.ST_NAM_ST_ID = [NAM].ST_NAM_ST_ID;
    DELETE [LOC]
    FROM
        [dbo].[ST_LOC_Stage_Location] [LOC]
    JOIN
        deleted d
    ON
        d.ST_LOC_ST_ID = [LOC].ST_LOC_ST_ID;
    DELETE [AVG]
    FROM
        [dbo].[ST_AVG_Stage_Average] [AVG]
    JOIN
        deleted d
    ON
        d.ST_AVG_ChangedAt = [AVG].ST_AVG_ChangedAt
    AND
        d.ST_AVG_ST_ID = [AVG].ST_AVG_ST_ID;
    DELETE [MIN]
    FROM
        [dbo].[ST_MIN_Stage_Minimum] [MIN]
    JOIN
        deleted d
    ON
        d.ST_MIN_ST_ID = [MIN].ST_MIN_ST_ID;
    DECLARE @deleted TABLE (
        ST_ID int NOT NULL PRIMARY KEY
    );
    INSERT INTO @deleted (ST_ID)
    SELECT a.ST_ID
    FROM (
        SELECT [ST].ST_ID
        FROM [dbo].[ST_Stage] [ST] WITH(NOLOCK)
        WHERE
        NOT EXISTS (
            SELECT TOP 1 ST_NAM_ST_ID
            FROM [dbo].[ST_NAM_Stage_Name] WITH(NOLOCK)
            WHERE ST_NAM_ST_ID = [ST].ST_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 ST_LOC_ST_ID
            FROM [dbo].[ST_LOC_Stage_Location] WITH(NOLOCK)
            WHERE ST_LOC_ST_ID = [ST].ST_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 ST_AVG_ST_ID
            FROM [dbo].[ST_AVG_Stage_Average] WITH(NOLOCK)
            WHERE ST_AVG_ST_ID = [ST].ST_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 ST_MIN_ST_ID
            FROM [dbo].[ST_MIN_Stage_Minimum] WITH(NOLOCK)
            WHERE ST_MIN_ST_ID = [ST].ST_ID
        )
    ) a
    JOIN deleted d
    ON d.ST_ID = a.ST_ID;
    DELETE [ST]
    FROM [dbo].[ST_Stage] [ST]
    JOIN @deleted d
    ON d.ST_ID = [ST].ST_ID;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_Actor instead of INSERT trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lAC_Actor] ON [dbo].[lAC_Actor]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @AC TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        AC_ID int not null
    );
    INSERT INTO [dbo].[AC_Actor] (
        Metadata_AC 
    )
    OUTPUT
        inserted.AC_ID
    INTO
        @AC
    SELECT
        Metadata_AC 
    FROM
        inserted
    WHERE
        inserted.AC_ID is null;
    DECLARE @inserted TABLE (
        AC_ID int not null,
        Metadata_AC int not null,
        AC_NAM_AC_ID int null,
        Metadata_AC_NAM int null,
        AC_NAM_ChangedAt datetime null,
        AC_NAM_Actor_Name varchar(42) null,
        AC_GEN_AC_ID int null,
        Metadata_AC_GEN int null,
        AC_GEN_GEN_Gender varchar(42) null,
        AC_GEN_Metadata_GEN int null,
        AC_GEN_GEN_ID bit null,
        AC_PLV_AC_ID int null,
        Metadata_AC_PLV int null,
        AC_PLV_ChangedAt datetime null,
        AC_PLV_PLV_ProfessionalLevel varchar(max) null,
        AC_PLV_PLV_Checksum varbinary(16) null,
        AC_PLV_Metadata_PLV int null,
        AC_PLV_PLV_ID tinyint null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.AC_ID, a.AC_ID),
        i.Metadata_AC,
        ISNULL(ISNULL(i.AC_NAM_AC_ID, i.AC_ID), a.AC_ID),
        ISNULL(i.Metadata_AC_NAM, i.Metadata_AC),
        ISNULL(i.AC_NAM_ChangedAt, @now),
        i.AC_NAM_Actor_Name,
        ISNULL(ISNULL(i.AC_GEN_AC_ID, i.AC_ID), a.AC_ID),
        ISNULL(i.Metadata_AC_GEN, i.Metadata_AC),
        i.AC_GEN_GEN_Gender,
        ISNULL(i.AC_GEN_Metadata_GEN, i.Metadata_AC),
        i.AC_GEN_GEN_ID,
        ISNULL(ISNULL(i.AC_PLV_AC_ID, i.AC_ID), a.AC_ID),
        ISNULL(i.Metadata_AC_PLV, i.Metadata_AC),
        ISNULL(i.AC_PLV_ChangedAt, @now),
        i.AC_PLV_PLV_ProfessionalLevel,
        ISNULL(i.AC_PLV_PLV_Checksum, dbo.MD5(cast(i.AC_PLV_PLV_ProfessionalLevel as varbinary(max)))),
        ISNULL(i.AC_PLV_Metadata_PLV, i.Metadata_AC),
        i.AC_PLV_PLV_ID
    FROM (
        SELECT
            AC_ID,
            Metadata_AC,
            AC_NAM_AC_ID,
            Metadata_AC_NAM,
            AC_NAM_ChangedAt,
            AC_NAM_Actor_Name,
            AC_GEN_AC_ID,
            Metadata_AC_GEN,
            AC_GEN_GEN_Gender,
            AC_GEN_Metadata_GEN,
            AC_GEN_GEN_ID,
            AC_PLV_AC_ID,
            Metadata_AC_PLV,
            AC_PLV_ChangedAt,
            AC_PLV_PLV_ProfessionalLevel,
            AC_PLV_PLV_Checksum,
            AC_PLV_Metadata_PLV,
            AC_PLV_PLV_ID,
            ROW_NUMBER() OVER (PARTITION BY AC_ID ORDER BY AC_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @AC a
    ON
        a.Row = i.Row;
    INSERT INTO [dbo].[AC_NAM_Actor_Name] (
        Metadata_AC_NAM,
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    )
    SELECT DISTINCT
        i.Metadata_AC_NAM,
        i.AC_NAM_AC_ID,
        i.AC_NAM_ChangedAt,
        i.AC_NAM_Actor_Name
    FROM
        @inserted i
    WHERE
        i.AC_NAM_Actor_Name is not null;
    INSERT INTO [dbo].[AC_GEN_Actor_Gender] (
        Metadata_AC_GEN,
        AC_GEN_AC_ID,
        AC_GEN_GEN_ID
    )
    SELECT DISTINCT
        i.Metadata_AC_GEN,
        i.AC_GEN_AC_ID,
        ISNULL(i.AC_GEN_GEN_ID, [kGEN].GEN_ID) 
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[GEN_Gender] [kGEN]
    ON
        [kGEN].GEN_Gender = i.AC_GEN_GEN_Gender
    WHERE
        ISNULL(i.AC_GEN_GEN_ID, [kGEN].GEN_ID) is not null;
    INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel] (
        Metadata_AC_PLV,
        AC_PLV_AC_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PLV_ID
    )
    SELECT DISTINCT
        i.Metadata_AC_PLV,
        i.AC_PLV_AC_ID,
        i.AC_PLV_ChangedAt,
        ISNULL(i.AC_PLV_PLV_ID, [kPLV].PLV_ID) 
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[PLV_ProfessionalLevel] [kPLV]
    ON
        [kPLV].PLV_Checksum = i.AC_PLV_PLV_Checksum 
    WHERE
        ISNULL(i.AC_PLV_PLV_ID, [kPLV].PLV_ID) is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_Actor instead of UPDATE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lAC_Actor] ON [dbo].[lAC_Actor]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(AC_ID))
        RAISERROR('The identity column AC_ID is not updatable.', 16, 1);
    IF(UPDATE(AC_NAM_AC_ID))
        RAISERROR('The foreign key column AC_NAM_AC_ID is not updatable.', 16, 1);
    IF(UPDATE(AC_NAM_Actor_Name))
    BEGIN
        INSERT INTO [dbo].[AC_NAM_Actor_Name] (
            Metadata_AC_NAM,
            AC_NAM_AC_ID,
            AC_NAM_ChangedAt,
            AC_NAM_Actor_Name
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_AC) AND NOT UPDATE(Metadata_AC_NAM)
                THEN i.Metadata_AC
                ELSE i.Metadata_AC_NAM
            END, i.Metadata_AC),
            ISNULL(i.AC_NAM_AC_ID, i.AC_ID),
            cast(ISNULL(CASE
                WHEN i.AC_NAM_Actor_Name is null THEN i.AC_NAM_ChangedAt
                WHEN UPDATE(AC_NAM_ChangedAt) THEN i.AC_NAM_ChangedAt
            END, @now) as datetime),
            i.AC_NAM_Actor_Name
        FROM
            inserted i
        WHERE
            i.AC_NAM_Actor_Name is not null;
    END
    IF(UPDATE(AC_GEN_AC_ID))
        RAISERROR('The foreign key column AC_GEN_AC_ID is not updatable.', 16, 1);
    IF(UPDATE(AC_GEN_GEN_ID) OR UPDATE(AC_GEN_GEN_Gender))
    BEGIN
        INSERT INTO [dbo].[AC_GEN_Actor_Gender] (
            Metadata_AC_GEN,
            AC_GEN_AC_ID,
            AC_GEN_GEN_ID
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_AC) AND NOT UPDATE(Metadata_AC_GEN)
                THEN i.Metadata_AC
                ELSE i.Metadata_AC_GEN
            END, i.Metadata_AC),
            ISNULL(i.AC_GEN_AC_ID, i.AC_ID),
            CASE WHEN UPDATE(AC_GEN_GEN_ID) THEN i.AC_GEN_GEN_ID ELSE [kGEN].GEN_ID END
        FROM
            inserted i
        LEFT JOIN
            [dbo].[GEN_Gender] [kGEN]
        ON
            [kGEN].GEN_Gender = i.AC_GEN_GEN_Gender
        WHERE
            CASE WHEN UPDATE(AC_GEN_GEN_ID) THEN i.AC_GEN_GEN_ID ELSE [kGEN].GEN_ID END is not null;
    END
    IF(UPDATE(AC_PLV_AC_ID))
        RAISERROR('The foreign key column AC_PLV_AC_ID is not updatable.', 16, 1);
    IF(UPDATE(AC_PLV_PLV_ID) OR UPDATE(AC_PLV_PLV_ProfessionalLevel))
    BEGIN
        INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel] (
            Metadata_AC_PLV,
            AC_PLV_AC_ID,
            AC_PLV_ChangedAt,
            AC_PLV_PLV_ID
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_AC) AND NOT UPDATE(Metadata_AC_PLV)
                THEN i.Metadata_AC
                ELSE i.Metadata_AC_PLV
            END, i.Metadata_AC),
            ISNULL(i.AC_PLV_AC_ID, i.AC_ID),
            cast(ISNULL(CASE
                WHEN i.AC_PLV_PLV_ID is null AND [kPLV].PLV_ID is null THEN i.AC_PLV_ChangedAt
                WHEN UPDATE(AC_PLV_ChangedAt) THEN i.AC_PLV_ChangedAt
            END, @now) as datetime),
            CASE WHEN UPDATE(AC_PLV_PLV_ID) THEN i.AC_PLV_PLV_ID ELSE [kPLV].PLV_ID END
        FROM
            inserted i
        LEFT JOIN
            [dbo].[PLV_ProfessionalLevel] [kPLV]
        ON
            [kPLV].PLV_Checksum = dbo.MD5(cast(i.AC_PLV_PLV_ProfessionalLevel as varbinary(max))) 
        WHERE
            CASE WHEN UPDATE(AC_PLV_PLV_ID) THEN i.AC_PLV_PLV_ID ELSE [kPLV].PLV_ID END is not null;
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_Actor instead of DELETE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lAC_Actor] ON [dbo].[lAC_Actor]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [NAM]
    FROM
        [dbo].[AC_NAM_Actor_Name] [NAM]
    JOIN
        deleted d
    ON
        d.AC_NAM_ChangedAt = [NAM].AC_NAM_ChangedAt
    AND
        d.AC_NAM_AC_ID = [NAM].AC_NAM_AC_ID;
    DELETE [GEN]
    FROM
        [dbo].[AC_GEN_Actor_Gender] [GEN]
    JOIN
        deleted d
    ON
        d.AC_GEN_AC_ID = [GEN].AC_GEN_AC_ID;
    DELETE [PLV]
    FROM
        [dbo].[AC_PLV_Actor_ProfessionalLevel] [PLV]
    JOIN
        deleted d
    ON
        d.AC_PLV_ChangedAt = [PLV].AC_PLV_ChangedAt
    AND
        d.AC_PLV_AC_ID = [PLV].AC_PLV_AC_ID;
    DECLARE @deleted TABLE (
        AC_ID int NOT NULL PRIMARY KEY
    );
    INSERT INTO @deleted (AC_ID)
    SELECT a.AC_ID
    FROM (
        SELECT [AC].AC_ID
        FROM [dbo].[AC_Actor] [AC] WITH(NOLOCK)
        WHERE
        NOT EXISTS (
            SELECT TOP 1 AC_NAM_AC_ID
            FROM [dbo].[AC_NAM_Actor_Name] WITH(NOLOCK)
            WHERE AC_NAM_AC_ID = [AC].AC_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 AC_GEN_AC_ID
            FROM [dbo].[AC_GEN_Actor_Gender] WITH(NOLOCK)
            WHERE AC_GEN_AC_ID = [AC].AC_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 AC_PLV_AC_ID
            FROM [dbo].[AC_PLV_Actor_ProfessionalLevel] WITH(NOLOCK)
            WHERE AC_PLV_AC_ID = [AC].AC_ID
        )
    ) a
    JOIN deleted d
    ON d.AC_ID = a.AC_ID;
    DELETE [AC]
    FROM [dbo].[AC_Actor] [AC]
    JOIN @deleted d
    ON d.AC_ID = [AC].AC_ID;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_Program instead of INSERT trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lPR_Program] ON [dbo].[lPR_Program]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @PR TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        PR_ID int not null
    );
    INSERT INTO [dbo].[PR_Program] (
        Metadata_PR 
    )
    OUTPUT
        inserted.PR_ID
    INTO
        @PR
    SELECT
        Metadata_PR 
    FROM
        inserted
    WHERE
        inserted.PR_ID is null;
    DECLARE @inserted TABLE (
        PR_ID int not null,
        Metadata_PR int not null,
        PR_NAM_PR_ID int null,
        Metadata_PR_NAM int null,
        PR_NAM_Program_Name varchar(42) null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.PR_ID, a.PR_ID),
        i.Metadata_PR,
        ISNULL(ISNULL(i.PR_NAM_PR_ID, i.PR_ID), a.PR_ID),
        ISNULL(i.Metadata_PR_NAM, i.Metadata_PR),
        i.PR_NAM_Program_Name
    FROM (
        SELECT
            PR_ID,
            Metadata_PR,
            PR_NAM_PR_ID,
            Metadata_PR_NAM,
            PR_NAM_Program_Name,
            ROW_NUMBER() OVER (PARTITION BY PR_ID ORDER BY PR_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @PR a
    ON
        a.Row = i.Row;
    INSERT INTO [dbo].[PR_NAM_Program_Name] (
        Metadata_PR_NAM,
        PR_NAM_PR_ID,
        PR_NAM_Program_Name
    )
    SELECT DISTINCT
        i.Metadata_PR_NAM,
        i.PR_NAM_PR_ID,
        i.PR_NAM_Program_Name
    FROM
        @inserted i
    WHERE
        i.PR_NAM_Program_Name is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_Program instead of UPDATE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lPR_Program] ON [dbo].[lPR_Program]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(PR_ID))
        RAISERROR('The identity column PR_ID is not updatable.', 16, 1);
    IF(UPDATE(PR_NAM_PR_ID))
        RAISERROR('The foreign key column PR_NAM_PR_ID is not updatable.', 16, 1);
    IF(UPDATE(PR_NAM_Program_Name))
    BEGIN
        INSERT INTO [dbo].[PR_NAM_Program_Name] (
            Metadata_PR_NAM,
            PR_NAM_PR_ID,
            PR_NAM_Program_Name
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_PR) AND NOT UPDATE(Metadata_PR_NAM)
                THEN i.Metadata_PR
                ELSE i.Metadata_PR_NAM
            END, i.Metadata_PR),
            ISNULL(i.PR_NAM_PR_ID, i.PR_ID),
            i.PR_NAM_Program_Name
        FROM
            inserted i
        WHERE
            i.PR_NAM_Program_Name is not null;
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_Program instead of DELETE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lPR_Program] ON [dbo].[lPR_Program]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [NAM]
    FROM
        [dbo].[PR_NAM_Program_Name] [NAM]
    JOIN
        deleted d
    ON
        d.PR_NAM_PR_ID = [NAM].PR_NAM_PR_ID;
    DECLARE @deleted TABLE (
        PR_ID int NOT NULL PRIMARY KEY
    );
    INSERT INTO @deleted (PR_ID)
    SELECT a.PR_ID
    FROM (
        SELECT [PR].PR_ID
        FROM [dbo].[PR_Program] [PR] WITH(NOLOCK)
        WHERE
        NOT EXISTS (
            SELECT TOP 1 PR_NAM_PR_ID
            FROM [dbo].[PR_NAM_Program_Name] WITH(NOLOCK)
            WHERE PR_NAM_PR_ID = [PR].PR_ID
        )
    ) a
    JOIN deleted d
    ON d.PR_ID = a.PR_ID;
    DELETE [PR]
    FROM [dbo].[PR_Program] [PR]
    JOIN @deleted d
    ON d.PR_ID = [PR].PR_ID;
END
GO
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each tie. There are four types of perspectives: latest,
-- point-in-time, difference, and now.
--
-- The latest perspective shows the latest available information for each tie.
-- The now perspective shows the information as it is right now.
-- The point-in-time perspective lets you travel through the information to the given timepoint.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints.
--
-- @intervalStart the start of the interval for finding changes
-- @intervalEnd the end of the interval for finding changes
--
-- Under equivalence all these views default to equivalent = 0, however, corresponding
-- prepended-e perspectives are provided in order to select a specific equivalent.
--
-- @equivalent the equivalent for which to retrieve data
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dAC_exclusive_AC_with_ONG_currently', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dAC_exclusive_AC_with_ONG_currently];
IF Object_ID('dbo.nAC_exclusive_AC_with_ONG_currently', 'V') IS NOT NULL
DROP VIEW [dbo].[nAC_exclusive_AC_with_ONG_currently];
IF Object_ID('dbo.pAC_exclusive_AC_with_ONG_currently', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pAC_exclusive_AC_with_ONG_currently];
IF Object_ID('dbo.lAC_exclusive_AC_with_ONG_currently', 'V') IS NOT NULL
DROP VIEW [dbo].[lAC_exclusive_AC_with_ONG_currently];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_exclusive_AC_with_ONG_currently viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lAC_exclusive_AC_with_ONG_currently] WITH SCHEMABINDING AS
SELECT
    tie.Metadata_AC_exclusive_AC_with_ONG_currently,
    tie.AC_exclusive_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_exclusive,
    tie.AC_ID_with,
    [ONG_currently].ONG_Ongoing AS currently_ONG_Ongoing,
    [ONG_currently].Metadata_ONG AS currently_Metadata_ONG,
    tie.ONG_ID_currently
FROM
    [dbo].[AC_exclusive_AC_with_ONG_currently] tie
LEFT JOIN
    [dbo].[ONG_Ongoing] [ONG_currently]
ON
    [ONG_currently].ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_exclusive_AC_with_ONG_currently_ChangedAt = (
        SELECT
            max(sub.AC_exclusive_AC_with_ONG_currently_ChangedAt)
        FROM
            [dbo].[AC_exclusive_AC_with_ONG_currently] sub
        WHERE
            sub.AC_ID_exclusive = tie.AC_ID_exclusive
        OR
            sub.AC_ID_with = tie.AC_ID_with
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_exclusive_AC_with_ONG_currently viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pAC_exclusive_AC_with_ONG_currently] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.Metadata_AC_exclusive_AC_with_ONG_currently,
    tie.AC_exclusive_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_exclusive,
    tie.AC_ID_with,
    [ONG_currently].ONG_Ongoing AS currently_ONG_Ongoing,
    [ONG_currently].Metadata_ONG AS currently_Metadata_ONG,
    tie.ONG_ID_currently
FROM
    [dbo].[AC_exclusive_AC_with_ONG_currently] tie
LEFT JOIN
    [dbo].[ONG_Ongoing] [ONG_currently]
ON
    [ONG_currently].ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_exclusive_AC_with_ONG_currently_ChangedAt = (
        SELECT
            max(sub.AC_exclusive_AC_with_ONG_currently_ChangedAt)
        FROM
            [dbo].[AC_exclusive_AC_with_ONG_currently] sub
        WHERE
        (
                sub.AC_ID_exclusive = tie.AC_ID_exclusive
            OR
                sub.AC_ID_with = tie.AC_ID_with
        )
        AND
            sub.AC_exclusive_AC_with_ONG_currently_ChangedAt <= @changingTimepoint
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_exclusive_AC_with_ONG_currently viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nAC_exclusive_AC_with_ONG_currently]
AS
SELECT
    *
FROM
    [dbo].[pAC_exclusive_AC_with_ONG_currently](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dAC_exclusive_AC_with_ONG_currently showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dAC_exclusive_AC_with_ONG_currently] (
    @intervalStart datetime2(7),
    @intervalEnd datetime2(7)
)
RETURNS TABLE AS RETURN
SELECT
    tie.Metadata_AC_exclusive_AC_with_ONG_currently,
    tie.AC_exclusive_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_exclusive,
    tie.AC_ID_with,
    [ONG_currently].ONG_Ongoing AS currently_ONG_Ongoing,
    [ONG_currently].Metadata_ONG AS currently_Metadata_ONG,
    tie.ONG_ID_currently
FROM
    [dbo].[AC_exclusive_AC_with_ONG_currently] tie
LEFT JOIN
    [dbo].[ONG_Ongoing] [ONG_currently]
ON
    [ONG_currently].ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_exclusive_AC_with_ONG_currently_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dPE_wasHeld_ST_at', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dPE_wasHeld_ST_at];
IF Object_ID('dbo.nPE_wasHeld_ST_at', 'V') IS NOT NULL
DROP VIEW [dbo].[nPE_wasHeld_ST_at];
IF Object_ID('dbo.pPE_wasHeld_ST_at', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pPE_wasHeld_ST_at];
IF Object_ID('dbo.lPE_wasHeld_ST_at', 'V') IS NOT NULL
DROP VIEW [dbo].[lPE_wasHeld_ST_at];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lPE_wasHeld_ST_at viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lPE_wasHeld_ST_at] WITH SCHEMABINDING AS
SELECT
    tie.Metadata_PE_wasHeld_ST_at,
    tie.PE_ID_wasHeld,
    tie.ST_ID_at
FROM
    [dbo].[PE_wasHeld_ST_at] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pPE_wasHeld_ST_at viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pPE_wasHeld_ST_at] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.Metadata_PE_wasHeld_ST_at,
    tie.PE_ID_wasHeld,
    tie.ST_ID_at
FROM
    [dbo].[PE_wasHeld_ST_at] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nPE_wasHeld_ST_at viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nPE_wasHeld_ST_at]
AS
SELECT
    *
FROM
    [dbo].[pPE_wasHeld_ST_at](sysdatetime());
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dAC_subset_PN_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dAC_subset_PN_of];
IF Object_ID('dbo.nAC_subset_PN_of', 'V') IS NOT NULL
DROP VIEW [dbo].[nAC_subset_PN_of];
IF Object_ID('dbo.pAC_subset_PN_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pAC_subset_PN_of];
IF Object_ID('dbo.lAC_subset_PN_of', 'V') IS NOT NULL
DROP VIEW [dbo].[lAC_subset_PN_of];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_subset_PN_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lAC_subset_PN_of] WITH SCHEMABINDING AS
SELECT
    tie.Metadata_AC_subset_PN_of,
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    [dbo].[AC_subset_PN_of] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_subset_PN_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pAC_subset_PN_of] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.Metadata_AC_subset_PN_of,
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    [dbo].[AC_subset_PN_of] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_subset_PN_of viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nAC_subset_PN_of]
AS
SELECT
    *
FROM
    [dbo].[pAC_subset_PN_of](sysdatetime());
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dPE_at_PR_wasPlayed', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dPE_at_PR_wasPlayed];
IF Object_ID('dbo.nPE_at_PR_wasPlayed', 'V') IS NOT NULL
DROP VIEW [dbo].[nPE_at_PR_wasPlayed];
IF Object_ID('dbo.pPE_at_PR_wasPlayed', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pPE_at_PR_wasPlayed];
IF Object_ID('dbo.lPE_at_PR_wasPlayed', 'V') IS NOT NULL
DROP VIEW [dbo].[lPE_at_PR_wasPlayed];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lPE_at_PR_wasPlayed viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lPE_at_PR_wasPlayed] WITH SCHEMABINDING AS
SELECT
    tie.Metadata_PE_at_PR_wasPlayed,
    tie.PE_ID_at,
    tie.PR_ID_wasPlayed
FROM
    [dbo].[PE_at_PR_wasPlayed] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pPE_at_PR_wasPlayed viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pPE_at_PR_wasPlayed] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.Metadata_PE_at_PR_wasPlayed,
    tie.PE_ID_at,
    tie.PR_ID_wasPlayed
FROM
    [dbo].[PE_at_PR_wasPlayed] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nPE_at_PR_wasPlayed viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nPE_at_PR_wasPlayed]
AS
SELECT
    *
FROM
    [dbo].[pPE_at_PR_wasPlayed](sysdatetime());
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dPE_in_AC_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dPE_in_AC_wasCast];
IF Object_ID('dbo.nPE_in_AC_wasCast', 'V') IS NOT NULL
DROP VIEW [dbo].[nPE_in_AC_wasCast];
IF Object_ID('dbo.pPE_in_AC_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pPE_in_AC_wasCast];
IF Object_ID('dbo.lPE_in_AC_wasCast', 'V') IS NOT NULL
DROP VIEW [dbo].[lPE_in_AC_wasCast];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lPE_in_AC_wasCast viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lPE_in_AC_wasCast] WITH SCHEMABINDING AS
SELECT
    tie.Metadata_PE_in_AC_wasCast,
    tie.PE_ID_in,
    tie.AC_ID_wasCast
FROM
    [dbo].[PE_in_AC_wasCast] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pPE_in_AC_wasCast viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pPE_in_AC_wasCast] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.Metadata_PE_in_AC_wasCast,
    tie.PE_ID_in,
    tie.AC_ID_wasCast
FROM
    [dbo].[PE_in_AC_wasCast] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nPE_in_AC_wasCast viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nPE_in_AC_wasCast]
AS
SELECT
    *
FROM
    [dbo].[pPE_in_AC_wasCast](sysdatetime());
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dAC_part_PR_in_RAT_got', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dAC_part_PR_in_RAT_got];
IF Object_ID('dbo.nAC_part_PR_in_RAT_got', 'V') IS NOT NULL
DROP VIEW [dbo].[nAC_part_PR_in_RAT_got];
IF Object_ID('dbo.pAC_part_PR_in_RAT_got', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pAC_part_PR_in_RAT_got];
IF Object_ID('dbo.lAC_part_PR_in_RAT_got', 'V') IS NOT NULL
DROP VIEW [dbo].[lAC_part_PR_in_RAT_got];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_part_PR_in_RAT_got viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lAC_part_PR_in_RAT_got] WITH SCHEMABINDING AS
SELECT
    tie.Metadata_AC_part_PR_in_RAT_got,
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    [RAT_got].RAT_Rating AS got_RAT_Rating,
    [RAT_got].Metadata_RAT AS got_Metadata_RAT,
    tie.RAT_ID_got
FROM
    [dbo].[AC_part_PR_in_RAT_got] tie
LEFT JOIN
    [dbo].[RAT_Rating] [RAT_got]
ON
    [RAT_got].RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt = (
        SELECT
            max(sub.AC_part_PR_in_RAT_got_ChangedAt)
        FROM
            [dbo].[AC_part_PR_in_RAT_got] sub
        WHERE
            sub.AC_ID_part = tie.AC_ID_part
        AND
            sub.PR_ID_in = tie.PR_ID_in
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_part_PR_in_RAT_got viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pAC_part_PR_in_RAT_got] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.Metadata_AC_part_PR_in_RAT_got,
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    [RAT_got].RAT_Rating AS got_RAT_Rating,
    [RAT_got].Metadata_RAT AS got_Metadata_RAT,
    tie.RAT_ID_got
FROM
    [dbo].[AC_part_PR_in_RAT_got] tie
LEFT JOIN
    [dbo].[RAT_Rating] [RAT_got]
ON
    [RAT_got].RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt = (
        SELECT
            max(sub.AC_part_PR_in_RAT_got_ChangedAt)
        FROM
            [dbo].[AC_part_PR_in_RAT_got] sub
        WHERE
            sub.AC_ID_part = tie.AC_ID_part
        AND
            sub.PR_ID_in = tie.PR_ID_in
        AND
            sub.AC_part_PR_in_RAT_got_ChangedAt <= @changingTimepoint
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_part_PR_in_RAT_got viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nAC_part_PR_in_RAT_got]
AS
SELECT
    *
FROM
    [dbo].[pAC_part_PR_in_RAT_got](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dAC_part_PR_in_RAT_got showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dAC_part_PR_in_RAT_got] (
    @intervalStart datetime2(7),
    @intervalEnd datetime2(7)
)
RETURNS TABLE AS RETURN
SELECT
    tie.Metadata_AC_part_PR_in_RAT_got,
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    [RAT_got].RAT_Rating AS got_RAT_Rating,
    [RAT_got].Metadata_RAT AS got_Metadata_RAT,
    tie.RAT_ID_got
FROM
    [dbo].[AC_part_PR_in_RAT_got] tie
LEFT JOIN
    [dbo].[RAT_Rating] [RAT_got]
ON
    [RAT_got].RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dST_at_PR_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dST_at_PR_isPlaying];
IF Object_ID('dbo.nST_at_PR_isPlaying', 'V') IS NOT NULL
DROP VIEW [dbo].[nST_at_PR_isPlaying];
IF Object_ID('dbo.pST_at_PR_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pST_at_PR_isPlaying];
IF Object_ID('dbo.lST_at_PR_isPlaying', 'V') IS NOT NULL
DROP VIEW [dbo].[lST_at_PR_isPlaying];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lST_at_PR_isPlaying viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lST_at_PR_isPlaying] WITH SCHEMABINDING AS
SELECT
    tie.Metadata_ST_at_PR_isPlaying,
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    [dbo].[ST_at_PR_isPlaying] tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt = (
        SELECT
            max(sub.ST_at_PR_isPlaying_ChangedAt)
        FROM
            [dbo].[ST_at_PR_isPlaying] sub
        WHERE
            sub.ST_ID_at = tie.ST_ID_at
        AND
            sub.PR_ID_isPlaying = tie.PR_ID_isPlaying
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pST_at_PR_isPlaying viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pST_at_PR_isPlaying] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.Metadata_ST_at_PR_isPlaying,
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    [dbo].[ST_at_PR_isPlaying] tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt = (
        SELECT
            max(sub.ST_at_PR_isPlaying_ChangedAt)
        FROM
            [dbo].[ST_at_PR_isPlaying] sub
        WHERE
            sub.ST_ID_at = tie.ST_ID_at
        AND
            sub.PR_ID_isPlaying = tie.PR_ID_isPlaying
        AND
            sub.ST_at_PR_isPlaying_ChangedAt <= @changingTimepoint
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nST_at_PR_isPlaying viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nST_at_PR_isPlaying]
AS
SELECT
    *
FROM
    [dbo].[pST_at_PR_isPlaying](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dST_at_PR_isPlaying showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dST_at_PR_isPlaying] (
    @intervalStart datetime2(7),
    @intervalEnd datetime2(7)
)
RETURNS TABLE AS RETURN
SELECT
    tie.Metadata_ST_at_PR_isPlaying,
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    [dbo].[ST_at_PR_isPlaying] tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dAC_parent_AC_child_PAT_having', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dAC_parent_AC_child_PAT_having];
IF Object_ID('dbo.nAC_parent_AC_child_PAT_having', 'V') IS NOT NULL
DROP VIEW [dbo].[nAC_parent_AC_child_PAT_having];
IF Object_ID('dbo.pAC_parent_AC_child_PAT_having', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pAC_parent_AC_child_PAT_having];
IF Object_ID('dbo.lAC_parent_AC_child_PAT_having', 'V') IS NOT NULL
DROP VIEW [dbo].[lAC_parent_AC_child_PAT_having];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_parent_AC_child_PAT_having viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lAC_parent_AC_child_PAT_having] WITH SCHEMABINDING AS
SELECT
    tie.Metadata_AC_parent_AC_child_PAT_having,
    tie.AC_ID_parent,
    tie.AC_ID_child,
    [PAT_having].PAT_ParentalType AS having_PAT_ParentalType,
    [PAT_having].Metadata_PAT AS having_Metadata_PAT,
    tie.PAT_ID_having
FROM
    [dbo].[AC_parent_AC_child_PAT_having] tie
LEFT JOIN
    [dbo].[PAT_ParentalType] [PAT_having]
ON
    [PAT_having].PAT_ID = tie.PAT_ID_having;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_parent_AC_child_PAT_having viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pAC_parent_AC_child_PAT_having] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.Metadata_AC_parent_AC_child_PAT_having,
    tie.AC_ID_parent,
    tie.AC_ID_child,
    [PAT_having].PAT_ParentalType AS having_PAT_ParentalType,
    [PAT_having].Metadata_PAT AS having_Metadata_PAT,
    tie.PAT_ID_having
FROM
    [dbo].[AC_parent_AC_child_PAT_having] tie
LEFT JOIN
    [dbo].[PAT_ParentalType] [PAT_having]
ON
    [PAT_having].PAT_ID = tie.PAT_ID_having;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_parent_AC_child_PAT_having viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nAC_parent_AC_child_PAT_having]
AS
SELECT
    *
FROM
    [dbo].[pAC_parent_AC_child_PAT_having](sysdatetime());
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dPR_content_ST_location_PE_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dPR_content_ST_location_PE_of];
IF Object_ID('dbo.nPR_content_ST_location_PE_of', 'V') IS NOT NULL
DROP VIEW [dbo].[nPR_content_ST_location_PE_of];
IF Object_ID('dbo.pPR_content_ST_location_PE_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pPR_content_ST_location_PE_of];
IF Object_ID('dbo.lPR_content_ST_location_PE_of', 'V') IS NOT NULL
DROP VIEW [dbo].[lPR_content_ST_location_PE_of];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lPR_content_ST_location_PE_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lPR_content_ST_location_PE_of] WITH SCHEMABINDING AS
SELECT
    tie.Metadata_PR_content_ST_location_PE_of,
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.PE_ID_of
FROM
    [dbo].[PR_content_ST_location_PE_of] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pPR_content_ST_location_PE_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pPR_content_ST_location_PE_of] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.Metadata_PR_content_ST_location_PE_of,
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.PE_ID_of
FROM
    [dbo].[PR_content_ST_location_PE_of] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nPR_content_ST_location_PE_of viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nPR_content_ST_location_PE_of]
AS
SELECT
    *
FROM
    [dbo].[pPR_content_ST_location_PE_of](sysdatetime());
GO
-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent ties, only changes that represent values different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_exclusive_AC_with_ONG_currently instead of INSERT trigger on AC_exclusive_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_AC_exclusive_AC_with_ONG_currently', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_exclusive_AC_with_ONG_currently];
GO
CREATE TRIGGER [dbo].[it_AC_exclusive_AC_with_ONG_currently] ON [dbo].[AC_exclusive_AC_with_ONG_currently]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @inserted TABLE (
        Metadata_AC_exclusive_AC_with_ONG_currently int not null,
        AC_exclusive_AC_with_ONG_currently_StatementType char(1) not null,
        AC_exclusive_AC_with_ONG_currently_ChangedAt datetime not null,
        AC_ID_exclusive int not null,
        AC_ID_with int not null,
        ONG_ID_currently tinyint not null,
        primary key (
            AC_ID_exclusive asc,
            AC_ID_with asc,
            ONG_ID_currently asc,
            AC_exclusive_AC_with_ONG_currently_ChangedAt desc
        )
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_AC_exclusive_AC_with_ONG_currently, 0),
        'P', -- new posit
        ISNULL(i.AC_exclusive_AC_with_ONG_currently_ChangedAt, @now),
        i.AC_ID_exclusive,
        i.AC_ID_with,
        i.ONG_ID_currently
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            [dbo].[AC_exclusive_AC_with_ONG_currently] x
        WHERE 
            x.AC_ID_exclusive = i.AC_ID_exclusive
        AND
            x.AC_ID_with = i.AC_ID_with
        AND
            x.ONG_ID_currently = i.ONG_ID_currently
        AND
            x.AC_exclusive_AC_with_ONG_currently_ChangedAt = i.AC_exclusive_AC_with_ONG_currently_ChangedAt
    );
    INSERT INTO [dbo].[AC_exclusive_AC_with_ONG_currently] (
        Metadata_AC_exclusive_AC_with_ONG_currently, 
        AC_exclusive_AC_with_ONG_currently_ChangedAt,
        AC_ID_exclusive,
        AC_ID_with,
        ONG_ID_currently
    )
    SELECT
        Metadata_AC_exclusive_AC_with_ONG_currently,
        AC_exclusive_AC_with_ONG_currently_ChangedAt,
        AC_ID_exclusive,
        AC_ID_with,
        ONG_ID_currently
    FROM
        @inserted
    WHERE
        AC_exclusive_AC_with_ONG_currently_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_exclusive_AC_with_ONG_currently instead of INSERT trigger on lAC_exclusive_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lAC_exclusive_AC_with_ONG_currently] ON [dbo].[lAC_exclusive_AC_with_ONG_currently]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_exclusive_AC_with_ONG_currently] (
        Metadata_AC_exclusive_AC_with_ONG_currently,
        AC_exclusive_AC_with_ONG_currently_ChangedAt,
        AC_ID_exclusive,
        AC_ID_with,
        ONG_ID_currently
    )
    SELECT
        i.Metadata_AC_exclusive_AC_with_ONG_currently,
        i.AC_exclusive_AC_with_ONG_currently_ChangedAt,
        i.AC_ID_exclusive,
        i.AC_ID_with,
        ISNULL(i.ONG_ID_currently, [ONG_currently].ONG_ID) 
    FROM
        inserted i
    LEFT JOIN
        [dbo].[ONG_Ongoing] [ONG_currently]
    ON
        [ONG_currently].ONG_Ongoing = i.currently_ONG_Ongoing;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_exclusive_AC_with_ONG_currently instead of UPDATE trigger on lAC_exclusive_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lAC_exclusive_AC_with_ONG_currently] ON [dbo].[lAC_exclusive_AC_with_ONG_currently]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_exclusive_AC_with_ONG_currently] (
        Metadata_AC_exclusive_AC_with_ONG_currently,
        AC_exclusive_AC_with_ONG_currently_ChangedAt,
        AC_ID_exclusive,
        AC_ID_with,
        ONG_ID_currently
    )
    SELECT
        i.Metadata_AC_exclusive_AC_with_ONG_currently,
        cast(CASE WHEN UPDATE(AC_exclusive_AC_with_ONG_currently_ChangedAt) THEN i.AC_exclusive_AC_with_ONG_currently_ChangedAt ELSE @now END as datetime),
        i.AC_ID_exclusive,
        i.AC_ID_with,
        CASE WHEN UPDATE(currently_ONG_Ongoing) THEN [ONG_currently].ONG_ID ELSE i.ONG_ID_currently END 
    FROM
        inserted i
    LEFT JOIN
        [dbo].[ONG_Ongoing] [ONG_currently]
    ON
        [ONG_currently].ONG_Ongoing = i.currently_ONG_Ongoing; 
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_exclusive_AC_with_ONG_currently instead of DELETE trigger on lAC_exclusive_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lAC_exclusive_AC_with_ONG_currently] ON [dbo].[lAC_exclusive_AC_with_ONG_currently]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [dbo].[AC_exclusive_AC_with_ONG_currently] tie
    JOIN
        deleted d
    ON
        d.AC_exclusive_AC_with_ONG_currently_ChangedAt = tie.AC_exclusive_AC_with_ONG_currently_ChangedAt
    AND
       (
            d.AC_ID_exclusive = tie.AC_ID_exclusive
        AND
            d.AC_ID_with = tie.AC_ID_with
        AND
            d.ONG_ID_currently = tie.ONG_ID_currently
       );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPE_wasHeld_ST_at instead of INSERT trigger on lPE_wasHeld_ST_at
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lPE_wasHeld_ST_at] ON [dbo].[lPE_wasHeld_ST_at]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    INSERT INTO [dbo].[PE_wasHeld_ST_at] (
        Metadata_PE_wasHeld_ST_at,
        PE_ID_wasHeld,
        ST_ID_at
    )
    SELECT
        i.Metadata_PE_wasHeld_ST_at,
        i.PE_ID_wasHeld,
        i.ST_ID_at
    FROM
        inserted i;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPE_wasHeld_ST_at instead of UPDATE trigger on lPE_wasHeld_ST_at
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lPE_wasHeld_ST_at] ON [dbo].[lPE_wasHeld_ST_at]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(PE_ID_wasHeld))
        RAISERROR('The identity column PE_ID_wasHeld is not updatable.', 16, 1);
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPE_wasHeld_ST_at instead of DELETE trigger on lPE_wasHeld_ST_at
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lPE_wasHeld_ST_at] ON [dbo].[lPE_wasHeld_ST_at]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [dbo].[PE_wasHeld_ST_at] tie
    JOIN
        deleted d
    ON
        d.PE_ID_wasHeld = tie.PE_ID_wasHeld;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_subset_PN_of instead of INSERT trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lAC_subset_PN_of] ON [dbo].[lAC_subset_PN_of]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_subset_PN_of] (
        Metadata_AC_subset_PN_of,
        AC_ID_subset,
        PN_ID_of
    )
    SELECT
        i.Metadata_AC_subset_PN_of,
        i.AC_ID_subset,
        i.PN_ID_of
    FROM
        inserted i;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_subset_PN_of instead of UPDATE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lAC_subset_PN_of] ON [dbo].[lAC_subset_PN_of]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_subset_PN_of instead of DELETE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lAC_subset_PN_of] ON [dbo].[lAC_subset_PN_of]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [dbo].[AC_subset_PN_of] tie
    JOIN
        deleted d
    ON
       (
            d.AC_ID_subset = tie.AC_ID_subset
        AND
            d.PN_ID_of = tie.PN_ID_of
       );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPE_at_PR_wasPlayed instead of INSERT trigger on lPE_at_PR_wasPlayed
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lPE_at_PR_wasPlayed] ON [dbo].[lPE_at_PR_wasPlayed]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    INSERT INTO [dbo].[PE_at_PR_wasPlayed] (
        Metadata_PE_at_PR_wasPlayed,
        PE_ID_at,
        PR_ID_wasPlayed
    )
    SELECT
        i.Metadata_PE_at_PR_wasPlayed,
        i.PE_ID_at,
        i.PR_ID_wasPlayed
    FROM
        inserted i;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPE_at_PR_wasPlayed instead of UPDATE trigger on lPE_at_PR_wasPlayed
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lPE_at_PR_wasPlayed] ON [dbo].[lPE_at_PR_wasPlayed]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(PE_ID_at))
        RAISERROR('The identity column PE_ID_at is not updatable.', 16, 1);
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPE_at_PR_wasPlayed instead of DELETE trigger on lPE_at_PR_wasPlayed
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lPE_at_PR_wasPlayed] ON [dbo].[lPE_at_PR_wasPlayed]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [dbo].[PE_at_PR_wasPlayed] tie
    JOIN
        deleted d
    ON
        d.PE_ID_at = tie.PE_ID_at;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPE_in_AC_wasCast instead of INSERT trigger on lPE_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lPE_in_AC_wasCast] ON [dbo].[lPE_in_AC_wasCast]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    INSERT INTO [dbo].[PE_in_AC_wasCast] (
        Metadata_PE_in_AC_wasCast,
        PE_ID_in,
        AC_ID_wasCast
    )
    SELECT
        i.Metadata_PE_in_AC_wasCast,
        i.PE_ID_in,
        i.AC_ID_wasCast
    FROM
        inserted i;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPE_in_AC_wasCast instead of DELETE trigger on lPE_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lPE_in_AC_wasCast] ON [dbo].[lPE_in_AC_wasCast]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [dbo].[PE_in_AC_wasCast] tie
    JOIN
        deleted d
    ON
        d.PE_ID_in = tie.PE_ID_in
    AND
        d.AC_ID_wasCast = tie.AC_ID_wasCast;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_part_PR_in_RAT_got instead of INSERT trigger on AC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_AC_part_PR_in_RAT_got', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_part_PR_in_RAT_got];
GO
CREATE TRIGGER [dbo].[it_AC_part_PR_in_RAT_got] ON [dbo].[AC_part_PR_in_RAT_got]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @inserted TABLE (
        Metadata_AC_part_PR_in_RAT_got int not null,
        AC_part_PR_in_RAT_got_StatementType char(1) not null,
        AC_part_PR_in_RAT_got_ChangedAt datetime not null,
        AC_ID_part int not null,
        PR_ID_in int not null,
        RAT_ID_got tinyint not null,
        primary key (
            AC_ID_part asc,
            PR_ID_in asc,
            AC_part_PR_in_RAT_got_ChangedAt desc
        )
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_AC_part_PR_in_RAT_got, 0),
        'P', -- new posit
        ISNULL(i.AC_part_PR_in_RAT_got_ChangedAt, @now),
        i.AC_ID_part,
        i.PR_ID_in,
        i.RAT_ID_got
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            [dbo].[AC_part_PR_in_RAT_got] x
        WHERE 
            x.AC_ID_part = i.AC_ID_part
        AND
            x.PR_ID_in = i.PR_ID_in
        AND
            x.RAT_ID_got = i.RAT_ID_got
        AND
            x.AC_part_PR_in_RAT_got_ChangedAt = i.AC_part_PR_in_RAT_got_ChangedAt
    );
    INSERT INTO [dbo].[AC_part_PR_in_RAT_got] (
        Metadata_AC_part_PR_in_RAT_got, 
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got
    )
    SELECT
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got
    FROM
        @inserted
    WHERE
        AC_part_PR_in_RAT_got_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_part_PR_in_RAT_got instead of INSERT trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lAC_part_PR_in_RAT_got] ON [dbo].[lAC_part_PR_in_RAT_got]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_part_PR_in_RAT_got] (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got
    )
    SELECT
        i.Metadata_AC_part_PR_in_RAT_got,
        i.AC_part_PR_in_RAT_got_ChangedAt,
        i.AC_ID_part,
        i.PR_ID_in,
        ISNULL(i.RAT_ID_got, [RAT_got].RAT_ID) 
    FROM
        inserted i
    LEFT JOIN
        [dbo].[RAT_Rating] [RAT_got]
    ON
        [RAT_got].RAT_Rating = i.got_RAT_Rating;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_part_PR_in_RAT_got instead of UPDATE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lAC_part_PR_in_RAT_got] ON [dbo].[lAC_part_PR_in_RAT_got]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(AC_ID_part))
        RAISERROR('The identity column AC_ID_part is not updatable.', 16, 1);
    IF(UPDATE(PR_ID_in))
        RAISERROR('The identity column PR_ID_in is not updatable.', 16, 1);
    INSERT INTO [dbo].[AC_part_PR_in_RAT_got] (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got
    )
    SELECT
        i.Metadata_AC_part_PR_in_RAT_got,
        cast(CASE WHEN UPDATE(AC_part_PR_in_RAT_got_ChangedAt) THEN i.AC_part_PR_in_RAT_got_ChangedAt ELSE @now END as datetime),
        i.AC_ID_part,
        i.PR_ID_in,
        CASE WHEN UPDATE(got_RAT_Rating) THEN [RAT_got].RAT_ID ELSE i.RAT_ID_got END 
    FROM
        inserted i
    LEFT JOIN
        [dbo].[RAT_Rating] [RAT_got]
    ON
        [RAT_got].RAT_Rating = i.got_RAT_Rating; 
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_part_PR_in_RAT_got instead of DELETE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lAC_part_PR_in_RAT_got] ON [dbo].[lAC_part_PR_in_RAT_got]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [dbo].[AC_part_PR_in_RAT_got] tie
    JOIN
        deleted d
    ON
        d.AC_part_PR_in_RAT_got_ChangedAt = tie.AC_part_PR_in_RAT_got_ChangedAt
    AND
        d.AC_ID_part = tie.AC_ID_part
    AND
        d.PR_ID_in = tie.PR_ID_in;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itST_at_PR_isPlaying instead of INSERT trigger on ST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_at_PR_isPlaying', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_at_PR_isPlaying];
GO
CREATE TRIGGER [dbo].[it_ST_at_PR_isPlaying] ON [dbo].[ST_at_PR_isPlaying]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @inserted TABLE (
        Metadata_ST_at_PR_isPlaying int not null,
        ST_at_PR_isPlaying_StatementType char(1) not null,
        ST_at_PR_isPlaying_ChangedAt datetime not null,
        ST_ID_at int not null,
        PR_ID_isPlaying int not null,
        primary key (
            ST_ID_at asc,
            PR_ID_isPlaying asc,
            ST_at_PR_isPlaying_ChangedAt desc
        )
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_ST_at_PR_isPlaying, 0),
        'P', -- new posit
        ISNULL(i.ST_at_PR_isPlaying_ChangedAt, @now),
        i.ST_ID_at,
        i.PR_ID_isPlaying
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            [dbo].[ST_at_PR_isPlaying] x
        WHERE 
            x.ST_ID_at = i.ST_ID_at
        AND
            x.PR_ID_isPlaying = i.PR_ID_isPlaying
        AND
            x.ST_at_PR_isPlaying_ChangedAt = i.ST_at_PR_isPlaying_ChangedAt
    );
    INSERT INTO [dbo].[ST_at_PR_isPlaying] (
        Metadata_ST_at_PR_isPlaying, 
        ST_at_PR_isPlaying_ChangedAt,
        ST_ID_at,
        PR_ID_isPlaying
    )
    SELECT
        Metadata_ST_at_PR_isPlaying,
        ST_at_PR_isPlaying_ChangedAt,
        ST_ID_at,
        PR_ID_isPlaying
    FROM
        @inserted
    WHERE
        ST_at_PR_isPlaying_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_at_PR_isPlaying instead of INSERT trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lST_at_PR_isPlaying] ON [dbo].[lST_at_PR_isPlaying]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    INSERT INTO [dbo].[ST_at_PR_isPlaying] (
        Metadata_ST_at_PR_isPlaying,
        ST_at_PR_isPlaying_ChangedAt,
        ST_ID_at,
        PR_ID_isPlaying
    )
    SELECT
        i.Metadata_ST_at_PR_isPlaying,
        i.ST_at_PR_isPlaying_ChangedAt,
        i.ST_ID_at,
        i.PR_ID_isPlaying
    FROM
        inserted i;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_at_PR_isPlaying instead of DELETE trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lST_at_PR_isPlaying] ON [dbo].[lST_at_PR_isPlaying]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [dbo].[ST_at_PR_isPlaying] tie
    JOIN
        deleted d
    ON
        d.ST_at_PR_isPlaying_ChangedAt = tie.ST_at_PR_isPlaying_ChangedAt
    AND
        d.ST_ID_at = tie.ST_ID_at
    AND
        d.PR_ID_isPlaying = tie.PR_ID_isPlaying;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_parent_AC_child_PAT_having instead of INSERT trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lAC_parent_AC_child_PAT_having] ON [dbo].[lAC_parent_AC_child_PAT_having]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_parent_AC_child_PAT_having] (
        Metadata_AC_parent_AC_child_PAT_having,
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having
    )
    SELECT
        i.Metadata_AC_parent_AC_child_PAT_having,
        i.AC_ID_parent,
        i.AC_ID_child,
        ISNULL(i.PAT_ID_having, [PAT_having].PAT_ID) 
    FROM
        inserted i
    LEFT JOIN
        [dbo].[PAT_ParentalType] [PAT_having]
    ON
        [PAT_having].PAT_ParentalType = i.having_PAT_ParentalType;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_parent_AC_child_PAT_having instead of DELETE trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lAC_parent_AC_child_PAT_having] ON [dbo].[lAC_parent_AC_child_PAT_having]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [dbo].[AC_parent_AC_child_PAT_having] tie
    JOIN
        deleted d
    ON
        d.AC_ID_parent = tie.AC_ID_parent
    AND
        d.AC_ID_child = tie.AC_ID_child
    AND
        d.PAT_ID_having = tie.PAT_ID_having;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_content_ST_location_PE_of instead of INSERT trigger on lPR_content_ST_location_PE_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lPR_content_ST_location_PE_of] ON [dbo].[lPR_content_ST_location_PE_of]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    INSERT INTO [dbo].[PR_content_ST_location_PE_of] (
        Metadata_PR_content_ST_location_PE_of,
        PR_ID_content,
        ST_ID_location,
        PE_ID_of
    )
    SELECT
        i.Metadata_PR_content_ST_location_PE_of,
        i.PR_ID_content,
        i.ST_ID_location,
        i.PE_ID_of
    FROM
        inserted i;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_content_ST_location_PE_of instead of UPDATE trigger on lPR_content_ST_location_PE_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lPR_content_ST_location_PE_of] ON [dbo].[lPR_content_ST_location_PE_of]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(PE_ID_of))
        RAISERROR('The identity column PE_ID_of is not updatable.', 16, 1);
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_content_ST_location_PE_of instead of DELETE trigger on lPR_content_ST_location_PE_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lPR_content_ST_location_PE_of] ON [dbo].[lPR_content_ST_location_PE_of]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [dbo].[PR_content_ST_location_PE_of] tie
    JOIN
        deleted d
    ON
        d.PE_ID_of = tie.PE_ID_of;
END
GO
-- SCHEMA EVOLUTION ---------------------------------------------------------------------------------------------------
--
-- The following tables, views, and functions are used to track schema changes
-- over time, as well as providing every XML that has been 'executed' against
-- the database.
--
-- Schema table -------------------------------------------------------------------------------------------------------
-- The schema table holds every xml that has been executed against the database
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Schema', 'U') IS NULL
   CREATE TABLE [dbo].[_Schema] (
      [version] int identity(1, 1) not null,
      [activation] datetime2(7) not null,
      [schema] xml not null,
      constraint pk_Schema primary key (
         [version]
      )
   );
GO
-- Insert the XML schema (as of now)
INSERT INTO [dbo].[_Schema] (
   [activation],
   [schema]
)
SELECT
   current_timestamp,
   N'<schema format="0.99.16" date="2026-01-20" time="09:42:48"><metadata changingRange="datetime" encapsulation="dbo" identity="int" metadataPrefix="Metadata" metadataType="int" metadataUsage="true" changingSuffix="ChangedAt" identitySuffix="ID" positIdentity="int" positGenerator="true" positingRange="datetime" positingSuffix="PositedAt" positorRange="tinyint" positorSuffix="Positor" reliabilityRange="decimal(5,2)" reliabilitySuffix="Reliability" defaultReliability="1" deleteReliability="0" assertionSuffix="Assertion" partitioning="false" entityIntegrity="true" restatability="true" idempotency="false" assertiveness="true" naming="improved" positSuffix="Posit" annexSuffix="Annex" chronon="datetime2(7)" now="sysdatetime()" dummySuffix="Dummy" versionSuffix="Version" statementTypeSuffix="StatementType" checksumSuffix="Checksum" businessViews="false" decisiveness="true" equivalence="false" equivalentSuffix="EQ" equivalentRange="tinyint" databaseTarget="SQLServer" temporalization="uni" deletability="false" deletablePrefix="Deletable" deletionSuffix="Deleted" privacy="Ignore" checksum="false" triggers="true" knotAliases="false"/><knot mnemonic="PAT" descriptor="ParentalType" identity="tinyint" dataRange="varchar(42)"><metadata capsule="dbo" generator="false"/><layout x="91.54" y="310.36" fixed="false"/></knot><knot mnemonic="GEN" descriptor="Gender" identity="bit" dataRange="varchar(42)"><metadata capsule="dbo" generator="false"/><layout x="166.59" y="153.03" fixed="false"/></knot><knot mnemonic="PLV" descriptor="ProfessionalLevel" identity="tinyint" dataRange="varchar(max)"><metadata capsule="dbo" generator="false" checksum="true"/><layout x="319.10" y="38.99" fixed="false"/></knot><knot mnemonic="UTL" descriptor="Utilization" identity="tinyint" dataRange="tinyint"><metadata capsule="dbo" generator="false"/><layout x="588.70" y="688.14" fixed="false"/></knot><knot mnemonic="ONG" descriptor="Ongoing" identity="tinyint" dataRange="varchar(3)"><metadata capsule="dbo" generator="false"/><layout x="419.33" y="114.13" fixed="false"/></knot><knot mnemonic="RAT" descriptor="Rating" identity="tinyint" dataRange="varchar(42)"><metadata capsule="dbo" generator="false"/><layout x="512.55" y="106.64" fixed="false"/></knot><anchor mnemonic="PE" descriptor="Performance" identity="int"><metadata capsule="dbo" generator="true"/><attribute mnemonic="DAT" descriptor="Date" dataRange="datetime"><metadata privacy="Ignore" capsule="dbo" idempotent="false" deletable="false"/><key stop="1" route="1st" of="PE" branch="1"/><layout x="832.94" y="517.86" fixed="false"/></attribute><attribute mnemonic="AUD" descriptor="Audience" dataRange="int"><metadata privacy="Ignore" capsule="dbo" idempotent="false" deletable="false"/><layout x="915.56" y="451.85" fixed="false"/></attribute><attribute mnemonic="REV" descriptor="Revenue" dataRange="money"><metadata privacy="Ignore" capsule="dbo" idempotent="false" deletable="false"/><layout x="900.90" y="493.09" fixed="false"/></attribute><layout x="820.28" y="431.86" fixed="false"/></anchor><anchor mnemonic="PN" descriptor="Person" identity="int"><metadata capsule="dbo" generator="true"/><layout x="231.72" y="456.13" fixed="false"/></anchor><anchor mnemonic="ST" descriptor="Stage" identity="int"><metadata capsule="dbo" generator="true"/><attribute mnemonic="NAM" descriptor="Name" timeRange="datetime" dataRange="varchar(42)"><metadata privacy="Ignore" capsule="dbo" restatable="true" idempotent="false" deletable="false"/><key stop="1" route="2nd" of="ST" branch="1"/><layout x="693.38" y="530.60" fixed="false"/></attribute><attribute mnemonic="LOC" descriptor="Location" dataRange="geography"><metadata privacy="Ignore" capsule="dbo" checksum="true" idempotent="false" deletable="false"/><key stop="1" route="1st" of="ST" branch="1"/><key stop="4" route="1st" of="PE" branch="2"/><layout x="710.57" y="499.21" fixed="false"/></attribute><attribute mnemonic="AVG" descriptor="Average" timeRange="datetime" knotRange="UTL"><metadata privacy="Ignore" capsule="dbo" restatable="true" idempotent="false" deletable="false"/><layout x="633.26" y="605.63" fixed="false"/></attribute><attribute mnemonic="MIN" descriptor="Minimum" knotRange="UTL"><metadata privacy="Ignore" capsule="dbo" idempotent="false" deletable="false"/><layout x="596.00" y="571.60" fixed="false"/></attribute><layout x="670.04" y="451.57" fixed="false"/></anchor><anchor mnemonic="AC" descriptor="Actor" identity="int"><metadata capsule="dbo" generator="true"/><attribute mnemonic="NAM" descriptor="Name" timeRange="datetime" dataRange="varchar(42)"><metadata privacy="Ignore" capsule="dbo" restatable="true" idempotent="false" deletable="false"/><key stop="1" route="1st" of="AC" branch="1"/><layout x="315.56" y="342.16" fixed="false"/></attribute><attribute mnemonic="GEN" descriptor="Gender" knotRange="GEN"><metadata privacy="Ignore" capsule="dbo" idempotent="false" deletable="false"/><layout x="247.68" y="201.35" fixed="false"/></attribute><attribute mnemonic="PLV" descriptor="ProfessionalLevel" timeRange="datetime" knotRange="PLV"><metadata privacy="Ignore" capsule="dbo" restatable="true" idempotent="false" deletable="false"/><layout x="346.43" y="133.81" fixed="false"/></attribute><layout x="374.64" y="291.77" fixed="false"/></anchor><anchor mnemonic="PR" descriptor="Program" identity="int"><metadata capsule="dbo" generator="true"/><attribute mnemonic="NAM" descriptor="Name" dataRange="varchar(42)"><metadata privacy="Ignore" capsule="dbo" idempotent="false" deletable="false"/><key stop="1" route="1st" of="PR" branch="1"/><key stop="7" route="1st" of="PE" branch="3"/><layout x="796.60" y="61.24" fixed="false"/></attribute><layout x="769.35" y="165.46" fixed="false"/></anchor><tie timeRange="datetime"><anchorRole role="exclusive" type="AC" identifier="false"/><anchorRole role="with" type="AC" identifier="false"/><knotRole role="currently" type="ONG" identifier="false"/><metadata capsule="dbo" restatable="true" deletable="false" idempotent="false"/><layout x="404.68" y="199.65" fixed="false"/></tie><tie><anchorRole role="wasHeld" type="PE" identifier="true"><key stop="2" route="1st" of="PE" branch="2"/></anchorRole><anchorRole role="at" type="ST" identifier="false"><key stop="3" route="1st" of="PE" branch="2"/></anchorRole><metadata capsule="dbo" deletable="false" idempotent="false"/><layout x="779.05" y="495.02" fixed="false"/></tie><tie><anchorRole role="subset" type="AC" identifier="false"/><anchorRole role="of" type="PN" identifier="false"/><metadata capsule="dbo" deletable="false" idempotent="false"/><layout x="286.80" y="406.90" fixed="false"/></tie><tie><anchorRole role="at" type="PE" identifier="true"><key stop="5" route="1st" of="PE" branch="3"/></anchorRole><anchorRole role="wasPlayed" type="PR" identifier="false"><key stop="6" route="1st" of="PE" branch="3"/></anchorRole><metadata capsule="dbo" deletable="false" idempotent="false"/><layout x="848.90" y="273.39" fixed="false"/></tie><tie><anchorRole role="in" type="PE" identifier="true"/><anchorRole role="wasCast" type="AC" identifier="true"/><metadata capsule="dbo" deletable="false" idempotent="false"/><layout x="592.24" y="364.28" fixed="false"/></tie><tie timeRange="datetime"><anchorRole role="part" type="AC" identifier="true"/><anchorRole role="in" type="PR" identifier="true"/><knotRole role="got" type="RAT" identifier="false"/><metadata capsule="dbo" restatable="true" deletable="false" idempotent="false"/><layout x="544.18" y="180.73" fixed="false"/></tie><tie timeRange="datetime"><anchorRole role="at" type="ST" identifier="true"/><anchorRole role="isPlaying" type="PR" identifier="true"/><metadata capsule="dbo" restatable="true" deletable="false" idempotent="false"/><layout x="716.29" y="295.31" fixed="false"/></tie><tie><anchorRole role="parent" type="AC" identifier="true"/><anchorRole role="child" type="AC" identifier="true"/><knotRole role="having" type="PAT" identifier="true"/><metadata capsule="dbo" deletable="false" idempotent="false"/><layout x="216.75" y="301.40" fixed="false"/></tie><tie><anchorRole role="content" type="PR" identifier="false"/><anchorRole role="location" type="ST" identifier="false"/><anchorRole role="of" type="PE" identifier="true"/><metadata capsule="dbo" deletable="false" idempotent="false"/><layout x="790.46" y="334.43" fixed="false"/></tie></schema>';
GO
-- Schema expanded view -----------------------------------------------------------------------------------------------
-- A view of the schema table that expands the XML attributes into columns
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Schema_Expanded', 'V') IS NOT NULL
DROP VIEW [dbo].[_Schema_Expanded]
GO
CREATE VIEW [dbo].[_Schema_Expanded]
AS
SELECT
	[version],
	[activation],
	[schema],
	[schema].value('schema[1]/@format', 'nvarchar(max)') as [format],
	[schema].value('schema[1]/@date', 'datetime') + [schema].value('schema[1]/@time', 'datetime') as [date],
	[schema].value('schema[1]/metadata[1]/@temporalization', 'nvarchar(max)') as [temporalization],
	[schema].value('schema[1]/metadata[1]/@databaseTarget', 'nvarchar(max)') as [databaseTarget],
	[schema].value('schema[1]/metadata[1]/@changingRange', 'nvarchar(max)') as [changingRange],
	[schema].value('schema[1]/metadata[1]/@encapsulation', 'nvarchar(max)') as [encapsulation],
	[schema].value('schema[1]/metadata[1]/@identity', 'nvarchar(max)') as [identity],
	[schema].value('schema[1]/metadata[1]/@metadataPrefix', 'nvarchar(max)') as [metadataPrefix],
	[schema].value('schema[1]/metadata[1]/@metadataType', 'nvarchar(max)') as [metadataType],
	[schema].value('schema[1]/metadata[1]/@metadataUsage', 'nvarchar(max)') as [metadataUsage],
	[schema].value('schema[1]/metadata[1]/@changingSuffix', 'nvarchar(max)') as [changingSuffix],
	[schema].value('schema[1]/metadata[1]/@identitySuffix', 'nvarchar(max)') as [identitySuffix],
	[schema].value('schema[1]/metadata[1]/@positIdentity', 'nvarchar(max)') as [positIdentity],
	[schema].value('schema[1]/metadata[1]/@positGenerator', 'nvarchar(max)') as [positGenerator],
	[schema].value('schema[1]/metadata[1]/@positingRange', 'nvarchar(max)') as [positingRange],
	[schema].value('schema[1]/metadata[1]/@positingSuffix', 'nvarchar(max)') as [positingSuffix],
	[schema].value('schema[1]/metadata[1]/@positorRange', 'nvarchar(max)') as [positorRange],
	[schema].value('schema[1]/metadata[1]/@positorSuffix', 'nvarchar(max)') as [positorSuffix],
	[schema].value('schema[1]/metadata[1]/@reliabilityRange', 'nvarchar(max)') as [reliabilityRange],
	[schema].value('schema[1]/metadata[1]/@reliabilitySuffix', 'nvarchar(max)') as [reliabilitySuffix],
	[schema].value('schema[1]/metadata[1]/@deleteReliability', 'nvarchar(max)') as [deleteReliability],
	[schema].value('schema[1]/metadata[1]/@assertionSuffix', 'nvarchar(max)') as [assertionSuffix],
	[schema].value('schema[1]/metadata[1]/@partitioning', 'nvarchar(max)') as [partitioning],
	[schema].value('schema[1]/metadata[1]/@entityIntegrity', 'nvarchar(max)') as [entityIntegrity],
	[schema].value('schema[1]/metadata[1]/@restatability', 'nvarchar(max)') as [restatability],
	[schema].value('schema[1]/metadata[1]/@idempotency', 'nvarchar(max)') as [idempotency],
	[schema].value('schema[1]/metadata[1]/@assertiveness', 'nvarchar(max)') as [assertiveness],
	[schema].value('schema[1]/metadata[1]/@naming', 'nvarchar(max)') as [naming],
	[schema].value('schema[1]/metadata[1]/@positSuffix', 'nvarchar(max)') as [positSuffix],
	[schema].value('schema[1]/metadata[1]/@annexSuffix', 'nvarchar(max)') as [annexSuffix],
	[schema].value('schema[1]/metadata[1]/@chronon', 'nvarchar(max)') as [chronon],
	[schema].value('schema[1]/metadata[1]/@now', 'nvarchar(max)') as [now],
	[schema].value('schema[1]/metadata[1]/@dummySuffix', 'nvarchar(max)') as [dummySuffix],
	[schema].value('schema[1]/metadata[1]/@statementTypeSuffix', 'nvarchar(max)') as [statementTypeSuffix],
	[schema].value('schema[1]/metadata[1]/@checksumSuffix', 'nvarchar(max)') as [checksumSuffix],
	[schema].value('schema[1]/metadata[1]/@businessViews', 'nvarchar(max)') as [businessViews],
	[schema].value('schema[1]/metadata[1]/@equivalence', 'nvarchar(max)') as [equivalence],
	[schema].value('schema[1]/metadata[1]/@equivalentSuffix', 'nvarchar(max)') as [equivalentSuffix],
	[schema].value('schema[1]/metadata[1]/@equivalentRange', 'nvarchar(max)') as [equivalentRange]
FROM
	_Schema;
GO
-- Anchor view --------------------------------------------------------------------------------------------------------
-- The anchor view shows information about all the anchors in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Anchor', 'V') IS NOT NULL
DROP VIEW [dbo].[_Anchor]
GO
CREATE VIEW [dbo].[_Anchor]
AS
SELECT
   S.version,
   S.activation,
   Nodeset.anchor.value('concat(@mnemonic, "_", @descriptor)', 'nvarchar(max)') as [name],
   Nodeset.anchor.value('metadata[1]/@capsule', 'nvarchar(max)') as [capsule],
   Nodeset.anchor.value('@mnemonic', 'nvarchar(max)') as [mnemonic],
   Nodeset.anchor.value('@descriptor', 'nvarchar(max)') as [descriptor],
   Nodeset.anchor.value('@identity', 'nvarchar(max)') as [identity],
   Nodeset.anchor.value('metadata[1]/@generator', 'nvarchar(max)') as [generator],
   Nodeset.anchor.value('count(attribute)', 'int') as [numberOfAttributes],
   Nodeset.anchor.value('description[1]/.', 'nvarchar(max)') as [description]
FROM
   [dbo].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/anchor') as Nodeset(anchor);
GO
-- Knot view ----------------------------------------------------------------------------------------------------------
-- The knot view shows information about all the knots in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Knot', 'V') IS NOT NULL
DROP VIEW [dbo].[_Knot]
GO
CREATE VIEW [dbo].[_Knot]
AS
SELECT
   S.version,
   S.activation,
   Nodeset.knot.value('concat(@mnemonic, "_", @descriptor)', 'nvarchar(max)') as [name],
   Nodeset.knot.value('metadata[1]/@capsule', 'nvarchar(max)') as [capsule],
   Nodeset.knot.value('@mnemonic', 'nvarchar(max)') as [mnemonic],
   Nodeset.knot.value('@descriptor', 'nvarchar(max)') as [descriptor],
   Nodeset.knot.value('@identity', 'nvarchar(max)') as [identity],
   Nodeset.knot.value('metadata[1]/@generator', 'nvarchar(max)') as [generator],
   Nodeset.knot.value('@dataRange', 'nvarchar(max)') as [dataRange],
   isnull(Nodeset.knot.value('metadata[1]/@checksum', 'nvarchar(max)'), 'false') as [checksum],
   isnull(Nodeset.knot.value('metadata[1]/@equivalent', 'nvarchar(max)'), 'false') as [equivalent],
   Nodeset.knot.value('description[1]/.', 'nvarchar(max)') as [description]
FROM
   [dbo].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/knot') as Nodeset(knot);
GO
-- Attribute view -----------------------------------------------------------------------------------------------------
-- The attribute view shows information about all the attributes in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Attribute', 'V') IS NOT NULL
DROP VIEW [dbo].[_Attribute]
GO
CREATE VIEW [dbo].[_Attribute]
AS
SELECT
   S.version,
   S.activation,
   ParentNodeset.anchor.value('concat(@mnemonic, "_")', 'nvarchar(max)') +
   Nodeset.attribute.value('concat(@mnemonic, "_")', 'nvarchar(max)') +
   ParentNodeset.anchor.value('concat(@descriptor, "_")', 'nvarchar(max)') +
   Nodeset.attribute.value('@descriptor', 'nvarchar(max)') as [name],
   Nodeset.attribute.value('metadata[1]/@capsule', 'nvarchar(max)') as [capsule],
   Nodeset.attribute.value('@mnemonic', 'nvarchar(max)') as [mnemonic],
   Nodeset.attribute.value('@descriptor', 'nvarchar(max)') as [descriptor],
   Nodeset.attribute.value('@identity', 'nvarchar(max)') as [identity],
   isnull(Nodeset.attribute.value('metadata[1]/@equivalent', 'nvarchar(max)'), 'false') as [equivalent],
   Nodeset.attribute.value('metadata[1]/@generator', 'nvarchar(max)') as [generator],
   Nodeset.attribute.value('metadata[1]/@assertive', 'nvarchar(max)') as [assertive],
   Nodeset.attribute.value('metadata[1]/@privacy', 'nvarchar(max)') as [privacy],
   isnull(Nodeset.attribute.value('metadata[1]/@checksum', 'nvarchar(max)'), 'false') as [checksum],
   Nodeset.attribute.value('metadata[1]/@restatable', 'nvarchar(max)') as [restatable],
   Nodeset.attribute.value('metadata[1]/@idempotent', 'nvarchar(max)') as [idempotent],
   ParentNodeset.anchor.value('@mnemonic', 'nvarchar(max)') as [anchorMnemonic],
   ParentNodeset.anchor.value('@descriptor', 'nvarchar(max)') as [anchorDescriptor],
   ParentNodeset.anchor.value('@identity', 'nvarchar(max)') as [anchorIdentity],
   Nodeset.attribute.value('@dataRange', 'nvarchar(max)') as [dataRange],
   Nodeset.attribute.value('@knotRange', 'nvarchar(max)') as [knotRange],
   Nodeset.attribute.value('@timeRange', 'nvarchar(max)') as [timeRange],
   Nodeset.attribute.value('metadata[1]/@deletable', 'nvarchar(max)') as [deletable],
   Nodeset.attribute.value('metadata[1]/@encryptionGroup', 'nvarchar(max)') as [encryptionGroup],
   Nodeset.attribute.value('description[1]/.', 'nvarchar(max)') as [description]
FROM
   [dbo].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/anchor') as ParentNodeset(anchor)
OUTER APPLY
   ParentNodeset.anchor.nodes('attribute') as Nodeset(attribute);
GO
-- Tie view -----------------------------------------------------------------------------------------------------------
-- The tie view shows information about all the ties in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Tie', 'V') IS NOT NULL
DROP VIEW [dbo].[_Tie]
GO
CREATE VIEW [dbo].[_Tie]
AS
SELECT
   S.version,
   S.activation,
   REPLACE(Nodeset.tie.query('
      for $role in *[local-name() = "anchorRole" or local-name() = "knotRole"]
      return concat($role/@type, "_", $role/@role)
   ').value('.', 'nvarchar(max)'), ' ', '_') as [name],
   Nodeset.tie.value('metadata[1]/@capsule', 'nvarchar(max)') as [capsule],
   Nodeset.tie.value('count(anchorRole) + count(knotRole)', 'int') as [numberOfRoles],
   Nodeset.tie.query('
      for $role in *[local-name() = "anchorRole" or local-name() = "knotRole"]
      return string($role/@role)
   ').value('.', 'nvarchar(max)') as [roles],
   Nodeset.tie.value('count(anchorRole)', 'int') as [numberOfAnchors],
   Nodeset.tie.query('
      for $role in anchorRole
      return string($role/@type)
   ').value('.', 'nvarchar(max)') as [anchors],
   Nodeset.tie.value('count(knotRole)', 'int') as [numberOfKnots],
   Nodeset.tie.query('
      for $role in knotRole
      return string($role/@type)
   ').value('.', 'nvarchar(max)') as [knots],
   Nodeset.tie.value('count(*[local-name() = "anchorRole" or local-name() = "knotRole"][@identifier = "true"])', 'int') as [numberOfIdentifiers],
   Nodeset.tie.query('
      for $role in *[local-name() = "anchorRole" or local-name() = "knotRole"][@identifier = "true"]
      return string($role/@type)
   ').value('.', 'nvarchar(max)') as [identifiers],
   Nodeset.tie.value('@timeRange', 'nvarchar(max)') as [timeRange],
   Nodeset.tie.value('metadata[1]/@generator', 'nvarchar(max)') as [generator],
   Nodeset.tie.value('metadata[1]/@assertive', 'nvarchar(max)') as [assertive],
   Nodeset.tie.value('metadata[1]/@restatable', 'nvarchar(max)') as [restatable],
   Nodeset.tie.value('metadata[1]/@idempotent', 'nvarchar(max)') as [idempotent],
   Nodeset.tie.value('description[1]/.', 'nvarchar(max)') as [description]
FROM
   [dbo].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/tie') as Nodeset(tie);
GO
-- Key view -----------------------------------------------------------------------------------------------------------
-- The key view shows information about all the keys in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Key', 'V') IS NOT NULL
DROP VIEW [dbo].[_Key]
GO
CREATE VIEW [dbo].[_Key]
AS
SELECT
   S.version,
   S.activation,
   Nodeset.keys.value('@of', 'nvarchar(max)') as [of],
   Nodeset.keys.value('@route', 'nvarchar(max)') as [route],
   Nodeset.keys.value('@stop', 'nvarchar(max)') as [stop],
   case [parent]
      when 'tie'
      then Nodeset.keys.value('../@role', 'nvarchar(max)')
   end as [role],
   case [parent]
      when 'knot'
      then Nodeset.keys.value('concat(../@mnemonic, "_")', 'nvarchar(max)') +
          Nodeset.keys.value('../@descriptor', 'nvarchar(max)') 
      when 'attribute'
      then Nodeset.keys.value('concat(../../@mnemonic, "_")', 'nvarchar(max)') +
          Nodeset.keys.value('concat(../@mnemonic, "_")', 'nvarchar(max)') +
          Nodeset.keys.value('concat(../../@descriptor, "_")', 'nvarchar(max)') +
          Nodeset.keys.value('../@descriptor', 'nvarchar(max)') 
      when 'tie'
      then REPLACE(Nodeset.keys.query('
            for $role in ../../*[local-name() = "anchorRole" or local-name() = "knotRole"]
            return concat($role/@type, "_", $role/@role)
          ').value('.', 'nvarchar(max)'), ' ', '_')
   end as [in],
   [parent]
FROM
   [dbo].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema//key') as Nodeset(keys)
CROSS APPLY (
   VALUES (
      case
         when Nodeset.keys.value('local-name(..)', 'nvarchar(max)') in ('anchorRole', 'knotRole')
         then 'tie'
         else Nodeset.keys.value('local-name(..)', 'nvarchar(max)')
      end 
   )
) p ([parent]);
GO
-- Evolution function -------------------------------------------------------------------------------------------------
-- The evolution function shows what the schema looked like at the given
-- point in time with additional information about missing or added
-- modeling components since that time.
--
-- @timepoint The point in time to which you would like to travel.
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._Evolution', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[_Evolution];
GO
CREATE FUNCTION [dbo].[_Evolution] (
    @timepoint AS datetime2(7)
)
RETURNS TABLE AS
RETURN
WITH constructs AS (
   SELECT
      temporalization,
      [capsule] + '.' + [name] + s.suffix AS [qualifiedName],
      [version],
      [activation]
   FROM 
      [dbo].[_Anchor] a
   CROSS APPLY (
      VALUES ('uni', ''), ('crt', '')
   ) s (temporalization, suffix)
   UNION ALL
   SELECT
      temporalization,
      [capsule] + '.' + [name] + s.suffix AS [qualifiedName],
      [version],
      [activation]
   FROM
      [dbo].[_Knot] k
   CROSS APPLY (
      VALUES ('uni', ''), ('crt', '')
   ) s (temporalization, suffix)
   UNION ALL
   SELECT
      temporalization,
      [capsule] + '.' + [name] + s.suffix AS [qualifiedName],
      [version],
      [activation]
   FROM
      [dbo].[_Attribute] b
   CROSS APPLY (
      VALUES ('uni', ''), ('crt', '_Annex'), ('crt', '_Posit')
   ) s (temporalization, suffix)
   UNION ALL
   SELECT
      temporalization,
      [capsule] + '.' + [name] + s.suffix AS [qualifiedName],
      [version],
      [activation]
   FROM
      [dbo].[_Tie] t
   CROSS APPLY (
      VALUES ('uni', ''), ('crt', '_Annex'), ('crt', '_Posit')
   ) s (temporalization, suffix)
), 
selectedSchema AS (
   SELECT TOP 1
      *
   FROM
      [dbo].[_Schema_Expanded]
   WHERE
      [activation] <= @timepoint
   ORDER BY
      [activation] DESC
),
presentConstructs AS (
   SELECT
      C.*
   FROM
      selectedSchema S
   JOIN
      constructs C
   ON
      S.[version] = C.[version]
   AND
      S.temporalization = C.temporalization 
), 
allConstructs AS (
   SELECT
      C.*
   FROM
      selectedSchema S
   JOIN
      constructs C
   ON
      S.temporalization = C.temporalization
)
SELECT
   COALESCE(P.[version], X.[version]) as [version],
   COALESCE(P.[qualifiedName], T.[qualifiedName]) AS [name],
   COALESCE(P.[activation], X.[activation], T.[create_date]) AS [activation],
   CASE
      WHEN P.[activation] = S.[activation] THEN 'Present'
      WHEN X.[activation] > S.[activation] THEN 'Future'
      WHEN X.[activation] < S.[activation] THEN 'Past'
      ELSE 'Missing'
   END AS Existence
FROM 
   presentConstructs P
FULL OUTER JOIN (
   SELECT 
      s.[name] + '.' + t.[name] AS [qualifiedName],
      t.[create_date]
   FROM 
      sys.tables t
   JOIN
      sys.schemas s
   ON
      s.schema_id = t.schema_id
   WHERE
      t.[type] = 'U'
   AND
      LEFT(t.[name], 1) <> '_'
) T
ON
   T.[qualifiedName] = P.[qualifiedName]
LEFT JOIN
   allConstructs X
ON
   X.[qualifiedName] = T.[qualifiedName]
AND
   X.[activation] = (
      SELECT
         MIN(sub.[activation])
      FROM
         constructs sub
      WHERE
         sub.[qualifiedName] = T.[qualifiedName]
      AND 
         sub.[activation] >= T.[create_date]
   )
CROSS APPLY (
   SELECT
      *
   FROM
      selectedSchema
) S;
GO
-- Drop Script Generator ----------------------------------------------------------------------------------------------
-- generates a drop script, that must be run separately, dropping everything in an Anchor Modeled database
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._GenerateDropScript', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[_GenerateDropScript];
GO
CREATE PROCEDURE [dbo].[_GenerateDropScript] (
   @exclusionPattern varchar(42) = '%.[[][_]%', -- exclude Metadata by default
   @inclusionPattern varchar(42) = '%', -- include everything by default
   @directions varchar(42) = 'Upwards, Downwards', -- do both up and down by default
   @qualifiedName varchar(555) = null -- can specify a single object
)
AS
BEGIN
	set nocount on;
	create table #entities (
		[object_id] int not null unique,
		[schema] varchar(42) not null,
		[entity] varchar(555) not null,
		[type] varchar(10) not null,
		qualifiedName varchar(597) not null,
		primary key (
			[schema],
			[entity]
		)
	);
	insert into #entities (
		[object_id],
		[schema], 
		[entity],
		[type],
		qualifiedName
	)
	select 
		o.[object_id],
		s.[name],
		o.[name],
		o.[type],
		n.qualifiedName
	from sys.objects o
	join sys.schemas s
	on s.schema_id = o.schema_id
	cross apply (
		values (
			'[' + s.[name] + '].[' + o.[name] + ']'
		)
	) n (qualifiedName)
	where o.[type] not in ('S', 'IT');
	create table #exclusions (
		[object_id] int not null unique,
		[schema] varchar(42) not null,
		[entity] varchar(555) not null,
		qualifiedName varchar(597) not null,
		primary key (
			[schema],
			[entity]
		)
	);
	insert into #exclusions (
		[object_id],
		[schema], 
		[entity],
		qualifiedName
	)
	select 
		[object_id],
		[schema], 
		[entity],
		qualifiedName
	from #entities
	where qualifiedName like @exclusionPattern;
	-- select * from #exclusions;
	create table #inclusions (
		[object_id] int not null unique,
		[schema] varchar(42) not null,
		[entity] varchar(555) not null,
		qualifiedName varchar(597) not null,
		primary key (
			[schema],
			[entity]
		)
	);
	insert into #inclusions (
		[object_id],
		[schema], 
		[entity],
		qualifiedName
	)
	select 
		[object_id],
		[schema], 
		[entity],
		qualifiedName
	from #entities e
	where coalesce(@qualifiedName, qualifiedName) in (qualifiedName, [schema] + '.' + [entity])
	and not exists (
		select top 1 [entity] from #exclusions where [schema] = e.[schema] and [entity] = e.[entity]
	);
	-- select * from #inclusions;
	create table #downward (
		referenced_id int not null unique, 
		referenced_schema_name varchar(42) not null,
		referenced_entity_name varchar(555) not null,
		[level] smallint not null, 
		[direction] char(1) not null, 
		primary key (
			referenced_schema_name,
			referenced_entity_name
		)
	);
	with downward as (
		select 
			r.referenced_schema_name, 
			r.referenced_entity_name, 
			-2 as [level], 
			'D' as direction, 
			r.referenced_id
		from #inclusions 
		cross apply sys.dm_sql_referenced_entities(qualifiedName, 'OBJECT') r
		where r.referenced_minor_id = 0 and r.is_incomplete = 0 and r.referenced_id is not null and r.referenced_schema_name is not null
		union all
		select 
			r.referenced_schema_name, 
			r.referenced_entity_name, 
			d.[level] - 2, 
			d.direction, 
			r.referenced_id
		from downward d
		cross apply sys.dm_sql_referenced_entities(d.referenced_schema_name + '.' + d.referenced_entity_name, 'OBJECT') r
		where r.referenced_minor_id = 0 and r.is_incomplete = 0 and r.referenced_id is not null and r.referenced_schema_name is not null
	)
	insert into #downward (
		referenced_id, 
		referenced_schema_name, 
		referenced_entity_name, 
		[level], 
		[direction]
	)
	select 
		referenced_id,
		referenced_schema_name, 
		referenced_entity_name, 
		max([level]) as [level],
		min([direction]) as [direction]
	from (
		select referenced_id, referenced_schema_name, referenced_entity_name, [level], [direction] from downward
		union all
		select [object_id], [schema], [entity], 0, 'D' from #inclusions
	) d
	where not exists (
		select top 1 [entity] from #exclusions where [schema] = referenced_schema_name and [entity] = referenced_entity_name
	)
	group by 
		referenced_id,
		referenced_schema_name, 
		referenced_entity_name;
	-- select * from #downward order by level desc;
	create table #entities_at_level (
		[schema] varchar(42) not null,
		[entity] varchar(555) not null,
		qualifiedName varchar(597) not null,
		[level] int null,
		primary key (
			[schema],
			[entity]
		)
	);
	insert into #entities_at_level (
		[schema], 
		[entity],
		qualifiedName,
		[level]
	)
	select 
		e.[schema], 
		e.[entity],
		e.qualifiedName,
		d.[level]
	from #entities e
	left join #downward d
	on d.referenced_schema_name = e.[schema]
	and d.referenced_entity_name = e.[entity]
	where not exists (
		select top 1 [entity] from #exclusions where [schema] = e.[schema] and [entity] = e.[entity]
	);
	create table #upward (
		referenced_id int not null unique, 
		referenced_schema_name varchar(42) not null,
		referenced_entity_name varchar(555) not null,
		[level] smallint not null, 
		[direction] char(1) not null, 
		primary key (
			referenced_schema_name,
			referenced_entity_name
		)
	);
	with upward as (
		select 
			referenced_schema_name, 
			referenced_entity_name, 
			[level], 
			direction, 
			referenced_id
		from #downward
		union all
		select 
			cast(r.referencing_schema_name as varchar(42)), 
			cast(r.referencing_entity_name as varchar(555)), 
			cast(u.[level] + 2 as smallint), -- series becomes 0, 2, 4, 6, ...
			cast('U' as char(1)), 
			r.referencing_id
		from upward u
		cross apply sys.dm_sql_referencing_entities(u.referenced_schema_name + '.' + u.referenced_entity_name, 'OBJECT') r
		join #entities_at_level e
		on e.[schema] = r.referencing_schema_name and e.[entity] = r.referencing_entity_name
		and (e.[level] is null or u.[level] + 2 > e.[level])
		where r.referencing_id <> OBJECT_ID(u.referenced_schema_name + '.' + u.referenced_entity_name)
	)
	insert into #upward (
		referenced_id, 
		referenced_schema_name, 
		referenced_entity_name, 
		[level], 
		[direction]
	)
	select 
		referenced_id,
		referenced_schema_name, 
		referenced_entity_name, 
		max([level]) as [level],
		min([direction]) as [direction]
	from upward 
	where referenced_schema_name + '.' + referenced_entity_name like @inclusionPattern
	group by 
		referenced_id,
		referenced_schema_name, 
		referenced_entity_name;
	with adjustment as (
		select 
			u.referenced_id,
			fk.referenced_object_id,
			1 as adjustment
		from #upward u
		join sys.foreign_keys fk
		on fk.parent_object_id = u.referenced_id
		union all 
		select
			a.referenced_object_id,
			fk.referenced_object_id, 
			a.adjustment + 2 -- series becomes 1, 3, 5, 7, ... so ends up between already defined order
		from adjustment a
		join sys.foreign_keys fk
		on fk.parent_object_id = a.referenced_object_id
	)
	update u
		set u.[level] = u.[level] + a.adjustment
	from #upward u
	join adjustment a
	on a.referenced_id = u.referenced_id;
	select
		case 
			when t.objectType = 'CHECK'
			then 'ALTER TABLE ' + n.parentName + ' DROP CONSTRAINT ' + u.referenced_entity_name
			else 'DROP ' + t.objectType + ' ' + n.qualifiedName
		end + ';' + CHAR(13) as [text()]
	from #upward u
	join sys.objects o
	on o.object_id = u.referenced_id
	cross apply (
		values (
			'[' + u.referenced_schema_name + '].[' + u.referenced_entity_name + ']',
			'[' + u.referenced_schema_name + '].[' + OBJECT_NAME(o.parent_object_id) + ']'
		)
	) n (qualifiedName, parentName)
	cross apply (
		select
		case o.[type]
			when 'C' then 'CHECK'
			when 'TR' then 'TRIGGER'
			when 'V' then 'VIEW'
			when 'IF' then 'FUNCTION'
			when 'FN' then 'FUNCTION'
			when 'P' then 'PROCEDURE'
			when 'PK' then 'CONSTRAINT'
			when 'UQ' then 'CONSTRAINT'
			when 'F' then 'CONSTRAINT'
			when 'U' then 'TABLE'
		end
		) t (objectType)
	where @directions like '%' + u.direction + '%'
	and t.objectType in (
			'CHECK',
			'VIEW',
			'FUNCTION',
			'PROCEDURE',
			'TABLE'
		)
	order by 
		[referenced_schema_name],
		[level] desc, 
		[direction] asc,
		case [type]
			when 'C' then 0 -- CHECK CONSTRAINT
			when 'TR' then 1 -- SQL_TRIGGER
			when 'P' then 2 -- SQL_STORED_PROCEDURE
			when 'V' then 3 -- VIEW
			when 'IF' then 4 -- SQL_INLINE_TABLE_VALUED_FUNCTION
			when 'FN' then 5 -- SQL_SCALAR_FUNCTION
			when 'PK' then 6 -- PRIMARY_KEY_CONSTRAINT
			when 'UQ' then 7 -- UNIQUE_CONSTRAINT
			when 'F' then 8 -- FOREIGN_KEY_CONSTRAINT
			when 'U' then 9 -- USER_TABLE
		end asc,
		[referenced_entity_name]
	for xml path('');
END
GO
-- Database Copy Script Generator -------------------------------------------------------------------------------------
-- generates a copy script, that must be run separately, copying all data between two identically modeled databases
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._GenerateCopyScript', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[_GenerateCopyScript];
GO
CREATE PROCEDURE [dbo]._GenerateCopyScript (
	@source varchar(123),
	@target varchar(123)
)
as
begin
	declare @R char(1);
    set @R = CHAR(13);
	-- stores the built SQL code
	declare @sql varchar(max);
    set @sql = 'USE ' + @target + ';' + @R;
	declare @xml xml;
	-- find which version of the schema that is in effect
	declare @version int;
	select
		@version = max([version])
	from
		[dbo]._Schema;
	-- declare and set other variables we need
	declare @equivalentSuffix varchar(42);
	declare @identitySuffix varchar(42);
	declare @annexSuffix varchar(42);
	declare @positSuffix varchar(42);
	declare @temporalization varchar(42);
	select
		@equivalentSuffix = equivalentSuffix,
		@identitySuffix = identitySuffix,
		@annexSuffix = annexSuffix,
		@positSuffix = positSuffix,
		@temporalization = temporalization
	from
		[dbo]._Schema_Expanded
	where
		[version] = @version;
	-- build non-equivalent knot copy
	set @xml = (
		select
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + ' ON;' + @R
			end,
			'INSERT INTO ' + [capsule] + '.' + [name] + '(' + [columns] + ')' + @R +
			'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + ';' + @R,
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + ' OFF;' + @R
			end
		from
			[dbo]._Knot x
		cross apply (
			select stuff((
				select
					', ' + [name]
				from
					sys.columns
				where
					[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
				and
					is_computed = 0
				for xml path('')
			), 1, 2, '')
		) c ([columns])
		where
			[version] = @version
		and
			isnull(equivalent, 'false') = 'false'
		for xml path('')
	);
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	-- build equivalent knot copy
	set @xml = (
		select
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @identitySuffix + ' ON;' + @R
			end,
			'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @identitySuffix + '(' + [columns] + ')' + @R +
			'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @identitySuffix + ';' + @R,
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @identitySuffix + ' OFF;' + @R
			end,
			'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @equivalentSuffix + '(' + [columns] + ')' + @R +
			'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @equivalentSuffix + ';' + @R
		from
			[dbo]._Knot x
		cross apply (
			select stuff((
				select
					', ' + [name]
				from
					sys.columns
				where
					[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
				and
					is_computed = 0
				for xml path('')
			), 1, 2, '')
		) c ([columns])
		where
			[version] = @version
		and
			isnull(equivalent, 'false') = 'true'
		for xml path('')
	);
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	-- build anchor copy
	set @xml = (
		select
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + ' ON;' + @R
			end,
			'INSERT INTO ' + [capsule] + '.' + [name] + '(' + [columns] + ')' + @R +
			'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + ';' + @R,
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + ' OFF;' + @R
			end
		from
			[dbo]._Anchor x
		cross apply (
			select stuff((
				select
					', ' + [name]
				from
					sys.columns
				where
					[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
				and
					is_computed = 0
				for xml path('')
			), 1, 2, '')
		) c ([columns])
		where
			[version] = @version
		for xml path('')
	);
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	-- build attribute copy
	if (@temporalization = 'crt')
	begin
		set @xml = (
			select
				case
					when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @positSuffix + ' ON;' + @R
				end,
				'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @positSuffix + '(' + [positColumns] + ')' + @R +
				'SELECT ' + [positColumns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @positSuffix + ';' + @R,
				case
					when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @positSuffix + ' OFF;' + @R
				end,
				'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @annexSuffix + '(' + [annexColumns] + ')' + @R +
				'SELECT ' + [annexColumns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @annexSuffix + ';' + @R
			from
				[dbo]._Attribute x
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name] + '_' + @positSuffix)
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) pc ([positColumns])
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name] + '_' + @annexSuffix)
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) ac ([annexColumns])
			where
				[version] = @version
			for xml path('')
		);
	end
	else -- uni
	begin
		set @xml = (
			select
				'INSERT INTO ' + [capsule] + '.' + [name] + '(' + [columns] + ')' + @R +
				'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + ';' + @R
			from
				[dbo]._Attribute x
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) c ([columns])
			where
				[version] = @version
			for xml path('')
		);
	end
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	-- build tie copy
	if (@temporalization = 'crt')
	begin
		set @xml = (
			select
				case
					when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @positSuffix + ' ON;' + @R
				end,
				'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @positSuffix + '(' + [positColumns] + ')' + @R +
				'SELECT ' + [positColumns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @positSuffix + ';' + @R,
				case
					when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @positSuffix + ' OFF;' + @R
				end,
				'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @annexSuffix + '(' + [annexColumns] + ')' + @R +
				'SELECT ' + [annexColumns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @annexSuffix + ';' + @R
			from
				[dbo]._Tie x
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name] + '_' + @positSuffix)
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) pc ([positColumns])
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name] + '_' + @annexSuffix)
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) ac ([annexColumns])
			where
				[version] = @version
			for xml path('')
		);
	end
	else -- uni
	begin
		set @xml = (
			select
				'INSERT INTO ' + [capsule] + '.' + [name] + '(' + [columns] + ')' + @R +
				'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + ';' + @R
			from
				[dbo]._Tie x
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) c ([columns])
			where
				[version] = @version
			for xml path('')
		);
	end
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	select @sql for xml path('');
end
go
-- Delete Everything with a Certain Metadata Id -----------------------------------------------------------------------
-- deletes all rows from all tables that have the specified metadata id
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo._DeleteWhereMetadataEquals', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[_DeleteWhereMetadataEquals];
GO
CREATE PROCEDURE [dbo]._DeleteWhereMetadataEquals (
	@metadataID int,
	@schemaVersion int = null,
	@includeKnots bit = 0
)
as
begin
	declare @sql varchar(max);
	set @sql = 'print ''Null is not a valid value for @metadataId''';
	if(@metadataId is not null)
	begin
		if(@schemaVersion is null)
		begin
			select
				@schemaVersion = max(Version)
			from
				[dbo]._Schema;
		end;
		with constructs as (
			select
				'l' + name as name,
				2 as prio,
				'Metadata' + name as metadataColumn
			from
				[dbo]._Tie
			where
				[version] = @schemaVersion
			union all
			select
				'l' + name as name,
				3 as prio,
				'Metadata' + mnemonic as metadataColumn
			from
				[dbo]._Anchor
			where
				[version] = @schemaVersion
			union all
			select
				name,
				4 as prio,
				'Metadata' + mnemonic as metadataColumn
			from
				[dbo]._Knot
			where
				[version] = @schemaVersion
			and
				@includeKnots = 1
		)
		select
			@sql = (
				select
					'DELETE FROM ' + name + ' WHERE ' + metadataColumn + ' = ' + cast(@metadataId as varchar(max)) + '; '
				from
					constructs
        order by
					prio, name
				for xml
					path('')
			);
	end
	exec(@sql);
end
go
if OBJECT_ID('dbo._FindWhatToRemove', 'P') is not null
drop proc [dbo].[_FindWhatToRemove];
go
-- _FindWhatToRemove finds what else to remove given 
-- some input data containing data about to be removed.
--
--	Note that the table #removed must be created and 
--	have at least one row before calling this SP. This 
--	table will be populated with additional rows during
--	the walking of the ties.
--
--	Parameters: 
--
--	@current	The mnemonic of the anchor in which to 
--	start the tie walking.
--	@forbid	Comma separated list of anchor mnemonics
--	that never should be walked over.
--	(optional)
--	@visited	Keeps track of which anchors have been
--	visited. Should never be passed to the
--	procedure.
--
--	----------------------------------------------------
--	-- EXAMPLE USAGE
--	----------------------------------------------------
--	if object_id('tempdb..#visited') is not null
--	drop table #visited;
--
--	create table #visited (
--	Visited varchar(max), 
--	CurrentRole varchar(42),
--	CurrentMnemonic char(2),
--	Occurrences int, 
--	Tie varchar(555), 
--	AnchorRole varchar(42),
--	AnchorMnemonic char(2), 
--	VisitingOrder int
--	);
--
--	if object_id('tempdb..#removed') is not null
--	drop table #removed;
--	create table #removed (
--	AnchorMnemonic char(2), 
--	AnchorID int, 
--	primary key (
--	AnchorMnemonic,
--	AnchorID
--	)
--	);
--
--	insert into #removed 
--	values ('CO', 3);
--
--	insert into #visited
--	EXEC _FindWhatToRemove 'CO', 'AA';
--
--	select * from #visited;
--	select * from #removed;
create proc [dbo].[_FindWhatToRemove] (
	@current char(2), 
	@forbid varchar(max) = null,
	@visited varchar(max) = null
)
as 
begin
	-- dummy creation to make intellisense work 
	if object_id('tempdb..#removed') is null
	create table #removed (
		AnchorMnemonic char(2), 
		AnchorID int, 
		primary key (
			AnchorMnemonic,
			AnchorID
		)
	);
	set @visited = isnull(@visited, '');
	if @visited not like '%-' + @current + '%'
	begin
		set @visited = @visited + '-' + @current;
		declare @version int = (select max(version) from [dbo]._Schema);
		declare @ties xml = (
			select
				*
			from (
				select [schema].query('//tie[anchorRole[@type = sql:variable("@current")]]')
				from [dbo]._Schema
				where version = @version
			) t (ties)
		);
		select 
			@visited as Visited,
			Tie.value('../anchorRole[@type = sql:variable("@current")][1]/@role', 'varchar(42)') as CurrentRole,
			@current as CurrentMnemonic,
			cast(null as int) as Occurrences,
			replace(Tie.query('
				for $tie in ..
				return <name> {
					for $role in ($tie/anchorRole, $tie/knotRole)
					return concat($role/@type, "_", $role/@role)
				} </name>
			').value('name[1]', 'varchar(555)'), ' ', '_') as Tie,
			Tie.value('@role', 'varchar(42)') as AnchorRole,
			Tie.value('@type', 'char(2)') as AnchorMnemonic, 
			row_number() over (order by (select 1)) as VisitingOrder
		into #walk
		from @ties.nodes('tie/anchorRole[@type != sql:variable("@current")]') AS t (Tie)
		delete #walk where @forbid + ',' like '%' + AnchorMnemonic + ',%';
		declare @update varchar(max) = (
			select '
				update #walk
				set Occurrences = (
					select count(*)
					from ' + Tie + ' t
					join #removed x
					on x.AnchorMnemonic = ''' + CurrentMnemonic + '''
					and x.AnchorId = t.' + CurrentMnemonic + '_ID_' + CurrentRole + '
				)
				where Tie = ''' + Tie + '''
			' as [text()]
			from #walk
			for xml path(''), type
		).value('.', 'varchar(max)');
		exec(@update);
		select 
			substring(Visited, 2, len(Visited)-1) as Visited, 
			CurrentRole, 
			CurrentMnemonic, 
			Occurrences,
			Tie, 
			AnchorRole, 
			AnchorMnemonic, 
			VisitingOrder
		from #walk;
		declare @i int = 0;
		declare @max int = (select max(VisitingOrder) from #walk);
		declare @next char(2);
		declare @occurrences int = 0;
		declare @insert varchar(max);
		declare @tie varchar(555);
		declare @anchor_column varchar(555);
		declare @current_column varchar(555);
		while @i < @max
		begin
			set @i = @i + 1;
			select 
				@occurrences = Occurrences,
				@tie = Tie,
				@next = AnchorMnemonic, 
				@anchor_column = AnchorMnemonic + '_ID_' + AnchorRole, 
				@current_column = CurrentMnemonic + '_ID_' + CurrentRole
			from #walk
			where VisitingOrder = @i;
			if @occurrences > 0
			begin
				set @insert = '
					insert into #removed (AnchorMnemonic, AnchorID)
					select distinct ''' + @next + ''', t.' + @anchor_column + '
					from ' + @tie + ' t
					join #removed x
					on x.AnchorMnemonic = ''' + @current + '''
					and x.AnchorId = t.' + @current_column + '
					left join #removed seen
					on seen.AnchorMnemonic = ''' + @next + '''
					and seen.AnchorId = t.' + @anchor_column + '
					where seen.AnchorId is null; 
				';
				exec(@insert);
				exec _FindWhatToRemove @next, @forbid, @visited;
			end
		end
	end
end
go
if OBJECT_ID('dbo._GenerateDeleteScript') is not null
drop proc [dbo]._GenerateDeleteScript;
go
-- _GenerateDeleteScript creates delete statements 
-- that can be used to empty a database or parts of 
-- a database.
--
--	Parameters: 
--
--	@anchorList	An optional parameter specified as a 
-- list of anchors to be deleted. If not
-- specified, delete statements will be
-- generated for all anchors.
-- 
-- EXAMPLE:
-- _GenerateDeleteScript @anchorList = 'AC PE'
--
create proc [dbo]._GenerateDeleteScript (
	@anchorList varchar(max) = null
)
as
begin
	declare @batchSize int = 100000;
	declare @currentVersion int = (
		select max([version]) from _Schema
	);
	select a.[capsule] + '.' + a.[name] as qualifiedName, a.[mnemonic], a.[generator]
	into #anchor 
	from [dbo]._Anchor a
	where a.[version] = @currentVersion
	and (@anchorList is null or @anchorList like '%' + a.[mnemonic] + '%');
	select b.[capsule] + '.' + b.[name] as qualifiedName, b.[generator], b.[knotRange]
	into #attribute
	from [dbo]._Attribute b
	join #anchor a
	on a.[mnemonic] = b.[anchorMnemonic]
	where b.[version] = @currentVersion;
	select distinct t.[capsule] + '.' + t.[name] as qualifiedName, t.[generator], t.[knots]
	into #tie 
	from [dbo]._Tie t
	join #anchor a
	on t.[anchors] like '%' + a.[mnemonic] + '%'
	where t.[version] = @currentVersion;
	select distinct k.[capsule] + '.' + k.[name] as qualifiedName, k.[generator]
	into #knot
	from [dbo]._Knot k
	outer apply (
		select qualifiedName 
		from #tie t
		where t.[knots] like '%' + k.[mnemonic] + '%'
	) kt
	left join #attribute a
	on a.[knotRange] = k.[mnemonic]
	where k.[version] = @currentVersion
	and (kt.qualifiedName is not null or a.qualifiedName is not null)
	and not exists (
		select top 1 t.[knots]
		from [dbo]._Tie t
		where t.[version] = @currentVersion
		and t.[knots] like '%' + k.[mnemonic] + '%'
		and t.[capsule] + '.' + t.[name] not in (
			select qualifiedName from #tie
		)
	)
	and not exists (
		select top 1 a.[mnemonic]
		from [dbo]._Attribute a
		where a.[version] = @currentVersion
		and a.[knotRange] = k.[mnemonic]
		and a.[capsule] + '.' + a.[name] not in (
			select qualifiedName from #attribute
		)
	);
	select 
		case 
			when ROW_NUMBER() over (order by ordering, qualifiedName) = 1
			then 'DECLARE @deletedRows INT; ' + CHAR(13)
			else ''
		end +
		'SET @deletedRows = 1; ' + CHAR(13) +
		'WHILE @deletedRows != 0 ' + CHAR(13) +
		'BEGIN' + CHAR(13) +
		CHAR(9) + 'DELETE TOP (' + cast(@batchSize as varchar(10)) + ') ' + qualifiedName + '; ' + CHAR(13) +
		CHAR(9) + 'SET @deletedRows = @@ROWCOUNT; ' + CHAR(13) +
		'END' + CHAR(13) +
		case 
			when [generator] = 'true'
			then 'DBCC CHECKIDENT (''' + qualifiedName + ''', RESEED, 0); ' + CHAR(13) 
			else ''
		end as [text()] 
	from (
		select 1 as ordering, qualifiedName, [generator] from #attribute
		union all
		select 2 as ordering, qualifiedName, [generator] from #tie
		union all
		select 3 as ordering, qualifiedName, [generator] from #anchor
		union all
		select 4 as ordering, qualifiedName, [generator] from #knot
	) x
	order by ordering, qualifiedName asc
	for xml path('');
end
go
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------