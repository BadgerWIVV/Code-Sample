/**************************************************************************************************************/
/*file:///C:/Users/JMarx/AppData/Local/Microsoft/Windows/INetCache/Content.Outlook/VIT1UI28/Genetic%20Testing%20-%20Medical%20Clinical%20Policy%20Bulletins%20_%20Aetna.html */

/**************************************************************************************************************/

IF OBJECT_ID('TEMPDB.DBO.#CoveredCriteria') IS NOT NULL
	BEGIN
		DROP TABLE #CoveredCriteria
	END;

CREATE TABLE #CoveredCriteria (
 [ID]		INT IDENTITY
,[CPT]		VARCHAR(MAX)
,[CPT End]	VARCHAR(MAX)
,[Text]		VARCHAR(MAX)
);

/*
1) Copy Paste
2) Find and replace 
	/t
	', NULL, '
3) Find and replace
	\r\n
	')\r\n,('
4) Clean up head and tail
5) Find and replace
	 '
	'
6) Find and replace
	','
	', NULL, '
7) Find and replace
	 -hyphen 
	', '
8) Find and replace
	(?<='[0-Z]{5}', '[0-Z]{5}'), NULL,
	,

*/

/* CPT codes covered if selection criteria are met:
Genetic testing for dominant polycystic kidney disease (PKD1 and PKD2), Dravet syndrome (SCN1A and SCN2A) -hyphen no specific code: */

INSERT INTO #CoveredCriteria VALUES

 ('0214U', NULL, 'Rare diseases (constitutional/heritable disorders), whole exome and mitochondrial DNA sequence analysis, including small sequence changes, deletions, duplications, short tandem repeat gene expansions, and variants in non-hyphenuniquely mappable regions, blood or saliva, identification and categorization of genetic variants, proband')
,('0215U', NULL, 'Rare diseases (constitutional/heritable disorders), whole exome and mitochondrial DNA sequence analysis, including small sequence changes, deletions, duplications, short tandem repeat gene expansions, and variants in non-hyphenuniquely mappable regions, blood or saliva, identification and categorization of genetic variants, proband')
,('0218U', NULL, 'Neurology (muscular dystrophy), DMD gene sequence analysis, including small sequence changes, deletions, duplications, and variants in non-hyphenuniquely mappable regions, blood or saliva, identification and characterization of genetic variants')
,('0231U', NULL, 'CACNA1A (calcium voltage-hyphengated channel subunit alpha 1A) (eg, spinocerebellar ataxia), full gene analysis, including small sequence changes in exonic and intronic regions, deletions, duplications, short tandem repeat (STR) gene expansions, mobile element insertions, and variants in non-hyphenuniquely mappable regions')
,('0233U', NULL, 'FXN (frataxin) (eg, Friedreich ataxia), gene analysis, including small sequence changes in exonic and intronic regions, deletions, duplications, short tandem repeat (STR) expansions, mobile element insertions, and variants in non-hyphenuniquely mappable regions')
,('0234U', NULL, 'MECP2 (methyl CpG binding protein 2) (eg, Rett syndrome), full gene analysis, including small sequence changes in exonic and intronic regions, deletions, duplications, mobile element insertions, and variants in non-hyphenuniquely mappable regions')
,('0235U', NULL, 'PTEN (phosphatase and tensin homolog) (eg, Cowden syndrome, PTEN hamartoma tumor syndrome), full gene analysis, including small sequence changes in exonic and intronic regions, deletions, duplications, mobile element insertions, and variants in non-hyphenuniquely mappable regions')
,('0236U', NULL, 'SMN1 (survival of motor neuron 1, telomeric) and SMN2 (survival of motor neuron 2, centromeric) (eg, spinal muscular atrophy) full gene analysis, including small sequence changes in exonic and intronic regions, duplications and deletions, and mobile element insertions')
,('0238U', NULL, 'Oncology (Lynch syndrome), genomic DNA sequence analysis of MLH1, MSH2, MSH6, PMS2, and EPCAM, including small sequence changes in exonic and intronic regions, deletions, duplications, mobile element insertions, and variants in non-hyphenuniquely mappable regions')
,('81161', NULL, 'DMD (dystrophin) (eg, duchenne/becker muscular dystrophy) deletion analysis, and duplication analysis, if performed')
,('81177', NULL, 'ATN1 (atrophin 1) (eg, dentatorubral-hyphenpallidoluysian atrophy) gene analysis, evaluation to detect abnormal (eg, expanded) alleles')
,('81178', NULL, 'ATXN1 (ataxin 1) (eg, spinocerebellar ataxia) gene analysis, evaluation to detect abnormal (eg, expanded) alleles')
,('81179', NULL, 'ATXN2 (ataxin 2) (eg, spinocerebellar ataxia) gene analysis, evaluation to detect abnormal (eg, expanded) alleles')
,('81180', NULL, 'ATXN3 (ataxin 3) (eg, spinocerebellar ataxia, Machado-hyphen Joseph disease) gene analysis, evaluation to detect abnormal (eg, expanded) alleles')
,('81181', NULL, 'ATXN7 (ataxin 7) (eg, spinocerebellar ataxia) gene analysis, evaluation to detect abnormal (eg, expanded) alleles')
,('81182', NULL, 'ATXN8OS (ATXN8 opposite strand [non-hyphenprotein coding]) (eg, spinocerebellar ataxia) gene analysis, evaluation to detect abnormal (eg, expanded) alleles')
,('81183', NULL, 'ATXN10 (ataxin 10) (eg, spinocerebellar ataxia) gene analysis, evaluation to detect abnormal (eg, expanded) alleles')
,('81184', NULL, 'CACNA1A (calcium voltage-hyphengated channel subunit alpha1 A) (eg, spinocerebellar ataxia) gene analysis evaluation to detect abnormal (eg, expanded) alleles')
,('81185', NULL, 'CACNA1A (calcium voltage-hyphengated channel subunit alpha1 A) (eg, spinocerebellar ataxia) gene analysis; full gene sequence')
,('81186', NULL, 'CACNA1A (calcium voltage-hyphengated channel subunit alpha1 A) (eg, spinocerebellar ataxia) gene analysis; known familial variant')
,('81187', NULL, 'CNBP (CCHC-hyphentype zinc finger nucleic acid binding protein) (eg, myotonic dystrophy type 2) gene analysis, evaluation to detect abnormal (eg, expanded) alleles')
,('81200', NULL, 'ASPA (aspartoacylase)(eg, Canavan disease) gene analysis, common variants (eg, E285A, Y231X)')
,('81201', '81203', 'APC (adenomatous polyposis coli) (eg, familial adenomatosis polyposis [FAP], attenuated [FAP] gene analysis; full gene sequence, known familial variants, duplication/deletio variants')
,('81205', NULL, 'BCKDHB (branched-hyphenchain keto acid dehydrogenase E1, beta polypeptide) (eg, Maple syrup urine disease) gene analysis, common variants (eg, R183P, G278S, E422X)')
,('81209', NULL, 'BLM (Bloom syndrome, RecQ helicase-hyphenlike) (eg, Bloom syndrome) gene analysis, 2281del6ins7 variant')
,('81220', '81221', 'CFTR (cystic fibrosis transmembrane conductance regulator) (eg, cystic fibrosis) gene analysis; common variants (eg, ACMG/ACOG guidelines) and with known familial variants')
,('81223', NULL, 'CFTR (cystic fibrosis transmembrane conductance regulator) (eg, cystic fibrosis) gene analysis; full gene sequence')
,('81238', NULL, 'F9 (coagulation factor IX) (eg, hemophilia B), full gene sequence')
,('81240', NULL, 'F2 (prothrombin, coagulation factor II) (eg, hereditary hypercoagulability) gene analysis, 20210G>A variant')
,('81242', NULL, 'FANCC (Fanconi anemia, complementation group C) (eg, Fanconi anemia, type C) gene analysis, common variant (eg, IVS4+4A>T)')
,('81243', NULL, 'FMR1 (Fragile X mental retardation 1) (eg, fragile X mental retardation) gene analysis; evaluation to detect abnormal (eg, expanded) alleles')
,('81244', NULL, 'FMR1 (fragile X mental retardation 1) (eg, fragile X mental retardation) gene analysis; characterization of alleles (eg, expanded size and methylation status)')
,('81250', NULL, 'G6PC (glucose-hyphen6-hyphenphosphatase, catalytic subunit) (eg, Glycogen storage disease, Type 1a, von Gierke disease) gene analysis, common variants (eg, R83C, Q347X)')
,('81251', NULL, 'GBA (glucosidase, beta, acid) (eg, Gaucher disease) gene analysis, common variants (eg, N370S, 84GG, L444P, IVS2+1G>A)')
,('81252', '81253', 'GJB2 (gap junction protein, beta 2, 26kDa; connexin 26) (eg, nonsyndromic hearing loss) gene analysis; full gene sequence')
,('81255', NULL, 'HEXA (hexosaminidase A [alpha polypeptide]) (eg, Tay-hyphenSachs disease) gene analysis, common variants (eg, 1278insTATC, 1421+1G>C, G269S)')
,('81256', NULL, 'HFE (hemochromatosis) (eg, hereditary hemochromatosis) gene analysis, common variants (eg, C282Y, H63D)')
,('81257', NULL, 'HBA1/HBA2 (alpha globin 1 and alpha globin 2 (eg, alpha thalassemia, Hb Bart hydrops fetalis syndrome, HbH disease), gene analysis, for common deletions or variant (eg, Southeast Asian, Thai, Filipino, Mediterranean, alpha3.7, alpha4.2, alpha20.5, and Constant Spring)')
,('81258', '81259', 'HBA1/HBA2 (alpha globin 1 and alpha globin 2) (eg, alpha thalassemia, Hb Bart hydrops fetalis syndrome, HbH disease), gene analysis')
,('81260', NULL, 'IKBKAP (inhibitor of kappa light polypeptide gene enhancer in B-hyphencells, kinase complex-hyphenassociated protein) (eg, familial dysautonomia) gene analysis, common variants (eg, 2507+6T>C, R696P)')
,('81269', NULL, 'HBA1/HBA2 (alpha globin 1 and alpha globin 2) (eg, alpha thalassemia, Hb Bart hydrops fetalis syndrome, HbH disease), gene analysis; duplication/deletion variants')
,('81271', NULL, 'HTT (huntingtin) (eg, Huntington disease) gene analysis; evaluation to detect abnormal (eg, expanded) alleles')
,('81274', NULL, 'HTT (huntingtin) (eg, Huntington disease) gene analysis; characterization of alleles (eg, expanded size)')
,('81284', NULL, 'FXN (frataxin) (eg, Friedreich ataxia) gene analysis; evaluation to detect abnormal (expanded) alleles')
,('81285', NULL, 'FXN (frataxin) (eg, Friedreich ataxia) gene analysis evaluation; characterization of alleles (eg, expanded size)')
,('81286', NULL, 'FXN (frataxin) (eg, Friedreich ataxia) gene analysis; full gene sequence')
,('81288', NULL, 'MLH1 (mutL homolog 1, colon cancer, nonpolyposis type 2) (eg, hereditary non-hyphenpolyposis colorectal cancer, Lynch syndrome) gene analysis; promoter methylation analysis')
,('81289', NULL, 'FXN (frataxin) (eg, Friedreich ataxia) gene analysis evaluation; known familial variant(s)')
,('81290', NULL, 'MCOLN1 (mucolipin 1)(eg, Mucolipidosis, type IV) gene analysis, common variants (eg, IVS3-hyphen2A>G, del6, 4kb)')
,('81292', '81294', 'MLH1 (mutL homolog 1, colon cancer, nonpolyposis type 2) (eg, hereditary non-hyphenpolyposis colorectal cancer, Lynch syndrome) gene analysis; full sequence analysis or known familial variants or duplication/deletion variants')
,('81295', '81297', 'MSH2 (mutS homolog 2, colon cancer, nonpolyposis type 1) (eg, hereditary non-hyphenpolyposis colorectal cancer, Lynch syndrome) gene analysis; full sequence analysis or known familial variants or duplication/deletion variants')
,('81298', '81300', 'MSH6 (mutS homolog 6 [E. Coli]) )eg. jeredotaru mpm-hyphenpolyposis colorectal cancer, Lynch syndrome) gene analysis; full sequence analysis or known familial variants or duplication/deletion variants')
,('81301', NULL, 'Microsatellite instability analysis (eg, hereditary non-hyphenpolyposis colorectal cancer, Lynch syndrome) of markers for mismatch repair deficiency (eg, BAT25, BAT26), includes comparison of neoplastic and normal tissue, if performed')
,('81302', NULL, 'MECP2 (methyl CpG binding protein 2) (eg, Rett syndrome) gene analysis; full sequence analysis')
,('81310', NULL, 'NPM1 (nucleophosmin) (eg, acute myeloid leukemia) gene analysis, exon 12 variants')
,('81317', NULL, 'PMS2 (postmeiotic segregation increased 2 [S. cerevisiae]) (eg, hereditary non-hyphenpolyposis colorectal cancer, Lynch syndrome) gene analysis; full sequence analysisor known familial variants or duplication/deletion variants')
,('81318', NULL, 'PMS2 (postmeiotic segregation increased 2 [S. cerevisiae]) (eg, hereditary non-hyphenpolyposis colorectal cancer, Lynch syndrome) gene analysis; known familial variants')
,('81321', '81323', 'PTEN (phosphatase and tensin homolog) (eg, Cowden syndrome, PTEN hamartoma tumor syndrome) gene analysis; full sequence analysis, known familial variant, duplication/deletion variant')
,('81324', '81326', 'PMP22 (peripheral myelin protein 22) (eg, Charcot-hyphenMarie-hyphenTooth, hereditary neuropathy with liability to pressure palsies) gene analysis; duplication/deletion analysis, full sequence analysis, known familial variant')
,('81329', NULL, 'SMN1 (survival of motor neuron 1, telomeric) (eg, spinal muscular atrophy) gene analysis; dosage/deletion analysis (eg, carrier testing), includes SMN2 (survival of motor neuron 2, centromeric) analysis, if performed')
,('81330', NULL, 'SMPD1 (sphingomyelin phosphodiesterase 1, acid lysosomal) (eg, Niemann-hyphenPick disease, Type A) gene analysis, common variants (eg, R496L, L302P, fsP330)')
,('81331', NULL, 'SNRPN/UBE3A (small nuclear ribonucleoprotein polypeptide N and ubiquitin protein ligase E3A)(eg, Prader-hyphenWilli syndrome and/or Angelman syndrome), methylation analysis')
,('81332', NULL, 'SERPINA1 (serpin peptidase inhibitor, clade A, alpha-hyphen1 antiproteinase, antitrypsin, member 1) (eg, alpha-hyphen1-hyphenantitrypsin deficiency), gene analysis, common variants (eg, *S and *Z)')
,('81336', NULL, 'SMN1 (survival of motor neuron 1, telomeric) (eg, spinal muscular atrophy) gene analysis; full gene sequence')
,('81337', NULL, 'SMN1 (survival of motor neuron 1, telomeric) (eg, spinal muscular atrophy) gene analysis; known familial sequence variant(s')
,('81343', NULL, 'PPP2R2B (protein phosphatase 2 regulatory subunit Bbeta) (eg, spinocerebellar ataxia) gene analysis, evaluation to detect abnormal (eg, expanded) alleles')
,('81344', NULL, 'TBP (TATA box binding protein) (eg, spinocerebellar ataxia) gene analysis, evaluation to detect abnormal (eg, expanded) alleles')
,('81353', NULL, 'TP53 (tumor protein 53) (eg, Li-hyphenFraumeni syndrome) gene analysis; known familial variant')
,('81361', '81364', 'HBB (hemoglobin, subunit beta) (eg, sickle cell anemia, beta thalassemia, hemoglobinopathy)')
,('81401', NULL, 'Molecular pathology procedure, Level 2 (eg, 2-hyphen10 SNPs, 1 methylated variant, or 1 somatic variant [typically using nonsequencing target variant analysis], or detection of a dynamic mutation disorder/triplet repeat)')
,('81404', NULL, 'Molecular pathology procedure, Level 5 (eg, analysis of 2-hyphen5 exons by DNA sequence analysis, mutation scanning or duplication/deletion variants of 6-hyphen10 exons, or characterization of a dynamic mutation disorder/triplet repeat by Southern blot analysis) [covered for glucokinase gene (GCK), hepatic nuclear factor 1-hyphenα (HNF1-hyphenα), and hepatic nuclear factor 4-hyphenα (HNF4-hyphenα) for maturity-hyphenonset diabetes of the young (MODY)]')
,('81405', NULL, 'Molecular pathology procedure, Level 6 (eg, analysis of 6-hyphen10 exons by DNA sequence analysis, mutation scanning or duplication/deletion variants of 11-hyphen25 exons, regionally targeted cytogenomic array analysis) [covered for glucokinase gene (GCK), hepatic nuclear factor 1-hyphenα (HNF1-hyphenα), and hepatic nuclear factor 4-hyphenα (HNF4-hyphenα) for maturity-hyphenonset diabetes of the young (MODY)]')
,('81406', NULL, 'Molecular pathology procedure, Level 7 (eg, analysis of 11-hyphen25 exons by DNA sequence analysis, mutation scanning or duplication/deletion variants of 26-hyphen50 exons, cytogenomic array analysis for neoplasia [covered for glucokinase gene (GCK), hepatic nuclear factor 1-hyphenα (HNF1-hyphenα), and hepatic nuclear factor 4-hyphenα (HNF4-hyphenα) for maturity-hyphenonset diabetes of the young (MODY)]')
,('81408', NULL, 'Molecular pathology procedure, Level 9 (eg, analysis of >50 exons in a single gene by DNA sequence analysis) ABCA4 (ATP-hyphenbinding cassette, sub-hyphenfamily A [ABC1], member 4) (eg, Stargardt disease, age-hyphenrelated macular degeneration), full gene sequence ATM (ataxia telangiectasia mutated) (eg, ataxia telangiectasia), full gene sequence CDH23 (cadherin-hyphenrelated 23 [FBN1 sequencing]')
,('81412', NULL, 'Ashkenazi Jewish associated disorders (eg, Bloom syndrome, Canavan disease, cystic fibrosis, familial dysautonomia, Fanconi anemia group C, Gaucher disease, Tay-hyphenSachs disease), genomic sequence analysis panel, must include sequencing of at least 9 genes, including ASPA, BLM, CFTR, FANCC, GBA, HEXA, IKBKAP, MCOLN1, and SMPD1')
,('81434', NULL, 'Hereditary retinal disorders (eg, retinitis pigmentosa, Leber congenital amaurosis, cone-hyphenrod dystrophy), genomic sequence analysis panel, must include sequencing of at least 15 genes, including ABCA4, CNGA1, CRB1, EYS, PDE6A, PDE6B, PRPF31, PRPH2, RDH12, RHO, RP1, RP2, RPE65, RPGR, and USH2A')
,('81442', NULL, 'Noonan spectrum disorders (eg, Noonan syndrome, cardio-hyphenfacio-hyphencutaneous syndrome, Costello syndrome, LEOPARD syndrome, Noonan-hyphenlike syndrome), genomic sequence analysis panel, must include sequencing of at least 12 genes, including BRAF, CBL, HRAS, KRAS, MAP2K1, MAP2K2, NRAS, PTPN11, RAF1, RIT1, SHOC2, and SOS1')
,('81448', NULL, 'Hereditary peripheral neuropathies (eg, Charcot-hyphenMarie-hyphenTooth, spastic paraplegia), genomic sequence analysis panel, must include sequencing of at least 5 peripheral neuropathy-hyphenrelated genes (eg, BSCL2, GJB1, MFN2, MPZ, REEP1, SPAST, SPG11, SPTLC1)')
,('83080', NULL, 'b-hyphenHexosaminidase, each assay')
,('88245', '88269', 'Chromosome analysis')
,('88271', '88275', 'Molecular cytogenetics')
,('88323', NULL, 'Consultation and report on referred material requiring preparation of slides')
,('88341', NULL, 'Immunohistochemistry or immunocytochemistry, per specimen; each additional single antibody stain procedure (List separately in addition to code for primary procedure)')
,('88342', NULL, '   initial single antibody stain procedure')
,('88344', NULL, '   each multiplex antibody stain procedure')
,('88360', '88361', 'Morphometric analysis, tumor immunohistochemistry (eg, Her-hyphen2/neu, estrogen receptor/progesterone receptor), quantitative or semiquantitative, each antibody; manual or using computer-hyphenassisted technology')
;




