-- Create Table with identical settings to LaurenDB.I_TFbkup
 CREATE TABLE IF NOT EXISTS `I_TF` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `WBID` varchar(255) DEFAULT NULL,
  `Genename` varchar(255) DEFAULT NULL,
  `AnatomyTermID` varchar(255) DEFAULT NULL,
  `In_WTF` tinyint(4) DEFAULT 0,
  `In_modENCODE` tinyint(4) DEFAULT 0,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Genename_UNIQUE` (`Genename`)
) ENGINE=MyISAM AUTO_INCREMENT=1036 DEFAULT CHARSET=ascii;

-- Populate table with data from AnatomyAssociation that also appears in WTF3

INSERT INTO LaurenDB.I_TF (WBID, genename, AnatomyTermID)
SELECT DISTINCT WBiD, genename, AnatomyTermID
FROM NishimuraLab.AnatomyAssociation
WHERE AnatomyTermID = 'WBbt:0005772' and 
qualifier in ('enriched', 'certain', 'partial') and 
genename in (select genename from NishimuraLab.WTF3);

-- Populate table with novel Genes from Robs data 

INSERT INTO LaurenDB.I_TF (WBID, genename) 
SELECT DISTINCT WBID, geneName from williams2023.log2FoldChangeWide 
Where outcome_01 in ('enriched', 'partial', 'equal') and 
geneName IN (SELECT genename FROM NishimuraLab.WTF3) AND 
geneName NOT IN (SELECT genename from LaurenDB.I_TF);

-- Update In_WTF column to the value 1 if gene appears in the NishimuraLab.WTF3 table

Update LaurenDB.I_TF SET In_WTF = 1 where genename in 
(select genename from NishimuraLab.WTF3);

-- Update In_modENCODE to the value 1 if gene appears in the NishimuraLab.modENCODE table 
 
Update LaurenDB.I_TF SET In_modENCODE = 1 where genename in 
(select genename from NishimuraLab.modENCODE_TFs); 

-- create table with the counts and genenames from WTF3 and CGC_with_GFP

/*CREATE TABLE CGC_counts AS SELECT count( b.geneName), genename FROM NishimuraLab.CGC_with_GFP a  
INNER JOIN NishimuraLab.WTF3 b ON (a.description LIKE CONCAT('%',b.geneName,'p%'))
GROUP BY geneName
HAVING COUNT(*)>= 1;*/

-- select counts and genename from CGC_counts table that appear in I_TF

/*SELECT ctb_genename, b_genename from LaurenDB.CGC_counts  where b_genename in (
Select genename from LaurenDB.I_TF Inner join CGC_counts ON I_TF.genename = CGC_counts.b_genename)*/

-- UPDATE In_CGC values with values/counts from CGC_counts and set null to zero

/*UPDATE I_TF t1, CGC_counts t2
SET t1.In_CGC = t2.ctb_geneName
WHERE t1.genename = t2.genename;

UPDATE LaurenDB.I_TF SET In_CGC = 0 WHERE In_CGC IS NULL;
*/



