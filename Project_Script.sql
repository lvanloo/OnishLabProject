-- Create Table with identical settings to LaurenDB.I_TFbkup

CREATE TABLE `I_TF` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `WBID` varchar(255) DEFAULT NULL,
  `Genename` varchar(255) DEFAULT NULL,
  `AnatomyTermID` varchar(255) DEFAULT NULL,
  `In_WTF` tinyint(4) DEFAULT 0,
  `In_modENCODE` tinyint(4) DEFAULT 0,
  `In_CGC` int(11) DEFAULT 0,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Genename_UNIQUE` (`Genename`)
) ENGINE=MyISAM AUTO_INCREMENT=1585 DEFAULT CHARSET=ascii;

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

CREATE TABLE CGC_counts AS SELECT count( b.geneName), genename FROM NishimuraLab.CGC_with_GFP a  
INNER JOIN NishimuraLab.WTF3 b ON (a.description LIKE CONCAT('%',b.geneName,'p%'))
GROUP BY geneName
HAVING COUNT(*)>= 1;

-- alter column names in CGC_counts 

ALTER TABLE `LaurenDB`.`CGC_counts` 
CHANGE COLUMN `count( b.geneName)` `ctb_genename` BIGINT(21) NOT NULL ;

ALTER TABLE `LaurenDB`.`CGC_counts` 
CHANGE COLUMN `genename` `geneName` VARCHAR(45) NULL DEFAULT NULL ;


-- UPDATE In_CGC values with values/counts from CGC_counts

UPDATE I_TF t1, CGC_counts t2 SET t1.In_CGC = t2.ctb_genename WHERE t1.genename = t2.genename;


-- set null In_CGC = to zero

UPDATE LaurenDB.I_TF SET In_CGC = 0 WHERE In_CGC IS NULL;

-- Add column to show which genes appear in Rob's data

ALTER TABLE `LaurenDB`.`I_TF` 
ADD COLUMN `In_Log2Fold` TINYINT(4) NULL DEFAULT 0 AFTER `In_CGC`;

-- Change 0 value In_Log2Fold to a value of 1 when it appears in williams2023.Log2FoldChangeWide

Update LaurenDB.I_TF SET In_Log2Fold = 1 where genename in
(select genename from williams2023.log2FoldChangeWide);

-- count the  number of rows that the WBID is in the dineenSetsAnalyzed and the I_TF

SELECT count(distinct genename)
FROM LaurenDB.I_TF
inner JOIN williams2023.dineenSetsAnalyzed
ON LaurenDB.I_TF.WBID = dineenSetsAnalyzed.WBID;

-- add description from williams2023.dineenSetsAnalyzed to I_TF 

alter table LaurenDB.I_TF add dineen_analyzed VARCHAR(45);
UPDATE LaurenDB.I_TF t1, williams2023.dineenSetsAnalyzed t2
SET t1.dineen_analyzed = t2.description 
WHERE t1.WBID = t2.WBID;


 
 