--SELECT * FROM #CoveredCriteria WHERE LEN(CPT ) > 5

SELECT TOP 0 [CPT codes covered if selection criteria are met] = NULL 

SELECT
 AllCodes.STANDARDIZED_SERVICE_CODE
,AllCodes.SERVICE_SHORT_DESCRIPTION
,AllCodes.SERVICE_LONG_DESCRIPTION
,#CoveredCriteria.[Text]
,#CoveredCriteria.CPT
,#CoveredCriteria.[CPT End]
FROM
WEA_EDW.DIM.SERVICE_DIM AS AllCodes

	JOIN #CoveredCriteria
		ON AllCodes.[STANDARDIZED_SERVICE_CODE] >= #CoveredCriteria.CPT
		AND AllCodes.[STANDARDIZED_SERVICE_CODE] <= ISNULL( #CoveredCriteria.[CPT End],#CoveredCriteria.CPT )

WHERE
AllCodes.SERVICE_TYPE_NAME IN ( 'CPT-4 code', 'HCPCS code')
ORDER BY
AllCodes.STANDARDIZED_SERVICE_CODE


/**************************************************************************************************************/


IF OBJECT_ID('TEMPDB.DBO.#NotCoveredCPB') IS NOT NULL
	BEGIN
		DROP TABLE #NotCoveredCPB
	END;

CREATE TABLE #NotCoveredCPB (
 [ID]		INT IDENTITY
,[CPT]		VARCHAR(MAX)
,[CPT End]	VARCHAR(MAX)
,[Text]		VARCHAR(MAX)
);

/*
1) Copy Paste
2) Find and replace 
	/t
	', NULL, '
3) Find and replace
	\r\n
	')\r\n,('
4) Clean up head and tail
5) Find and replace
	 '
	'
6) Find and replace
	','
	', NULL, '
7) Find and replace
	 -hyphen 
	', '
8) Find and replace
	'\+
	'
9) Find and replace
	(?<='[0-Z]{5}', '[0-Z]{5}'), NULL,
	,

*/

/* CPT codes not covered for indications listed in the CPB: */

INSERT INTO #NotCoveredCPB VALUES

 ('0012U', NULL,'Germline disorders, gene rearrangement detection by whole genome next-hyphengeneration sequencing, DNA, whole blood, report of specific gene rearrangement(s)')
,('0094U', NULL,'Genome (eg, unexplained constitutional or heritable disorder or syndrome), rapid sequence analysis')
,('0101U', NULL,'Hereditary colon cancer disorders (eg, Lynch syndrome, PTEN hamartoma syndrome, Cowden syndrome, familial adenomatosis polyposis), genomic sequence analysis panel utilizing a combination of NGS, Sanger, MLPA, and array CGH, with mRNA analytics to resolve variants of unknown significance when indicated (15 genes [sequencing and deletion/duplication], EPCAM and GREM1 [deletion/duplication only])')
,('0102U', NULL,'Hereditary breast cancer-hyphenrelated disorders (eg, hereditary breast cancer, hereditary ovarian cancer, hereditary endometrial cancer), genomic sequence analysis panel utilizing a combination of NGS, Sanger, MLPA, and array CGH, with mRNA analytics to resolve variants of unknown significance when indicated (17 genes [sequencing and deletion/duplication])')
,('0103U', NULL,'Hereditary ovarian cancer (eg, hereditary ovarian cancer, hereditary endometrial cancer), genomic sequence analysis panel utilizing a combination of NGS, Sanger, MLPA, and array CGH, with mRNA analytics to resolve variants of unknown significance when indicated (24 genes [sequencing and deletion/duplication], EPCAM [deletion/duplication only])')
,('0130U', NULL,'Hereditary colon cancer disorders (eg, Lynch syndrome, PTEN hamartoma syndrome, Cowden syndrome, familial adenomatosis polyposis), targeted mRNA sequence analysis panel (APC, CDH1, CHEK2, MLH1, MSH2, MSH6, MUTYH, PMS2, PTEN, and TP53) (List separately in addition to code for primary procedure)')
,('0136U', NULL,'ATM (ataxia telangiectasia mutated) (eg, ataxia telangiectasia) mRNA sequence analysis (List separately in addition to code for primary procedure)')
,('0137U', NULL,'PALB2 (partner and localizer of BRCA2) (eg, breast and pancreatic cancer) mRNA sequence analysis (List separately in addition to code for primary procedure)')
,('0156U', NULL,'Copy number (eg, intellectual disability, dysmorphology), sequence analysis [Short Multiply Aggregated Sequence Homologies (SMASH) (Marvel Genomics)]')
,('0157U', NULL,'APC (APC regulator of WNT signaling pathway) (eg, familial adenomatosis polyposis [FAP]) mRNA sequence analysis[Short Multiply Aggregated Sequence Homologies (SMASH) (Marvel Genomics)]')
,('0162U', NULL,'Hereditary colon cancer (Lynch syndrome), targeted mRNA sequence analysis panel (MLH1, MSH2, MSH6, PMS2) (List separately in addition to code for primary procedure) [Short Multiply Aggregated Sequence Homologies (SMASH) (Marvel Genomics)]')
,('0209U', NULL,'Cytogenomic constitutional (genome-hyphenwide) analysis, interrogation of genomic regions for copy number, structural changes and areas of homozygosity for chromosomal abnormalities')
,('0212U', NULL,'Rare diseases (constitutional/heritable disorders), whole genome and mitochondrial DNA sequence analysis, including small sequence changes, deletions, duplications, short tandem repeat gene expansions, and variants in non-hyphenuniquely mappable regions, blood or saliva, identification and categorization of genetic variants, proband')
,('0213U', NULL,'Rare diseases (constitutional/heritable disorders), whole genome and mitochondrial DNA sequence analysis, including small sequence changes, deletions, duplications, short tandem repeat gene expansions, and variants in non-hyphenuniquely mappable regions, blood or saliva, identification and categorization of genetic variants, each comparator genome (eg, parent, sibling)')
,('81222', NULL,'CFTR (cystic fibrosis transmembrane conductance regulator) (eg, cystic fibrosis) gene analysis; duplication/deletion variants')
,('81291', NULL,'MTHFR (5,10-hyphenmethylenetetrahydrofolate reductase) (eg, hereditary hypercoagulability) gene analysis, common variants (eg, 677T, 1298C)')
,('81312', NULL,'PABPN1 (poly[A] binding protein nuclear 1) (eg, oculopharyngeal muscular dystrophy) gene analysis, evaluation to detect abnormal (eg, expanded) alleles')
,('81377', NULL,'HLA Class II typing, low resolution (eg, antigen equivalents); one antigen equivalent, each')
,('81383', NULL,'HLA Class II typing, high resolution (ie, alleles or allele groups); one allele or allele group (eg, HLA-hyphenDQB1*06:02P), each')
,('81410', NULL,'Aortic dysfunction or dilation (eg, Marfan syndrome, Loeys Dietz syndrome, Ehler Danlos syndrome type IV, arterial tortuosity syndrome); genomic sequence analysis panel, must include sequencing of at least 9 genes, including FBN1, TGFBR1, TGFBR2, COL3A1, MYH11, ACTA2, SLC2A10, SMAD3, and MYLK')
,('81411', NULL,'   duplication/deletion analysis panel, must include analyses for TGFBR1, TGFBR2, MYH11, and COL3A1')
,('81419', NULL,'Epilepsy genomic sequence analysis panel, must include analyses for ALDH7A1, CACNA1A, CDKL5, CHD2, GABRG2, GRIN2A, KCNQ2, MECP2, PCDH19, POLG, PRRT2, SCN1A, SCN1B, SCN2A, SCN8A, SLC2A1, SLC9A6, STXBP1, SYNGAP1, TCF4, TPP1, TSC1, TSC2, and ZEB2')
,('81425', NULL,'Genome (eg, unexplained constitutional or heritable disorder or syndrome); sequence analysis')
,('81426', NULL,'Genome (eg, unexplained constitutional or heritable disorder or syndrome); sequence analysis, each comparator genome (eg, parents, siblings) (List separately in addition to code for primary procedure)')
,('81427', NULL,'Genome (eg, unexplained constitutional or heritable disorder or syndrome); re-hyphenevaluation of previously obtained genome sequence (eg, updated knowledge or unrelated condition/syndrome)')
,('81430', NULL,'Hearing loss (eg, nonsyndromic hearing loss, Usher syndrome, Pendred syndrome); genomic sequence analysis panel, must include sequencing of at least 60 genes, including CDH23, CLRN1, GJB2, GPR98, MTRNR1, MYO7A, MYO15A, PCDH15, OTOF, SLC26A4, TMC1, TMPRSS3, USH1C, USH1G, USH2A, and WFS1')
,('81431', NULL,'   duplication/deletion analysis panel, must include copy number analyses for STRC and DFNB1 deletions in GJB2 and GJB6 genes')
,('81435', NULL,'Hereditary colon cancer disorders (eg, Lynch syndrome, PTEN hamartoma syndrome, Cowden syndrome, familial adenomatosis polyposis); genomic sequence analysis panel, must include sequencing of at least 10 genes, including APC, BMPR1A, CDH1, MLH1, MSH2, MSH6, MUTYH, PTEN, SMAD4, and STK11')
,('81436', NULL,'   duplication/deletion analysis panel, must include analysis of at least 5 genes, including MLH1, MSH2, EPCAM, SMAD4, and STK11')
,('81440', NULL,'Nuclear encoded mitochondrial genes (eg, neurologic or myopathic phenotypes), genomic sequence panel, must include analysis of at least 100 genes, including BCS1L, C10orf2, COQ2, COX10, DGUOK, MPV17, OPA1, PDSS2, POLG, POLG2, RRM2B, SCO1, SCO2, SLC25A4, SUCLA2, SUCLG1, TAZ, TK2, and TYMP')
,('81443', NULL,'Genetic testing for severe inherited conditions (eg, cystic fibrosis, Ashkenazi Jewish-hyphenassociated disorders [eg, Bloom syndrome, Canavan disease, Fanconi anemia type C, mucolipidosis type VI, Gaucher disease, Tay-hyphenSachs disease], beta hemoglobinopathies, phenylketonuria, galactosemia), genomic sequence analysis panel, must include sequencing of at least 15 genes (eg, ACADM, ARSA, ASPA, ATP7B, BCKDHA, BCKDHB, BLM, CFTR, DHCR7, FANCC, G6PC, GAA, GALT, GBA, GBE1, HBB, HEXA, IKBKAP, MCOLN1, PAH')
,('81460', NULL,'Whole mitochondrial genome (eg, Leigh syndrome, mitochondrial encephalomyopathy, lactic acidosis, and stroke-hyphenlike episodes [MELAS], myoclonic epilepsy with ragged-hyphenred fibers [MERFF], neuropathy, ataxia, and retinitis pigmentosa [NARP], Leber hereditary optic neuropathy [LHON]), genomic sequence, must include sequence analysis of entire mitochondrial genome with heteroplasmy detection')
,('81465', NULL,'Whole mitochondrial genome large deletion analysis panel (eg, Kearns-hyphenSayre syndrome, chronic progressive external ophthalmoplegia), including heteroplasmy detection, if performed')
,('81470', NULL,'X-hyphenlinked intellectual disability (XLID) (eg, syndromic and non-hyphensyndromic XLID); genomic sequence analysis panel, must include sequencing of at least 60 genes, including ARX, ATRX, CDKL5, FGD1, FMR1, HUWE1, IL1RAPL, KDM5C, L1CAM, MECP2, MED12, MID1, OCRL, RPS6KA3, and SLC16A2')
,('81471', NULL,'   duplication/deletion gene analysis, must include analysis of at least 60 genes, including ARX, ATRX, CDKL5, FGD1, FMR1, HUWE1, IL1RAPL, KDM5C, L1CAM, MECP2, MED12, MID1, OCRL, RPS6KA3, and SLC16A2')

;


SELECT TOP 0 [CPT codes not covered for indications listed in the CPB:] = NULL 

SELECT
 AllCodes.STANDARDIZED_SERVICE_CODE
,AllCodes.SERVICE_SHORT_DESCRIPTION
,AllCodes.SERVICE_LONG_DESCRIPTION
,#NotCoveredCPB.[Text]
,#NotCoveredCPB.CPT
,#NotCoveredCPB.[CPT End]
FROM
WEA_EDW.DIM.SERVICE_DIM AS AllCodes

	JOIN #NotCoveredCPB
		ON AllCodes.[STANDARDIZED_SERVICE_CODE] >= #NotCoveredCPB.CPT
		AND AllCodes.[STANDARDIZED_SERVICE_CODE] <= ISNULL( #NotCoveredCPB.[CPT End],#NotCoveredCPB.CPT )

WHERE
AllCodes.SERVICE_TYPE_NAME IN ( 'CPT-4 code', 'HCPCS code')
ORDER BY
AllCodes.STANDARDIZED_SERVICE_CODE


/**************************************************************************************************************/

IF OBJECT_ID('TEMPDB.DBO.#OtherCodesRelatedToCPB') IS NOT NULL
	BEGIN
		DROP TABLE #OtherCodesRelatedToCPB
	END;

CREATE TABLE #OtherCodesRelatedToCPB (
 [ID]		INT IDENTITY
,[CPT]		VARCHAR(MAX)
,[CPT End]	VARCHAR(MAX)
,[Text]		VARCHAR(MAX)
);

/*
1) Copy Paste
2) Find and replace 
	/t
	', NULL, '
3) Find and replace
	\r\n
	')\r\n,('
4) Clean up head and tail
5) Find and replace
	 '
	'
6) Find and replace
	','
	', NULL, '
7) Find and replace
	 -hyphen 
	', '
8) Find and replace
	'\+
	'
9) Find and replace
	'
	'
10) Find and replace
	(?<='[0-Z]{5}', '[0-Z]{5}'), NULL,
	,

*/

/* Other CPT codes related to the CPB: */

INSERT INTO #OtherCodesRelatedToCPB VALUES

 ('81400', '81408','Molecular pathology procedures')
,('96040', NULL,'Medical genetics and genetic counseling services, each 30 minutes face-hyphento-hyphenface with patient/family')

;


SELECT TOP 0 [Other CPT codes related to the CPB:] = NULL 

SELECT
 AllCodes.STANDARDIZED_SERVICE_CODE
,AllCodes.SERVICE_SHORT_DESCRIPTION
,AllCodes.SERVICE_LONG_DESCRIPTION
,#OtherCodesRelatedToCPB.[Text]
,#OtherCodesRelatedToCPB.CPT
,#OtherCodesRelatedToCPB.[CPT End]
FROM
WEA_EDW.DIM.SERVICE_DIM AS AllCodes

	JOIN #OtherCodesRelatedToCPB
		ON AllCodes.[STANDARDIZED_SERVICE_CODE] >= #OtherCodesRelatedToCPB.CPT
		AND AllCodes.[STANDARDIZED_SERVICE_CODE] <= ISNULL( #OtherCodesRelatedToCPB.[CPT End],#OtherCodesRelatedToCPB.CPT )

WHERE
AllCodes.SERVICE_TYPE_NAME IN ( 'CPT-4 code', 'HCPCS code')
ORDER BY
AllCodes.STANDARDIZED_SERVICE_CODE

/**************************************************************************************************************/

IF OBJECT_ID('TEMPDB.DBO.#HCPCSCodesCovered') IS NOT NULL
	BEGIN
		DROP TABLE #HCPCSCodesCovered
	END;

CREATE TABLE #HCPCSCodesCovered (
 [ID]		INT IDENTITY
,[CPT]		VARCHAR(MAX)
,[CPT End]	VARCHAR(MAX)
,[Text]		VARCHAR(MAX)
);

/*
1) Copy Paste
2) Find and replace 
	/t
	', NULL, '
3) Find and replace
	\r\n
	')\r\n,('
4) Clean up head and tail
5) Find and replace
	 '
	'
6) Find and replace
	','
	', NULL, '
7) Find and replace
	 -hyphen 
	', '
8) Find and replace
	'\+
	'
9) Find and replace
	'
	'
10) Find and replace
	(?<='[0-Z]{5}', '[0-Z]{5}'), NULL,
	,

*/

/* HCPCS codes covered if selection criteria are met: */

INSERT INTO #HCPCSCodesCovered VALUES

 ('S3840', NULL,'DNA analysis for germline mutations of the RET proto-hyphenoncogene for susceptibility to multiple endocrine neoplasia type 2')
,('S3841', NULL,'Genetic testing for retinoblastoma')
,('S3842', NULL,'Genetic testing for von Hippel-hyphenLindau disease')
,('S3844', NULL,'DNA analysis of the connexin 26 gene (GJB2) for susceptibility to congenital, profound deafness')
,('S3845', NULL,'Genetic testing for alpha-hyphenthalassemia')
,('S3846', NULL,'Genetic testing for hemoglobin E beta-hyphenthalassemia')
,('S3850', NULL,'Genetic testing for sickle cell anemia')
,('S3853', NULL,'Genetic testing for myotonic muscular dystrophy')
,('S3866', NULL,'Genetic analysis for a specific gene mutation for hypertrophic cardiomyopathy (HCM) in an individual with a known HCM mutation in the family')

;


SELECT TOP 0 [HCPCS codes covered if selection criteria are met:] = NULL 

SELECT
 AllCodes.STANDARDIZED_SERVICE_CODE
,AllCodes.SERVICE_SHORT_DESCRIPTION
,AllCodes.SERVICE_LONG_DESCRIPTION
,#HCPCSCodesCovered.[Text]
,#HCPCSCodesCovered.CPT
,#HCPCSCodesCovered.[CPT End]
FROM
WEA_EDW.DIM.SERVICE_DIM AS AllCodes

	JOIN #HCPCSCodesCovered
		ON AllCodes.[STANDARDIZED_SERVICE_CODE] >= #HCPCSCodesCovered.CPT
		AND AllCodes.[STANDARDIZED_SERVICE_CODE] <= ISNULL( #HCPCSCodesCovered.[CPT End],#HCPCSCodesCovered.CPT )

WHERE
AllCodes.SERVICE_TYPE_NAME IN ( 'CPT-4 code', 'HCPCS code')
ORDER BY
AllCodes.STANDARDIZED_SERVICE_CODE

/**************************************************************************************************************/

IF OBJECT_ID('TEMPDB.DBO.#HCPCSCodesNotCovered') IS NOT NULL
	BEGIN
		DROP TABLE #HCPCSCodesNotCovered
	END;

CREATE TABLE #HCPCSCodesNotCovered (
 [ID]		INT IDENTITY
,[CPT]		VARCHAR(MAX)
,[CPT End]	VARCHAR(MAX)
,[Text]		VARCHAR(MAX)
);

/*
1) Copy Paste
2) Find and replace 
	/t
	', NULL, '
3) Find and replace
	\r\n
	')\r\n,('
4) Clean up head and tail
5) Find and replace
	 '
	'
6) Find and replace
	','
	', NULL, '
7) Find and replace
	 -hyphen 
	', '
8) Find and replace
	'\+
	'
9) Find and replace
	'
	'
10) Find and replace
	(?<='[0-Z]{5}', '[0-Z]{5}'), NULL,
	,

*/

/* HCPCS codes not covered for indications listed in the CPB: */

INSERT INTO #HCPCSCodesNotCovered VALUES

 ('S3861', NULL,'Genetic testing, sodium channel, voltage-hyphengated, type V, alpha subunit (SCN5A) and variants for suspected Brugada syndrome')
,('S3865', NULL,'Comprehensive gene sequence analysis for hypertrophic cardiomyopathy')

;


SELECT TOP 0 [HCPCS codes not covered for indications listed in the CPB:] = NULL 

SELECT
 AllCodes.STANDARDIZED_SERVICE_CODE
,AllCodes.SERVICE_SHORT_DESCRIPTION
,AllCodes.SERVICE_LONG_DESCRIPTION
,#HCPCSCodesNotCovered.[Text]
,#HCPCSCodesNotCovered.CPT
,#HCPCSCodesNotCovered.[CPT End]
FROM
WEA_EDW.DIM.SERVICE_DIM AS AllCodes

	JOIN #HCPCSCodesNotCovered
		ON AllCodes.[STANDARDIZED_SERVICE_CODE] >= #HCPCSCodesNotCovered.CPT
		AND AllCodes.[STANDARDIZED_SERVICE_CODE] <= ISNULL( #HCPCSCodesNotCovered.[CPT End],#HCPCSCodesNotCovered.CPT )

WHERE
AllCodes.SERVICE_TYPE_NAME IN ( 'CPT-4 code', 'HCPCS code')
ORDER BY
AllCodes.STANDARDIZED_SERVICE_CODE

/**************************************************************************************************************/

IF OBJECT_ID('TEMPDB.DBO.#OtherHCPCSRelatedToCPB') IS NOT NULL
	BEGIN
		DROP TABLE #OtherHCPCSRelatedToCPB
	END;

CREATE TABLE #OtherHCPCSRelatedToCPB (
 [ID]		INT IDENTITY
,[CPT]		VARCHAR(MAX)
,[CPT End]	VARCHAR(MAX)
,[Text]		VARCHAR(MAX)
);

/*
1) Copy Paste
2) Find and replace 
	/t
	', NULL, '
3) Find and replace
	\r\n
	')\r\n,('
4) Clean up head and tail
5) Find and replace
	 '
	'
6) Find and replace
	','
	', NULL, '
7) Find and replace
	 -hyphen 
	', '
8) Find and replace
	'\+
	'
9) Find and replace
	'
	'
10) Find and replace
	(?<='[0-Z]{5}', '[0-Z]{5}'), NULL,
	,

*/

/* Other HCPCS codes related to the CPB: */

INSERT INTO #OtherHCPCSRelatedToCPB VALUES

 ('G0461', NULL,'Immunohistochemistry or immunocytochemistry, per specimen; first single or multiplex antibody stain')
,('G0462', NULL,'each additional single or multiplex antibody stain (list separately in addition to code for primary procedure)')
,('S0265', NULL,'Genetic counseling, under physician supervision, each 15 minutes ')
;

SELECT TOP 0 [Other HCPCS codes related to the CPB:] = NULL 

SELECT
 AllCodes.STANDARDIZED_SERVICE_CODE
,AllCodes.SERVICE_SHORT_DESCRIPTION
,AllCodes.SERVICE_LONG_DESCRIPTION
,Reference.[Text]
,Reference.CPT
,Reference.[CPT End]
FROM
WEA_EDW.DIM.SERVICE_DIM AS AllCodes

	JOIN #OtherHCPCSRelatedToCPB AS Reference
		ON AllCodes.[STANDARDIZED_SERVICE_CODE] >= Reference.CPT
		AND AllCodes.[STANDARDIZED_SERVICE_CODE] <= ISNULL( Reference.[CPT End],Reference.CPT )

WHERE
AllCodes.SERVICE_TYPE_NAME IN ( 'CPT-4 code', 'HCPCS code')
ORDER BY
AllCodes.STANDARDIZED_SERVICE_CODE

/**************************************************************************************************************/

IF OBJECT_ID('TEMPDB.DBO.#ICD10Covered') IS NOT NULL
	BEGIN
		DROP TABLE #ICD10Covered
	END;

CREATE TABLE #ICD10Covered (
 [ID]		INT IDENTITY
,[Dx]		VARCHAR(MAX)
,[Dx End]	VARCHAR(MAX)
,[Text]		VARCHAR(MAX)
);

/*
1) Copy Paste
1.5) Find and replace
	'
	''
2) Find and replace 
	/t
	', NULL, '
3) Find and replace
	\r\n
	')\r\n,('
4) Clean up head and tail
4.5) Find and replace
	\r\n,\(''\)\r\n
	\r\n
5) Find and replace
	 '
	'
6) Find and replace
	','
	', NULL, '
6.5) Find and replace (repeat until no longer found)
	' 
	'
7) Find and replace
	 -hyphen 
	', '
8) Find and replace
	\+
	
9) Find and replace
	' 
	'
10) Find and replace
	(?<='[0-Z|.]*', '[0-Z|.]*'), NULL,
	,

11) manually clean up other unstructured codes

*/

/* ICD-hyphen10 codes covered if selection criteria are met: */

INSERT INTO #ICD10Covered VALUES

 ('C16.0', 'C16.9','Malignant neoplasm of stomach [with 2 HNPCC-hyphenrelated cancers]')
,('C17.0', 'C17.9','Malignant neoplasm of small intestine [with 2 HNPCC-hyphenrelated cancers]')
,('C18.0', 'C21.8','Malignant neoplasm of colon [hereditary non-hyphenpolyposis colorectal cancer (HNPCC) (MLH1, MSH2)] [persons with serrated polyposis syndrome with at least some adenomas]')
,('C22.0', 'C22.9','Malignant neoplasm of liver and intrahepatic bile ducts [with 2 HNPCC cancers]')
,('C34.00', 'C34.92','Malignant neoplasm of bronchus and lung')
,('C40.00', 'C41.9','Malignant neoplasm of bone and articular cartilage [osteosarcoma]')
,('C49.0', 'C49.9','Malignant neoplasm of other connective and soft tissue [soft tissue sarcoma]')
,('C50.011', 'C50.929','Malignant neoplasm of breast')
,('C54.0', 'C54.9','Malignant neoplasm of corpus uteri')
,('C56.1', 'C56.9','Malignant neoplasm of ovary [with 2 HNPCC cancers]')
,('C64.1', 'C64.9','Malignant neoplasm of kidney, except pelvis [renal cell cancer syndrome]')
,('C65.1', 'C65.9','Malignant neoplasm of renal pelvis [transitional cell for microsatellite instability (MSI) testing and MLH1 and MLH2 sequence analysis for HNPCC]')
,('C66.1', 'C66.9','Malignant neoplasm of ureter [transitional cell for microsatellite instability (MSI) testing and MLH1 and MLH2 sequence analysis for HNPCC]')
,('C67.0', 'C67.9','Malignant neoplasm of bladder [transitional cell for microsatellite instability (MSI) testing and MLH1 and MLH2 sequence analysis for HNPCC]')
,('C69.20', 'C69.22','Malignant neoplasm of retina [retinoblastoma]')
,('C71.0', 'C71.9','Malignant neoplasm of brain [except glioblastoma multiforme]')
,('C73', NULL,'Malignant neoplasm of thyroid gland [medullary thyroid carcinoma] [cribriform-hyphenmorular variant of papillary thyroid cancer]')
,('C74.00', 'C74.92','Malignant neoplasm of adrenal gland [adrenocortical carcinoma]')
,('C91.00', 'C95.92','Leukemias')
,('D02.3', NULL,'Carcinoma in situ of other parts of respiratory system [hereditary leiomyomatosis]')
,('D12.2', 'D12.9','Benign neoplasm of colon [hereditary polyposis coli (APC)] [persons with serrated polyposis syndrome with at least some adenomas]')
,('D12.7', 'D12.9','Benign neoplasm of rectosigmoid junctn, rectum, anus and anal canal')
,('D35.00', 'D35.02','Benign neoplasm of adrenal gland [hereditary paraganglioma (SDHS, SDHB)]')
,('D55.21', 'D55.29','Anemia due to disorders of glycolytic enzymes [pyruvate kinase (PK) deficiency anemia]')
,('D57.3', NULL,'Sickle-hyphencell trait [hemoglobin S]')
,('D57.40', 'D57.419','Sickle-hyphencell thalassemia [alpha globin/beta globin/hemoglobin E]')
,('D58.2', NULL,'Other hemoglobinopathies [hb-hyphenC disease]')
,('D66', NULL,'Hereditary factor VIII deficiency [hemophilia A/VWF]')
,('D67', NULL,'Hereditary factor IX deficiency [hemophilia B]')
,('D68.2', NULL,'Hereditary deficiency of other clotting factors [deficiency of factor II (prothrombin), 20210A mutation]')
,('D69.42', NULL,'Congenital and hereditary thrombocytopenia purpura [amegakaryocytic]')
,('D70.0', NULL,'Congenital agranulocytosis [congenital neutropenia] [cyclic]')
,('D70.4', NULL,'Cyclic neutropenia [congenital]')
,('E11.00', 'E11.9','Type 2 diabetes mellitus [covered for maturity-hyphenonset diabetes of the young (MODY)]')
,('E23.0', NULL,'Hypopituitarism [Kallman''s syndrome] (FGFR1)')
,('E25.0', NULL,'Congenital adrenal hyperplasia')
,('E31.21', NULL,'Multiple endocrine neoplasia [MEN] type I')
,('E70.0', NULL,'Classical phenylketonuria')
,('E70.30', 'E70.39','Albinism')
,('E71.0', NULL,'Maple syrup urine disease')
,('E71.311', NULL,'Medium chain acyl CoA dehydrogenase deficiency [MCAD]')
,('E74.04', NULL,'McArdle''s disease')
,('E74.20', 'E74.29','Disorders of galactose metabolism')
,('E75.02', NULL,'Tay-hyphenSachs disease')

,('E75.21', NULL,'Other sphingolipidosis [Fabry (-hyphenAnderson, Gaucher, Niemann-hyphenPick disease (sphingomyelin phosphodiesterase)]')
,('E75.22', NULL,'Other sphingolipidosis [Fabry (-hyphenAnderson, Gaucher, Niemann-hyphenPick disease (sphingomyelin phosphodiesterase)]')
,('E75.240', NULL,'Other sphingolipidosis [Fabry (-hyphenAnderson, Gaucher, Niemann-hyphenPick disease (sphingomyelin phosphodiesterase)]')
,('E75.249', NULL,'Other sphingolipidosis [Fabry (-hyphenAnderson, Gaucher, Niemann-hyphenPick disease (sphingomyelin phosphodiesterase)]')

,('E75.29', NULL,'Other sphingolipidosis [Canavan''s disease (aspartoacylase A)]')
,('E76.01', 'E76.03','Mucopolysaccharidosis, type I [(MPS-hyphen1)]')
,('E78.01', NULL,'Familial hypercholesterolemia')
,('E83.110', NULL,'Hereditary hemochromatosis')
,('E83.40', 'E83.49','Disorders of magnesium metabolism [Gitelman''s syndrome]')
,('E83.52', NULL,'Hypercalcemia (familial hypocalciuric)')
,('E84.0', 'E84.9','Cystic fibrosis [CTFR]')
,('E85.2', NULL,'Heredofamilial amyloidosis, unspecified [hereditary amyloidosis (TTR variants)]')
,('E88.01', NULL,'Alpha-hyphen1-hyphenantitrypsin deficiency')
,('E88.41', NULL,'MELAS syndrome [mitochondrial encephalopathy (MTTL1, tRNAleu)]')
,('F70', 'F79','Intellectual disabilities')
,('F84.0', NULL,'Autistic disorder')
,('F84.2', NULL,'Rett''s syndrome [MECP2]')
,('G10', NULL,'Huntington''s disease')
,('G11.1', NULL,'Early-hyphenonset cerebellar ataxia [Friedreich''s ataxia] [frataxin]')
,('G11.3', NULL,'Cerebellar ataxia with defective DNA repair')
,('G11.4', NULL,'Hereditary spastic paraplegia [hereditary spastic paraplegia 3 (SPG3A) and 4 (SPG4, SPAST)]')
,('G11.8', NULL,'Other hereditary ataxias [spinocerebellar ataxia (ataxin, CACNA1A)]')
,('G11.9', NULL,'Hereditary ataxia, unspecified [hereditary cerebellar ataxia NOS] [spinocerebellar ataxia (ataxin, CACNA1A)] [SCA types 8, 10, 17 and DRPLA)]')

,('G12.1', NULL,'Spinal muscular atrophy [Kennedy disease (SBMA) (SMN)]')
,('G12.8', NULL,'Spinal muscular atrophy [Kennedy disease (SBMA) (SMN)]')
,('G12.9', NULL,'Spinal muscular atrophy [Kennedy disease (SBMA) (SMN)]')

,('G24.1', NULL,'Genetic torsion dystonia [primary TOR1A (DYT1)]')
,('G31.82', NULL,'Leigh''s disease')
,('G40.301', 'G40.319','Generalized idiopathic epilepsy and epileptic syndromes [nonspecific myoclonic epileptic seizures (MERRF) (MTTK) (tRNAlys)]')
,('G40.401', 'G40.419','Other generalized epilepsy and epileptic syndromes, not intractable [Dravet syndrome]')
,('G47.35', NULL,'Congenital central alveolar hypoventilation syndrome')
,('G60.0', NULL,'Hereditary motor and sensory neuropathy [Charcot-hyphenMarie-hyphenTooth disease]')

,('G71.0', NULL,'Muscular dystrophy and congenital myopathies [benign (Becker) muscular dystrophy] [limb-hyphengirdle muscular dystrophy (LGMD1, LGMD2)] [not covered for oculopharyngeal muscular dystrophy (OPMD)] [severe (Duchenne) muscular dystrophy]')
,('G71.09', NULL,'Muscular dystrophy and congenital myopathies [benign (Becker) muscular dystrophy] [limb-hyphengirdle muscular dystrophy (LGMD1, LGMD2)] [not covered for oculopharyngeal muscular dystrophy (OPMD)] [severe (Duchenne) muscular dystrophy]')
,('G71.2', NULL,'Muscular dystrophy and congenital myopathies [benign (Becker) muscular dystrophy] [limb-hyphengirdle muscular dystrophy (LGMD1, LGMD2)] [not covered for oculopharyngeal muscular dystrophy (OPMD)] [severe (Duchenne) muscular dystrophy]')

,('G71.11', 'G71.19','Myotonic disorders [myotonic dystrophy (CMPK, ZNF-hyphen9)]')
,('G72.89', NULL,'Other specified myopathies [dysferlin]')
,('G90.1', NULL,'Familial dysautonomia [Riley-hyphenDay]')
,('H35.50', NULL,'Unspecified hereditary retinal dystrophy. [bi-hyphenallelic RPE65 mutation-hyphenassociated retinal dystrophy]')
,('H35.52', NULL,'Pigmentary retinal dystrophy [retinitis pigmentosa]')
,('H47.22', NULL,'Hereditary optic atrophy [Leber''s optic atrophy (LHON)]')
,('H90.0', 'H91.93','Hearing loss [hereditary (Connexin-hyphen26, GJB2)]')
,('I11.0', 'I11.9','Hypertensive heart disease [premature CHD]')
,('I20.0', NULL,'Unstable angina [premature CHD]')
,('I20.1', 'I20.9','Angina pectoris [premature CHD]')
,('I21.01', 'I21.9','ST elevation (STEMI) and non-hyphenST elevation (NSTEMI) myocardial infarction [premature CHD]')
,('I21.A1', NULL,'Myocardial infarction type 2')
,('I21.A9', NULL,'Other myocardial infarction type')
,('I24.0', 'I24.9','Other acute ischemic heart diseases [premature CHD]')
,('I25.110', 'I25.119','Atherosclerotic heart disease of native coronary artery with angina pectoris [premature CHD]')
,('I25.2', NULL,'Old myocardial infarction [premature CHD]')
,('I25.3', NULL,'Aneurysm of heart [premature CHD]')
,('I25.41', 'I25.42','Coronary artery aneurysm and dissection [premature CHD]')
,('I25.5', NULL,'Ischemic cardiomyopathy [premature CHD]')
,('I25.6', NULL,'Silent myocardial ischemia [premature CHD]')
,('I25.700', 'I25.799','Atherosclerosis of coronary artery bypass graft(s) and coronary artery of transplanted heart with angina pectoris [premature CHD]')
,('I25.810', 'I25.9','Other forms of chronic ischemic heart disease[premature CHD]')
,('I42.1', 'I42.2','Obstructive hypertrophic and other hypertrophic cardiomyopathy')
,('I42.8', NULL,'Other cardiomyopathies [arrhythmogenic right ventricular dysplasia/cardiomyopathy (ARVD/C)] [not covered for left ventricle non compaction genetic testing]')
,('I47.2', NULL,'Ventricular tachycardia [persons that display exercise-hyphen or emotion-hypheninduced polymorphic ventricular tachycardia or ventricular fibrillation, occurring in a structurally normal heart] [catecholaminergic polymorphic]')
,('I49.01', NULL,'Ventricular fibrillation')
,('I71.01', NULL,'Dissection of thoracic aorta')
,('I78.0', NULL,'Hereditary hemorrhagic telangiectasia')
,('K62.0', 'K62.1','Anal and rectal polyp')
,('K85.00', 'K85.92','Acute pancreatitis [unexplained episode in a child requiring hospitalization with significant concern that hereditary pancreatitis (PRSS1) should be excluded]')
,('K86.1', NULL,'Other chronic pancreatitis [unexplained (idiopathic) for hereditary pancreatitis (PRSS1)]')
,('L60.3', NULL,'Nail dystrophy')
,('N04.0', 'N04.9','Nephrotic syndrome [congenital (NPHS1, NPHS2)]')
,('Q04.3', NULL,'Other reduction deformities of brain [lissencephaly (classical)] [Joubert syndrome]')
,('Q61.11', 'Q61.3','Polycystic kidney')
,('Q61.5', NULL,'Medullary cystic kidney [nephronophthisis]')
,('Q61.9', NULL,'Cystic kidney disease, unspecified [Meckel-hyphenGruber syndrome]')
,('Q75.0', 'Q75.1','Other congenital malformations of skull and face bones [craniosynostosis] [Crouzon''s disease (CTFR), Saethre-hyphenChotzen syndrome (TWIST, FGFR2)]')
,('Q77.1', NULL,'Thanatophoric short stature')
,('Q77.4', NULL,'Achondroplasia')
,('Q78.0', NULL,'Osteogenesis imperfecta')
,('Q79.6', NULL,'Ehlers-hyphenDanlos syndrome')
,('Q79.8', NULL,'Other congenital malformations of musculoskeletal system [Jackson-hyphenWeiss syndrome] [Muencke syndrome (FGFR2)]')
,('Q82.8', NULL,'Other specified congenital malformations of skin [Bloom syndrome]')
,('Q85.01', NULL,'Neurofibromatosis, type 1 [von Recklinghausen''s disease] [neurofibromin] [not covered for Legius syndrome]')
,('Q85.02', NULL,'Neurofibromatosis, type 2 [acoustic neurofibromatosis] [Merlin]')
,('Q85.8', NULL,'Other phakomatoses, not elsewhere classified [von Hippel Lindau syndrome (VHL)] [Cowden syndrome]')
,('Q87.0', NULL,'Congenital malformation syndrome predominantly affecting facial appearance [acrocephalosyndactyly] [Pfeiffer syndrome (FGFR1)]')
,('Q87.1', NULL,'Congenital malformation syndromes predominantly associated with short stature [Prader-hyphenWilli syndrome] [GABRA, SNRPN] [Noonan syndrome]')
,('Q87.40', 'Q87.43','Marfan''s syndrome')
,('Q93.51', NULL,'Angelman syndrome')
,('Q93.81', NULL,'Velo-hyphencardio-hyphenfacial syndrome [22q11 deletion syndrome (CATCH-hyphen22)]')
,('Q99.2', NULL,'Fragile X chromosome [Fragile X syndrome]')
,('R62.52', NULL,'Short stature (child) [SHOX-hyphenrelated]')
,('R74.8', NULL,'Abnormal levels of other serum enzymes [abnormal level of amylase] [hyper-hyphenamylasemia]')
,('T88.3xx', NULL,'Malignant hyperthermia due to anesthesia')
,('Z13.228', NULL,'Encounter for screening for other metabolic disorders [phenylketonuria, galactosemia] and other inborn errors of metabolism')
,('Z13.29', NULL,'Encounter for screening for other suspected endocrine disorder [thyroid]')
,('Z13.5', NULL,'Encounter for screening for eye and ear disorders')
,('Z14.01', NULL,'Asymptomatic hemophilia A carrier')
,('Z14.02', NULL,'Symptomatic hemophilia A carrier')
,('Z14.1', NULL,'Cystic fibrosis carrier')
,('Z14.8', NULL,'Genetic carrier of other disease')
,('Z15.01', NULL,'Genetic susceptibility to malignant neoplasm of breast [Li-hyphenFraumeni syndrome] [covered for Li-hyphenFraumeni syndrome testing other than OncoVue]')
,('Z31.430', NULL,'Encounter of female for testing for genetic disease carrier status for procreative management')
,('Z31.440', NULL,'Encounter of male for testing for genetic disease carrier status for procreative management')
,('Z80.0', NULL,'Family history of malignant neoplasm of digestive organs')
,('Z81.0', NULL,'Family history of intellectual disabilities')
,('Z82.0', NULL,'Family history of epilepsy and other diseases of the nervous system')
,('Z82.41', NULL,'Family history of sudden cardiac death (SCD)')
,('Z82.49', NULL,'Family history of ischemic heart disease and other diseases of the circulatory system [premature CHD]')
,('Z82.79', NULL,'Family history of other congenital malformations, deformations and chromosomal abnormalities')
,('Z83.49', NULL,'Family history of other endocrine, nutritional and metabolic diseases [first degree relative with a causative FH mutation]')
,('Z83.71', NULL,'Family history of colonic polyps [members with first-hyphendegree relatives (i.e., siblings, parents, and offspring) diagnosed with familial adenomatous polyposis (FAP) or with a documented APC mutation] [persons with first-hyphendegree relatives with a documented deleterious MUTYH mutation]')
,('Z83.79', NULL,'Family history of other diseases of the digestive system [pancreatitis]')
,('Z84.81', NULL,'Family history of genetic disease carrier')
,('Z85.030', 'Z85.038','Personal history of malignant neoplasm of large intestine [with HNPCC related cancers]')
,('Z85.040', 'Z85.048','Personal history of malignant neoplasm of rectum, rectosigmoid junction, and anus')
,('Z95.1', NULL,'Presence of aortocoronary bypass graft [premature CHD]')
,('Z95.5', NULL,'Presence of coronary angioplasty implant and graft [premature CHD]')
,('Z98.61', NULL,'Coronary angioplasty status [premature CHD]')

;

SELECT TOP 0 [ICD-hyphen10 codes covered if selection criteria are met:] = NULL 

SELECT
 AllCodes.DIAGNOSIS_STANDARD_CODE
,AllCodes.DIAGNOSIS_CODE
,AllCodes.DIAGNOSIS_SHORT_DESCRIPTION
,AllCodes.DIAGNOSIS_LONG_DESCRIPTION
,Reference.[Text]
,Reference.Dx
,Reference.[Dx End]
FROM
WEA_EDW.DIM.DIAGNOSIS_DIM AS AllCodes

	JOIN #ICD10Covered AS Reference
		ON AllCodes.DIAGNOSIS_CODE >= Reference.Dx
		AND AllCodes.DIAGNOSIS_CODE <= ISNULL( Reference.[Dx End],Reference.Dx )

WHERE
1 = 1
ORDER BY
AllCodes.[DIAGNOSIS_STANDARD_CODE]


/**************************************************************************************************************/

IF OBJECT_ID('TEMPDB.DBO.#ICD10NotCovered') IS NOT NULL
	BEGIN
		DROP TABLE #ICD10NotCovered
	END;

CREATE TABLE #ICD10NotCovered (
 [ID]		INT IDENTITY
,[Dx]		VARCHAR(MAX)
,[Dx End]	VARCHAR(MAX)
,[Text]		VARCHAR(MAX)
);

/*
1) Copy Paste
1.5) Find and replace
	'
	''
2) Find and replace 
	/t
	', NULL, '
3) Find and replace
	\r\n
	')\r\n,('
4) Clean up head and tail
4.5) Find and replace
	\r\n,\(''\)\r\n
	\r\n
5) Find and replace
	 '
	'
6) Find and replace
	','
	', NULL, '
6.5) Find and replace (repeat until no longer found)
	' 
	'
7) Find and replace
	 -hyphen 
	', '
8) Find and replace
	\+
	
9) Find and replace
	' 
	'
10) Find and replace
	(?<='[0-Z|.]*', '[0-Z|.]*'), NULL,
	,

11) manually clean up other unstructured codes

*/

/* ICD-hyphen10 codes not covered for indications listed in the CPB: */

INSERT INTO #ICD10NotCovered VALUES
 ('C43.0', 'C43.9','Malignant melanoma of skin')
,('C61', NULL,'Malignant neoplasm of prostate')
,('D37.1', 'D37.5','Neoplasm of uncertain behavior of stomach, intestines, colon and rectum [desmoid tumor]')
,('D61.01', NULL,'Constitutional (pure) red blood cell aplasia')
,('D68.0', NULL,'Von Willebrand''s disease')
,('D68.1', NULL,'Congenital factor XI deficiency [hemophilia C]')
,('D72.0', NULL,'Genetic anomalies of leukocytes')
,('E71.310', NULL,'Long chain/very long chain acyl CoA dehydrogenase deficiency')
,('E73.0', 'E73.9','Lactose intolerance')
,('E88.1', NULL,'Lipodystrophy [familial partial lipodystrophy]')
,('E88.89', NULL,'Other specified metabolic disorders [multiple mitochondrial respiratory chain complex deficiencies]')
,('F51.3', NULL,'Sleepwalking [somnambulation]')
,('G12.21', NULL,'Amyotrophic lateral sclerosis [familial (SOD1 mutation)]')
,('G20', 'G21.9','Parkinson''s disease')
,('G25.0', NULL,'Essential tremor [benign]')
,('G25.3', NULL,'Myoclonus [dystonia]')
,('G43.401', 'G43.419','Hemiplegic migraine')
,('G47.411', 'G47.429','Narcolepsy and cataplexy')
,('H35.051', 'H35.059','Retinal neovascularization')
,('H35.30', 'H35.33','Degeneration of macula')
,('H53.63', NULL,'Congenital night blindness')
,('H90.0', 'H91.93','Hearing loss')
,('I20.0', 'I20.8','Angina pectoris')
,('I21.01', 'I21.4','ST elevation (STEMI) and non-hyphenST evevation (NSTEMI) myocardial infarction')
,('I24.0', 'I25.9','Other acute and chronic forms of ischemic heart disease')
,('I25.10', 'I25.9','Chronic ischemic heart disease')
,('M81.0', 'M81.8','Osteoporosis without current pathological fracture')
,('Q24.8', NULL,'Other specified congenital malformations of heart [Brugada syndrome]')
,('Q44.6', NULL,'Cystic disease of liver')
,('Q61.11', 'Q61.3','Polycystic kidney')
,('Q76.1', NULL,'Klippel-hyphenFeil syndrome')
,('Q78.1', NULL,'Polyostotic fibrous dysplasia [Mccune-hyphenAlbright syndrome]')
,('Q80.0', 'Q80.9','Congenital ichthyosis [epidemolytic hyperkatosis]')
,('Q89.9', NULL,'Congenital malformation, unspecified [heterotaxy]')
,('R42', NULL,'Dizziness and giddiness [migrainous vertigo]')
,('R56.00', 'R56.01','Febrile convulsions')
,('Z13.6', NULL,'Encounter for screening for cardiovascular disorders')
,('Z80.3', NULL,'Family history of malignant neoplasm of breast')
;

SELECT TOP 0 [ICD-hyphen10 codes not covered for indications listed in the CPB:] = NULL 

SELECT
 AllCodes.DIAGNOSIS_STANDARD_CODE
,AllCodes.DIAGNOSIS_CODE
,AllCodes.DIAGNOSIS_SHORT_DESCRIPTION
,AllCodes.DIAGNOSIS_LONG_DESCRIPTION
,Reference.[Text]
,Reference.Dx
,Reference.[Dx End]
FROM
WEA_EDW.DIM.DIAGNOSIS_DIM AS AllCodes

	JOIN #ICD10NotCovered AS Reference
		ON AllCodes.DIAGNOSIS_CODE >= Reference.Dx
		AND AllCodes.DIAGNOSIS_CODE <= ISNULL( Reference.[Dx End],Reference.Dx )

WHERE
1 = 1
ORDER BY
AllCodes.[DIAGNOSIS_STANDARD_CODE]


/**************************************************************************************************************/

IF OBJECT_ID('TEMPDB.DBO.#ICD10NotCoveredinCPB') IS NOT NULL
	BEGIN
		DROP TABLE #ICD10NotCoveredinCPB
	END;

CREATE TABLE #ICD10NotCoveredinCPB (
 [ID]		INT IDENTITY
,[Dx]		VARCHAR(MAX)
,[Dx End]	VARCHAR(MAX)
,[Text]		VARCHAR(MAX)
);

/*
1) Copy Paste
1.5) Find and replace
	'
	''
2) Find and replace 
	/t
	', NULL, '
3) Find and replace
	\r\n
	')\r\n,('
4) Clean up head and tail
4.5) Find and replace
	\r\n,\(''\)\r\n
	\r\n
5) Find and replace
	 '
	'
6) Find and replace
	','
	', NULL, '
6.5) Find and replace (repeat until no longer found)
	' 
	'
7) Find and replace
	 -hyphen 
	', '
8) Find and replace
	\+
	
9) Find and replace
	' 
	'
10) Find and replace
	(?<='[0-Z|.]*', '[0-Z|.]*'), NULL,
	,

11) manually clean up other unstructured codes

*/

/* ICD-hyphen10 codes not covered for indications listed in the CPB (not all-hypheninclusive): */

INSERT INTO #ICD10NotCovered VALUES
 ( 'O00.00', 'O9A.519', 'Pregnancy, childbirth and the puerperium' )
;

SELECT TOP 0 [ICD-hyphen10 codes not covered for indications listed in the CPB (not all-hypheninclusive):] = NULL 

SELECT
 AllCodes.DIAGNOSIS_STANDARD_CODE
,AllCodes.DIAGNOSIS_CODE
,AllCodes.DIAGNOSIS_SHORT_DESCRIPTION
,AllCodes.DIAGNOSIS_LONG_DESCRIPTION
,Reference.[Text]
,Reference.Dx
,Reference.[Dx End]
FROM
WEA_EDW.DIM.DIAGNOSIS_DIM AS AllCodes

	JOIN #ICD10NotCoveredinCPB AS Reference
		ON AllCodes.DIAGNOSIS_CODE >= Reference.Dx
		AND AllCodes.DIAGNOSIS_CODE <= ISNULL( Reference.[Dx End],Reference.Dx )

WHERE
1 = 1
ORDER BY
AllCodes.[DIAGNOSIS_STANDARD_CODE]

/**************************************************************************************************************/

IF OBJECT_ID('TEMPDB.DBO.#ICD10CoveredSelectionCriteria') IS NOT NULL
	BEGIN
		DROP TABLE #ICD10CoveredSelectionCriteria
	END;

CREATE TABLE #ICD10CoveredSelectionCriteria (
 [ID]		INT IDENTITY
,[Dx]		VARCHAR(MAX)
,[Dx End]	VARCHAR(MAX)
,[Text]		VARCHAR(MAX)
);

/*
1) Copy Paste
1.5) Find and replace
	'
	''
2) Find and replace 
	/t
	', NULL, '
3) Find and replace
	\r\n
	')\r\n,('
4) Clean up head and tail
4.5) Find and replace
	\r\n,\(''\)\r\n
	\r\n
5) Find and replace
	 '
	'
6) Find and replace
	','
	', NULL, '
6.5) Find and replace (repeat until no longer found)
	' 
	'
7) Find and replace
	 -hyphen 
	', '
8) Find and replace
	\+
	
9) Find and replace
	' 
	'
10) Find and replace
	(?<='[0-Z|.]*', '[0-Z|.]*'), NULL,
	,

11) manually clean up other unstructured codes

*/

/* ICD-hyphen10 codes covered if selection criteria are met: */

INSERT INTO #ICD10CoveredSelectionCriteria VALUES
 ( 'I21.01', 'I22.9', 'Myocardial infarction' )
,( 'I26.01', 'I26.99', 'Pulmonary embolism' )
,( 'O22.20', 'O22.33', 'Superficial thrombophlebitis and deep phlebothrombosis in pregnancy' )
,( 'Z82.49', NULL, 'Family history of ischemic heart disease and other diseases of the circulatory' )
,( 'Z86.711', 'Z86.72', 'Personal history of venous thombosis and embolism' )
;

SELECT TOP 0 [ICD-hyphen10 codes covered if selection criteria are met:] = NULL 

SELECT
 AllCodes.DIAGNOSIS_STANDARD_CODE
,AllCodes.DIAGNOSIS_CODE
,AllCodes.DIAGNOSIS_SHORT_DESCRIPTION
,AllCodes.DIAGNOSIS_LONG_DESCRIPTION
,Reference.[Text]
,Reference.Dx
,Reference.[Dx End]
FROM
WEA_EDW.DIM.DIAGNOSIS_DIM AS AllCodes

	JOIN #ICD10CoveredSelectionCriteria AS Reference
		ON AllCodes.DIAGNOSIS_CODE >= Reference.Dx
		AND AllCodes.DIAGNOSIS_CODE <= ISNULL( Reference.[Dx End],Reference.Dx )

WHERE
1 = 1
ORDER BY
AllCodes.[DIAGNOSIS_STANDARD_CODE]

/**************************************************************************************************************/

IF OBJECT_ID('TEMPDB.DBO.#ABCA3Mutation') IS NOT NULL
	BEGIN
		DROP TABLE #ABCA3Mutation
	END;

CREATE TABLE #ABCA3Mutation (
 [ID]		INT IDENTITY
,[Dx]		VARCHAR(MAX)
,[Dx End]	VARCHAR(MAX)
,[Text]		VARCHAR(MAX)
);

/*
1) Copy Paste
1.5) Find and replace
	'
	''
2) Find and replace 
	/t
	', NULL, '
3) Find and replace
	\r\n
	')\r\n,('
4) Clean up head and tail
4.5) Find and replace
	\r\n,\(''\)\r\n
	\r\n
5) Find and replace
	 '
	'
6) Find and replace
	','
	', NULL, '
6.5) Find and replace (repeat until no longer found)
	' 
	'
7) Find and replace
	 -hyphen 
	', '
8) Find and replace
	\+
	
9) Find and replace
	' 
	'
10) Find and replace
	(?<='[0-Z|.]*', '[0-Z|.]*'), NULL,
	,

11) manually clean up other unstructured codes

*/

/* SP-hyphenC/ABCA3 mutation -hyphen no specific code: */

INSERT INTO #ABCA3Mutation VALUES
 ( 'J84.841', 'J84.848', 'Other interstitial lung diseases of childhood' )
,( 'Z83.6', NULL, 'Family history of other diseases of the respiratory system' )
;

SELECT TOP 0 [SP-hyphenC/ABCA3 mutation -hyphen no specific code:] = NULL 

SELECT
 AllCodes.DIAGNOSIS_STANDARD_CODE
,AllCodes.DIAGNOSIS_CODE
,AllCodes.DIAGNOSIS_SHORT_DESCRIPTION
,AllCodes.DIAGNOSIS_LONG_DESCRIPTION
,Reference.[Text]
,Reference.Dx
,Reference.[Dx End]
FROM
WEA_EDW.DIM.DIAGNOSIS_DIM AS AllCodes

	JOIN #ABCA3Mutation AS Reference
		ON AllCodes.DIAGNOSIS_CODE >= Reference.Dx
		AND AllCodes.DIAGNOSIS_CODE <= ISNULL( Reference.[Dx End],Reference.Dx )

WHERE
1 = 1
ORDER BY
AllCodes.[DIAGNOSIS_STANDARD_CODE]

/**************************************************************************************************************/

IF OBJECT_ID('TEMPDB.DBO.#ICD10NonCoveredAdults') IS NOT NULL
	BEGIN
		DROP TABLE #ICD10NonCoveredAdults
	END;

CREATE TABLE #ICD10NonCoveredAdults (
 [ID]		INT IDENTITY
,[Dx]		VARCHAR(MAX)
,[Dx End]	VARCHAR(MAX)
,[Text]		VARCHAR(MAX)
);

/*
1) Copy Paste
1.5) Find and replace
	'
	''
2) Find and replace 
	/t
	', NULL, '
3) Find and replace
	\r\n
	')\r\n,('
4) Clean up head and tail
4.5) Find and replace
	\r\n,\(''\)\r\n
	\r\n
5) Find and replace
	 '
	'
6) Find and replace
	','
	', NULL, '
6.5) Find and replace (repeat until no longer found)
	' 
	'
7) Find and replace
	 -hyphen 
	', '
8) Find and replace
	\+
	
9) Find and replace
	' 
	'
10) Find and replace
	(?<='[0-Z|.]*', '[0-Z|.]*'), NULL,
	,

11) manually clean up other unstructured codes

*/

/* ICD-hyphen10 codes not covered for indications listed in the CPB (not all-hypheninclusive) [for adults]: */

INSERT INTO #ICD10NonCoveredAdults VALUES
 ( 'J84.10', 'J84.83', 'Other interstitial pulmonary diseases' )
,( 'J84.89', 'J84.9', 'Other interstitial pulmonary diseases' )
;

SELECT TOP 0 [ICD-hyphen10 codes not covered for indications listed in the CPB (for adults):] = NULL 

SELECT
 AllCodes.DIAGNOSIS_STANDARD_CODE
,AllCodes.DIAGNOSIS_CODE
,AllCodes.DIAGNOSIS_SHORT_DESCRIPTION
,AllCodes.DIAGNOSIS_LONG_DESCRIPTION
,Reference.[Text]
,Reference.Dx
,Reference.[Dx End]
FROM
WEA_EDW.DIM.DIAGNOSIS_DIM AS AllCodes

	JOIN #ICD10NonCoveredAdults AS Reference
		ON AllCodes.DIAGNOSIS_CODE >= Reference.Dx
		AND AllCodes.DIAGNOSIS_CODE <= ISNULL( Reference.[Dx End],Reference.Dx )

WHERE
1 = 1
ORDER BY
AllCodes.[DIAGNOSIS_STANDARD_CODE]

/**************************************************************************************************************/

IF OBJECT_ID('TEMPDB.DBO.#ICD10NonCoveredCPBCardio') IS NOT NULL
	BEGIN
		DROP TABLE #ICD10NonCoveredCPBCardio
	END;

CREATE TABLE #ICD10NonCoveredCPBCardio (
 [ID]		INT IDENTITY
,[Dx]		VARCHAR(MAX)
,[Dx End]	VARCHAR(MAX)
,[Text]		VARCHAR(MAX)
);

/*
1) Copy Paste
1.5) Find and replace
	'
	''
2) Find and replace 
	/t
	', NULL, '
3) Find and replace
	\r\n
	')\r\n,('
4) Clean up head and tail
4.5) Find and replace
	\r\n,\(''\)\r\n
	\r\n
5) Find and replace
	 '
	'
6) Find and replace
	','
	', NULL, '
6.5) Find and replace (repeat until no longer found)
	' 
	'
7) Find and replace
	 -hyphen 
	', '
8) Find and replace
	\+
	
9) Find and replace
	' 
	'
10) Find and replace
	(?<='[0-Z|.]*', '[0-Z|.]*'), NULL,
	,

11) manually clean up other unstructured codes

*/

/* ICD-hyphen10 codes not covered for indications listed in the CPB (not all-hypheninclusive): */

INSERT INTO #ICD10NonCoveredCPBCardio VALUES
 ( 'I42.0', 'I42.9', 'Cardiomyopathy' )
,( 'I43', NULL, ' Cardiomyopathy in diseases classified elsewhere' )
;

SELECT TOP 0 [ICD-hyphen10 codes not covered for indications listed in the CPB (not all-hypheninclusive):] = NULL 

SELECT
 AllCodes.DIAGNOSIS_STANDARD_CODE
,AllCodes.DIAGNOSIS_CODE
,AllCodes.DIAGNOSIS_SHORT_DESCRIPTION
,AllCodes.DIAGNOSIS_LONG_DESCRIPTION
,Reference.[Text]
,Reference.Dx
,Reference.[Dx End]
FROM
WEA_EDW.DIM.DIAGNOSIS_DIM AS AllCodes

	JOIN #ICD10NonCoveredCPBCardio AS Reference
		ON AllCodes.DIAGNOSIS_CODE >= Reference.Dx
		AND AllCodes.DIAGNOSIS_CODE <= ISNULL( Reference.[Dx End],Reference.Dx )

WHERE
1 = 1
ORDER BY
AllCodes.[DIAGNOSIS_STANDARD_CODE]

/**************************************************************************************************************/

IF OBJECT_ID('TEMPDB.DBO.#ICD10NonCoveredCPBSeizures') IS NOT NULL
	BEGIN
		DROP TABLE #ICD10NonCoveredCPBSeizures
	END;

CREATE TABLE #ICD10NonCoveredCPBSeizures (
 [ID]		INT IDENTITY
,[Dx]		VARCHAR(MAX)
,[Dx End]	VARCHAR(MAX)
,[Text]		VARCHAR(MAX)
);

/*
1) Copy Paste
1.5) Find and replace
	'
	''
2) Find and replace 
	/t
	', NULL, '
3) Find and replace
	\r\n
	')\r\n,('
4) Clean up head and tail
4.5) Find and replace
	\r\n,\(''\)\r\n
	\r\n
5) Find and replace
	 '
	'
6) Find and replace
	','
	', NULL, '
6.5) Find and replace (repeat until no longer found)
	' 
	'
7) Find and replace
	 -hyphen 
	', '
8) Find and replace
	\+
	
9) Find and replace
	' 
	'
10) Find and replace
	(?<='[0-Z|.]*', '[0-Z|.]*'), NULL,
	,

11) manually clean up other unstructured codes

*/

/* ICD-hyphen10 codes not covered for indications listed in the CPB: */

INSERT INTO #ICD10NonCoveredCPBSeizures VALUES
 ( 'G40.001', 'G40.919', 'Epilepsy and recurrent seizures' )

;

SELECT TOP 0 [ICD-hyphen10 codes not covered for indications listed in the CPB:] = NULL 

SELECT
 AllCodes.DIAGNOSIS_STANDARD_CODE
,AllCodes.DIAGNOSIS_CODE
,AllCodes.DIAGNOSIS_SHORT_DESCRIPTION
,AllCodes.DIAGNOSIS_LONG_DESCRIPTION
,Reference.[Text]
,Reference.Dx
,Reference.[Dx End]
FROM
WEA_EDW.DIM.DIAGNOSIS_DIM AS AllCodes

	JOIN #ICD10NonCoveredCPBSeizures AS Reference
		ON AllCodes.DIAGNOSIS_CODE >= Reference.Dx
		AND AllCodes.DIAGNOSIS_CODE <= ISNULL( Reference.[Dx End],Reference.Dx )

WHERE
1 = 1
ORDER BY
AllCodes.[DIAGNOSIS_STANDARD_CODE]

/**************************************************************************************************************/

IF OBJECT_ID('TEMPDB.DBO.#ICD10NonCoveredCPBMyelodysplastic') IS NOT NULL
	BEGIN
		DROP TABLE #ICD10NonCoveredCPBMyelodysplastic
	END;

CREATE TABLE #ICD10NonCoveredCPBMyelodysplastic (
 [ID]		INT IDENTITY
,[Dx]		VARCHAR(MAX)
,[Dx End]	VARCHAR(MAX)
,[Text]		VARCHAR(MAX)
);

/*
1) Copy Paste
1.5) Find and replace
	'
	''
2) Find and replace 
	/t
	', NULL, '
3) Find and replace
	\r\n
	')\r\n,('
4) Clean up head and tail
4.5) Find and replace
	\r\n,\(''\)\r\n
	\r\n
5) Find and replace
	 '
	'
6) Find and replace
	','
	', NULL, '
6.5) Find and replace (repeat until no longer found)
	' 
	'
7) Find and replace
	 -hyphen 
	', '
8) Find and replace
	\+
	
9) Find and replace
	' 
	'
10) Find and replace
	(?<='[0-Z|.]*', '[0-Z|.]*'), NULL,
	,

11) manually clean up other unstructured codes

*/

/* ICD-hyphen10 codes not covered for indications listed in the CPB: */

INSERT INTO #ICD10NonCoveredCPBMyelodysplastic VALUES
 ( 'D46.0', 'D46.9', 'Myelodysplastic syndromes' )

;

SELECT TOP 0 [ICD-hyphen10 codes not covered for indications listed in the CPB:] = NULL 

SELECT
 AllCodes.DIAGNOSIS_STANDARD_CODE
,AllCodes.DIAGNOSIS_CODE
,AllCodes.DIAGNOSIS_SHORT_DESCRIPTION
,AllCodes.DIAGNOSIS_LONG_DESCRIPTION
,Reference.[Text]
,Reference.Dx
,Reference.[Dx End]
FROM
WEA_EDW.DIM.DIAGNOSIS_DIM AS AllCodes

	JOIN #ICD10NonCoveredCPBMyelodysplastic AS Reference
		ON AllCodes.DIAGNOSIS_CODE >= Reference.Dx
		AND AllCodes.DIAGNOSIS_CODE <= ISNULL( Reference.[Dx End],Reference.Dx )

WHERE
1 = 1
ORDER BY
AllCodes.[DIAGNOSIS_STANDARD_CODE]

/**************************************************************************************************************/

IF OBJECT_ID('TEMPDB.DBO.#ICD10NonCoveredCPBBreastCancer') IS NOT NULL
	BEGIN
		DROP TABLE #ICD10NonCoveredCPBBreastCancer
	END;

CREATE TABLE #ICD10NonCoveredCPBBreastCancer (
 [ID]		INT IDENTITY
,[Dx]		VARCHAR(MAX)
,[Dx End]	VARCHAR(MAX)
,[Text]		VARCHAR(MAX)
);

/*
1) Copy Paste
1.5) Find and replace
	'
	''
2) Find and replace 
	/t
	', NULL, '
3) Find and replace
	\r\n
	')\r\n,('
4) Clean up head and tail
4.5) Find and replace
	\r\n,\(''\)\r\n
	\r\n
5) Find and replace
	 '
	'
6) Find and replace
	','
	', NULL, '
6.5) Find and replace (repeat until no longer found)
	' 
	'
7) Find and replace
	 -hyphen 
	', '
8) Find and replace
	\+
	
9) Find and replace
	' 
	'
10) Find and replace
	(?<='[0-Z|.]*', '[0-Z|.]*'), NULL,
	,

11) manually clean up other unstructured codes

*/

/* ICD-hyphen10 codes not covered for indications listed in the CPB (not all-hypheninclusive): */

INSERT INTO #ICD10NonCoveredCPBBreastCancer VALUES
 ( 'C50.011', 'C50.929', 'Malignant neoplasm of breast' )

;

SELECT TOP 0 [ICD-hyphen10 codes not covered for indications listed in the CPB (not all-hypheninclusive):] = NULL 

SELECT
 AllCodes.DIAGNOSIS_STANDARD_CODE
,AllCodes.DIAGNOSIS_CODE
,AllCodes.DIAGNOSIS_SHORT_DESCRIPTION
,AllCodes.DIAGNOSIS_LONG_DESCRIPTION
,Reference.[Text]
,Reference.Dx
,Reference.[Dx End]
FROM
WEA_EDW.DIM.DIAGNOSIS_DIM AS AllCodes

	JOIN #ICD10NonCoveredCPBBreastCancer AS Reference
		ON AllCodes.DIAGNOSIS_CODE >= Reference.Dx
		AND AllCodes.DIAGNOSIS_CODE <= ISNULL( Reference.[Dx End],Reference.Dx )

WHERE
1 = 1
ORDER BY
AllCodes.[DIAGNOSIS_STANDARD_CODE]


/**************************************************************************************************************/

IF OBJECT_ID('TEMPDB.DBO.#ICD10CoveredHypophosphate') IS NOT NULL
	BEGIN
		DROP TABLE #ICD10CoveredHypophosphate
	END;

CREATE TABLE #ICD10CoveredHypophosphate (
 [ID]		INT IDENTITY
,[Dx]		VARCHAR(MAX)
,[Dx End]	VARCHAR(MAX)
,[Text]		VARCHAR(MAX)
);

/*
1) Copy Paste
1.5) Find and replace
	'
	''
2) Find and replace 
	/t
	', NULL, '
3) Find and replace
	\r\n
	')\r\n,('
4) Clean up head and tail
4.5) Find and replace
	\r\n,\(''\)\r\n
	\r\n
5) Find and replace
	 '
	'
6) Find and replace
	','
	', NULL, '
6.5) Find and replace (repeat until no longer found)
	' 
	'
7) Find and replace
	 -hyphen 
	', '
8) Find and replace
	\+
	
9) Find and replace
	' 
	'
10) Find and replace
	(?<='[0-Z|.]*', '[0-Z|.]*'), NULL,
	,

11) manually clean up other unstructured codes

*/

/* ICD-hyphen10 codes covered if selection criteria are met: */

INSERT INTO #ICD10CoveredHypophosphate VALUES
 ( 'E83.30', 'E83.39', 'Disorders of phosphorus metabolism and phosphatases [hypophosphatasia]' )

;

SELECT TOP 0 [ICD-hyphen10 codes covered if selection criteria are met:] = NULL 

SELECT
 AllCodes.DIAGNOSIS_STANDARD_CODE
,AllCodes.DIAGNOSIS_CODE
,AllCodes.DIAGNOSIS_SHORT_DESCRIPTION
,AllCodes.DIAGNOSIS_LONG_DESCRIPTION
,Reference.[Text]
,Reference.Dx
,Reference.[Dx End]
FROM
WEA_EDW.DIM.DIAGNOSIS_DIM AS AllCodes

	JOIN #ICD10CoveredHypophosphate AS Reference
		ON AllCodes.DIAGNOSIS_CODE >= Reference.Dx
		AND AllCodes.DIAGNOSIS_CODE <= ISNULL( Reference.[Dx End],Reference.Dx )

WHERE
1 = 1
ORDER BY
AllCodes.[DIAGNOSIS_STANDARD_CODE]

/**************************************************************************************************************/

IF OBJECT_ID('TEMPDB.DBO.#ICD10CoveredSyndromes') IS NOT NULL
	BEGIN
		DROP TABLE #ICD10CoveredSyndromes
	END;

CREATE TABLE #ICD10CoveredSyndromes (
 [ID]		INT IDENTITY
,[Dx]		VARCHAR(MAX)
,[Dx End]	VARCHAR(MAX)
,[Text]		VARCHAR(MAX)
);

/*
1) Copy Paste
1.5) Find and replace
	'
	''
2) Find and replace 
	/t
	', NULL, '
3) Find and replace
	\r\n
	')\r\n,('
4) Clean up head and tail
4.5) Find and replace
	\r\n,\(''\)\r\n
	\r\n
5) Find and replace
	 '
	'
6) Find and replace
	','
	', NULL, '
6.5) Find and replace (repeat until no longer found)
	' 
	'
7) Find and replace
	 -hyphen 
	', '
8) Find and replace
	\+
	
9) Find and replace
	' 
	'
10) Find and replace
	(?<='[0-Z|.]*', '[0-Z|.]*'), NULL,
	,

11) manually clean up other unstructured codes

*/

/* ICD-hyphen10 codes covered if selection criteria are met: */

INSERT INTO #ICD10CoveredSyndromes VALUES
 ( 'E34.50', 'E34.52', 'Androgen insensitivity syndrome' )
,( 'G12.0', 'G12.9', 'Spinal muscular atrophy and related syndromes [Kennedy disease]' )

;

SELECT TOP 0 [ICD-hyphen10 codes covered if selection criteria are met:] = NULL 

SELECT
 AllCodes.DIAGNOSIS_STANDARD_CODE
,AllCodes.DIAGNOSIS_CODE
,AllCodes.DIAGNOSIS_SHORT_DESCRIPTION
,AllCodes.DIAGNOSIS_LONG_DESCRIPTION
,Reference.[Text]
,Reference.Dx
,Reference.[Dx End]
FROM
WEA_EDW.DIM.DIAGNOSIS_DIM AS AllCodes

	JOIN #ICD10CoveredSyndromes AS Reference
		ON AllCodes.DIAGNOSIS_CODE >= Reference.Dx
		AND AllCodes.DIAGNOSIS_CODE <= ISNULL( Reference.[Dx End],Reference.Dx )

WHERE
1 = 1
ORDER BY
AllCodes.[DIAGNOSIS_STANDARD_CODE]

/**************************************************************************************************************/

IF OBJECT_ID('TEMPDB.DBO.#ICD10CoveredEpilepsy') IS NOT NULL
	BEGIN
		DROP TABLE #ICD10CoveredEpilepsy
	END;

CREATE TABLE #ICD10CoveredEpilepsy (
 [ID]		INT IDENTITY
,[Dx]		VARCHAR(MAX)
,[Dx End]	VARCHAR(MAX)
,[Text]		VARCHAR(MAX)
);

/*
1) Copy Paste
1.5) Find and replace
	'
	''
2) Find and replace 
	/t
	', NULL, '
3) Find and replace
	\r\n
	')\r\n,('
4) Clean up head and tail
4.5) Find and replace
	\r\n,\(''\)\r\n
	\r\n
5) Find and replace
	 '
	'
6) Find and replace
	','
	', NULL, '
6.5) Find and replace (repeat until no longer found)
	' 
	'
7) Find and replace
	 -hyphen 
	', '
8) Find and replace
	\+
	
9) Find and replace
	' 
	'
10) Find and replace
	(?<='[0-Z|.]*', '[0-Z|.]*'), NULL,
	,

11) manually clean up other unstructured codes

*/

/* ICD-hyphen10 codes covered if selection criteria are met: */

INSERT INTO #ICD10CoveredEpilepsy VALUES
 ( 'G40.301', 'G40.319', 'Generalized idiopathic epilepsy and epileptic syndromes [Unverricht-hyphenLundborg disease]' )
;

SELECT TOP 0 [ICD-hyphen10 codes covered if selection criteria are met:] = NULL 

SELECT
 AllCodes.DIAGNOSIS_STANDARD_CODE
,AllCodes.DIAGNOSIS_CODE
,AllCodes.DIAGNOSIS_SHORT_DESCRIPTION
,AllCodes.DIAGNOSIS_LONG_DESCRIPTION
,Reference.[Text]
,Reference.Dx
,Reference.[Dx End]
FROM
WEA_EDW.DIM.DIAGNOSIS_DIM AS AllCodes

	JOIN #ICD10CoveredEpilepsy AS Reference
		ON AllCodes.DIAGNOSIS_CODE >= Reference.Dx
		AND AllCodes.DIAGNOSIS_CODE <= ISNULL( Reference.[Dx End],Reference.Dx )

WHERE
1 = 1
ORDER BY
AllCodes.[DIAGNOSIS_STANDARD_CODE]

/**************************************************************************************************************/

IF OBJECT_ID('TEMPDB.DBO.#ICD10CoveredCorneal') IS NOT NULL
	BEGIN
		DROP TABLE #ICD10CoveredCorneal
	END;

CREATE TABLE #ICD10CoveredCorneal (
 [ID]		INT IDENTITY
,[Dx]		VARCHAR(MAX)
,[Dx End]	VARCHAR(MAX)
,[Text]		VARCHAR(MAX)
);

/*
1) Copy Paste
1.5) Find and replace
	'
	''
2) Find and replace 
	/t
	', NULL, '
3) Find and replace
	\r\n
	')\r\n,('
4) Clean up head and tail
4.5) Find and replace
	\r\n,\(''\)\r\n
	\r\n
5) Find and replace
	 '
	'
6) Find and replace
	','
	', NULL, '
6.5) Find and replace (repeat until no longer found)
	' 
	'
7) Find and replace
	 -hyphen 
	', '
8) Find and replace
	\+
	
9) Find and replace
	' 
	'
10) Find and replace
	(?<='[0-Z|.]*', '[0-Z|.]*'), NULL,
	,

11) manually clean up other unstructured codes

*/

/* ICD-hyphen10 codes covered if selection criteria are met: */

INSERT INTO #ICD10CoveredCorneal VALUES
 ( 'H18.50', 'H18.59', 'Hereditary corneal dystrophies' )
;

SELECT TOP 0 [ICD-hyphen10 codes covered if selection criteria are met:] = NULL 

SELECT
 AllCodes.DIAGNOSIS_STANDARD_CODE
,AllCodes.DIAGNOSIS_CODE
,AllCodes.DIAGNOSIS_SHORT_DESCRIPTION
,AllCodes.DIAGNOSIS_LONG_DESCRIPTION
,Reference.[Text]
,Reference.Dx
,Reference.[Dx End]
FROM
WEA_EDW.DIM.DIAGNOSIS_DIM AS AllCodes

	JOIN #ICD10CoveredCorneal AS Reference
		ON AllCodes.DIAGNOSIS_CODE >= Reference.Dx
		AND AllCodes.DIAGNOSIS_CODE <= ISNULL( Reference.[Dx End],Reference.Dx )

WHERE
1 = 1
ORDER BY
AllCodes.[DIAGNOSIS_STANDARD_CODE]
