# Initial data imports (Uniref functions, Metadata), cleaning, phyloseq object, diversities, 
# and constrained correspondence Analysis (CCA)

# Script from Craig L. and Shawn P.

#########################
#
# CF Hackathon - Functions - MinION data, etc ...
# Mar-2023
#
#########################

# record library and version info
.libPaths() # "/Library/Frameworks/R.framework/Versions/4.2/Resources/library"

R.Version()
# "R version 4.2.2 (2022-10-31)"
citation()
# R Core Team (2020). R: A language and environment for statistical computing. R Foundation for Statistical Computing, Vienna, Austria. URL
# https://www.R-project.org/.

#### Load pkgs ####
library(readxl); packageVersion("readxl") # '1.4.1'
library(plyr); packageVersion("plyr") # '1.8.8'
library(dplyr); packageVersion("dplyr") # '1.0.10'
library(vegan);packageVersion("vegan") # '2.6.4'
library(phyloseq); packageVersion("phyloseq") # '1.42.0'
library(ggplot2); packageVersion("ggplot2") # '3.4.0'
library(grid); packageVersion("grid") #  '4.2.2'
library(reshape2); packageVersion("reshape2") # '1.4.4'
library(tidyr); packageVersion("tidyr") # '1.2.1'
library(ggforce); packageVersion("ggforce") # '0.4.1'
library(ggrepel); packageVersion("ggrepel") # '0.9.2'

library(stringdist); packageVersion("stringdist") # ‘0.9.10’
library(stringr); packageVersion("stringr") # ‘1.5.0’
library(doParallel); packageVersion("doParallel") # '1.0.17'

#library(zCompositions); packageVersion("zCompositions") # '1.4.0.1'
#library(propr); packageVersion("propr") # '4.2.6'

library(RColorBrewer); packageVersion("RColorBrewer") # '1.1.3'
library(ggpp); packageVersion("ggpp") # ‘0.5.0’ # https://cran.r-project.org/web/packages/ggpp/vignettes/grammar-extensions.html

library(corrplot)                  ;packageVersion("corrplot") #  '0.92'
library(caret)                     ;packageVersion("caret") # '6.0.93'
library(MASS)                     ;packageVersion("MASS") # ‘7.3.58.1’
library(ggsignif); packageVersion("ggsignif") # '0.6.4'
library(moments)                  ;packageVersion("moments") # ‘0.14.1’
library(ANCOMBC); packageVersion("ANCOMBC") # ‘2.0.1’
library(grDevices); packageVersion("grDevices") #  '4.2.2'
library(ggbiplot); packageVersion("ggbiplot") #  ‘0.55’
library(viridis); packageVersion("viridis") #  ‘0.6.2’

library(FSA); packageVersion("FSA") # '0.9.3'
library(rcompanion); packageVersion("rcompanion") # '2.4.18'


# up to line ...


######## Set WD ####
##save.image("/Users/lidd0026/WORKSPACE/PROJ/CFHackathon2023-FAME/Fxns_minion/WORKSPACE-v2.RData")
##      load("/Users/lidd0026/WORKSPACE/PROJ/CFHackathon2023-FAME/Fxns_minion/WORKSPACE-v2.RData")
#########################

workdir <- "/Users/pedd0011/Documents/et.al.MS's/CF.Hackathon"
setwd(workdir)
getwd() # "/Users/pedd0011/Library/CloudStorage/Dropbox/Mac/Documents/et.al.MS's/CF.Hackathon"


par.default <- par()




#### Patient Metadata ####

#### read in patient metadata

meta <- read_excel("/Users/pedd0011/Documents/et.al.MS's/CF.Hackathon/CF_Metadata_Table.xlsx",
                   sheet=1, range="A1:AK164", col_names = TRUE)
meta <- as.data.frame(meta)
str(meta)

row.names(meta) <- meta$unique_ID

names(meta)
# [1] "unique_ID"              "Patient"                "Date"                  
# [4] "IP vs OP"               "Hospital"               "Room"                  
# [7] "Age"                    "Age groups"             "Paediatric vs Adult"   
# [10] "Gender"                 "H2_Uncorrected"         "CH4_Uncorrected"       
# [13] "CO2"                    "H2_Corrected"           "CH4_Corrected"         
# [16] "CH4/H2 ratio_corrected" "Corr."                  "Antibiotics_YN"        
# [19] "Antibiotics (duration)" "Culture Result"         "NTM"                   
# [22] "Previous 12 months"     "Others"                 "IgE"                   
# [25] "Spec IgE"               "Spec IgG"               "Precipitins"           
# [28] "FVC"                    "FEV1"                   "Best FEV1"             
# [31] "FEV1/best FEV1"         "CFRD"                   "PI"                    
# [34] "CF gene 1"              "CF gene 2"              "Notes"                 
# [37] "CFLD" 


# change these to numeric

vars_to_numeric <- c(
  "H2_Uncorrected"   ,      "CH4_Uncorrected"   ,    
  "CO2"              ,      "H2_Corrected"      ,     "CH4_Corrected"  ,       
  "CH4/H2 ratio_corrected", "Corr."      ,           
  "IgE"   ,                
  "Spec IgE"    ,           "Spec IgG"      ,         "Precipitins"    ,       
  "FVC"           ,         "FEV1"    
  
)

meta[ ,vars_to_numeric] <- lapply(X = meta[ ,vars_to_numeric], FUN = as.numeric)

str(meta)
# 'data.frame':	163 obs. of  37 variables:
# $ unique_ID             : chr  "623361_20180123_S" "634207_20180510_S" "634207_20180517_S" "639354_20171206_S" ...
# $ Patient               : num  623361 634207 634207 639354 639354 ...
# $ Date                  : POSIXct, format: "2018-01-23" "2018-05-10" ...
# $ IP vs OP              : chr  "OP" "IP" "IP" "IP" ...
# $ Hospital              : chr  "RAH" "WCH" "WCH" "WCH" ...
# $ Room                  : chr  "Chest Clinic 9" "Adol Rm9" "Adol Rm9" "Adolescent 10" ...
# $ Age                   : num  18 17 17 17 17 17 17 17 16 16 ...
# $ Age groups            : num  4 3 3 3 3 3 3 3 3 3 ...
# $ Paediatric vs Adult   : chr  "Adult" "Paediatric" "Paediatric" "Paediatric" ...
# $ Gender                : chr  "M" "F" "F" "F" ...
# $ H2_Uncorrected        : num  6 39 26 10 9 22 31 3 11 14 ...
# $ CH4_Uncorrected       : num  2 15 10 2 2 8 5 1 2 2 ...
# $ CO2                   : num  4.1 4.2 4 3.6 3.5 3.8 4.2 4 3.6 3.8 ...
# $ H2_Corrected          : num  8 50 36 15 14 32 40 4 17 20 ...
# $ CH4_Corrected         : num  3 19 14 3 3 12 7 1 3 3 ...
# $ CH4/H2 ratio_corrected: num  0.375 0.38 0.389 0.2 0.214 ...
# $ Corr.                 : num  1.34 1.27 1.37 1.52 1.57 1.44 1.3 1.48 1.52 1.44 ...
# $ Antibiotics_YN        : chr  "0" "1" "1" "1" ...
# $ Antibiotics (duration): chr  "No antibiotics for >2/12" "Yes (IV tobramycin/? For 1/7)" "Yes (IV tobramycin/? For 8/7)" "IV tob (x1 dose)" ...
# $ Culture Result        : chr  "P. aeruginosa (mucoid), S. maltophilia, A. fumigatus, oral flora" "Oral flora; Aspergillus flavus" "Oral flora; Aspergillus flavus" "P. aeruginosa (mucoid)" ...
# $ NTM                   : chr  "0" "0" "0" "0" ...
# $ Previous 12 months    : chr  "2; 6; 10" "1; 6; 11" "1; 6; 11" "2" ...
# $ Others                : chr  NA "Penicillium; Enterobacter cloacae" "Penicillium; Enterobacter cloacae" NA ...
# $ IgE                   : num  NA 1750 NA 107 NA NA 11 NA NA 175 ...
# $ Spec IgE              : num  NA 31 NA 4.7 NA NA 0 NA NA 1.9 ...
# $ Spec IgG              : num  NA 122 NA NA NA NA NA NA NA NA ...
# $ Precipitins           : num  NA 1 NA 2 NA NA 1 NA NA 1 ...
# $ FVC                   : num  92 87 84 85 94 92 83 87 89 90 ...
# $ FEV1                  : num  84 79 79 53 69 91 86 89 86 87 ...
# $ Best FEV1             : num  89 94 94 77 77 91 87 89 98 96 ...
# $ FEV1/best FEV1        : num  0.944 0.84 0.84 0.688 0.896 ...
# $ CFRD                  : num  0 2 2 0 0 0 1 1 2 2 ...
# $ PI                    : num  1 0 0 0 0 1 1 1 1 1 ...
# $ CF gene 1             : chr  "F508" "F508" "F508" "F508" ...
# $ CF gene 2             : chr  "F508" "A455" "A455" "p.Arg851" ...
# $ Notes                 : chr  NA "2 week admission for acute on chronic bronchitis" "2 week admission for acute on chronic bronchitis" "2 week admission for 25% decline in PFT" ...
# $ CFLD                  : chr  "0" "0" "0" "0" ...

plot(meta$`Age groups`, meta$FEV1)
plot(meta$`Age groups`, meta$`FEV1/best FEV1`)
plot(meta$`Age groups`, meta$`CH4/H2 ratio_corrected`)



## later need to subselect only those sample IDs that occur in our MinION data
## e.g. select on names(fxns) that match up to row.names(meta)
## some trimming will be needed
## e.g. this format: "X658355_20171204" ... vs this format: "1845116_20180403_S" 

#sel <- which(names(fxns) %in% row.names(meta))


names(meta)

# keyvars <- c(
#   "IP vs OP"           , #   "Hospital"             ,  "Room"        ,          
#   #"Age"                 ,   
#   #"Paediatric vs Adult"   ,
#   "Gender"               ,    
#   "H2_Corrected"        ,   "CH4_Corrected"   ,      
#   "CH4/H2 ratio_corrected", # "Corr."      ,           
#   "Antibiotics_YN"   ,     
#   # "Culture Result"     ,    
#   "NTM"            ,       
#   "IgE"                  , 
#   "Spec IgE"          ,     "Spec IgG"     ,          "Precipitins"    ,       
#   "FEV1"              ,
#   "FEV1/best FEV1"    # ,    "CFRD"        ,           "PI"    ,                
#   #"CF gene 1"         ,     "CF gene 2"    ,            
#   #"CFLD" 
# )
# keyvars
# # [1] "IP vs OP"               "Gender"                
# # [3] "H2_Corrected"           "CH4_Corrected"         
# # [5] "CH4/H2 ratio_corrected" "Antibiotics_YN"        
# # [7] "NTM"                    "IgE"                   
# # [9] "Spec IgE"               "Spec IgG"              
# # [11] "Precipitins"            "FEV1"                  
# # [13] "FEV1/best FEV1"  
# 
# length(keyvars) # 13
# 
# meta.melt <- melt(meta, id.vars = c("unique_ID", "Patient", "Age groups"))
# # Using sample, age_category, site_name, city, year_planted, restoration_status as id variables
# 
# names(meta.melt)
# # "unique_ID"  "Patient"    "Age groups" "variable"   "value"
# 
# sel.plot <- which(meta.melt$variable %in% keyvars)
# 
# p <- ggplot( meta.melt[sel.plot, ], aes(x = `Age groups`, y = value )) +
#   #geom_boxplot()+
#   geom_point() +
#   #geom_boxplot(outlier.shape = NA)+
#   #geom_jitter(size=1.5,width = 0.15, alpha=0.25) +
#   facet_wrap(facets = vars(variable), nrow = 2, scales = "free")+
#   theme_bw()+
#   theme(
#     #axis.text.x  = element_text(angle=30, hjust=1, vjust = 1),
#     
#     panel.grid.major = element_blank(),
#     panel.grid.minor = element_blank(),
#     
#     strip.text = element_text(size = rel(0.7)),
#     #strip.text.y = element_text(size = rel(1.1)),
#     strip.background = element_blank()
#     )
# 
# p
# 
# #grid.text(label = "(a)", x = unit(0.03, "npc") , y = unit(0.97,"npc"), gp=gpar(fontsize=15, fontface="bold") )
# 
# dev.print(tiff, file = paste0(workdir,"/plots/","metadata-values.tiff"), width = 22, height = 22, units = "cm", res=600, compression="lzw", type = "cairo")




#### Fxn Minion - Read in Functions ####


# need to prepare:
# - OTU table
# - TAX table
# - metadata sample table



# raw <- read.csv(file = "/Users/lidd0026/WORKSPACE/PROJ/CFHackathon2023-FAME/Fxns_minion/10sample_uniref50counts_with_SEED.tsv", 
#                      header = TRUE, sep = "\t")

raw <- read.csv(file = "/Users/pedd0011/Documents/et.al.MS's/CF.Hackathon/all_minion_sample_uniref50counts_with_SEED.tsv", 
                header = TRUE, sep = "\t")

dim(raw) # 395195     66
length(unique(raw$X)) # 395195
row.names(raw) <- raw$X
raw <- raw[ ,-1]

names(raw)
names(raw) <- gsub(pattern = "_S_(.+)nooverlap", replacement = "", x = names(raw))
names(raw)
names(raw) <- gsub(pattern = "X", replacement = "", x = names(raw))
names(raw)
# [1] "1068841_20180306" "1112926_20171212" "1128691_20171218" "1128691_20180116" "1255498_20171212"
# [6] "1282052_20180206" "1316935_20180417" "1316979_20171215" "1447437_20171006" "1470026_20180502"
# [11] "1565754_20171128" "1565754_20180403" "1586713_20180309" "1593967_20180424" "1593973_20180427"
# [16] "1593973_20180504" "1598281_20180508" "1651490_20171010" "1651490_20180206" "1834617_20180501"
# [21] "1845116_20180403" "623361_20180123"  "639354_20171206"  "650003_20180207"  "658355_20171204" 
# [26] "658355_20180122"  "658355_20180321"  "673895_20180122"  "673895_20180205"  "676138_20180130" 
# [31] "698917_20171207"  "698917_20180128"  "698917_20190119"  "715927_20180205"  "748160_20180321" 
# [36] "748160_20180329"  "748699_20180329"  "748699_20180410"  "752797_20170927"  "753522_20180606" 
# [41] "756934_20181218"  "763742_20180129"  "768745_20171123"  "770590_20170925"  "770590_20180115" 
# [46] "778851_20171204"  "785991_20171129"  "785991_20171206"  "785991_20180321"  "788707_20171213" 
# [51] "788707_20180301"  "788707_20180313"  "788707_20181116"  "802971_20180605"  "825012_20181120" 
# [56] "825012_20181126"  "892355_20180123"  "895293_20180502"  "983493_20180123"  "FIG_function"    
# [61] "Uniref.function"  "Subsystem"        "Subclass"         "Class"            "Superclass"

( nreads0 <- length(unique(row.names(raw))) ) # 395195
length(unique(raw$FIG_function)) # 10666
length(unique(raw$Uniref.function)) # 53685
length(unique(raw$Subsystem)) # 578
length(unique(raw$Subclass)) # 111
length(unique(raw$Class)) # 32
length(unique(raw$Superclass)) # 15



fxns <- raw[ ,sort( c("1068841_20180306", "1112926_20171212", "1128691_20171218", "1128691_20180116" ,"1255498_20171212",
                      "1282052_20180206", "1316935_20180417", "1316979_20171215", "1447437_20171006" ,"1470026_20180502",
                      "1565754_20171128", "1565754_20180403", "1586713_20180309", "1593967_20180424" ,"1593973_20180427",
                      "1593973_20180504", "1598281_20180508", "1651490_20171010", "1651490_20180206" ,"1834617_20180501",
                      "1845116_20180403", "623361_20180123" , "639354_20171206" , "650003_20180207"  ,"658355_20171204" ,
                      "658355_20180122" , "658355_20180321" , "673895_20180122" , "673895_20180205"  ,"676138_20180130" ,
                      "698917_20171207" , "698917_20180128" , "698917_20190119" , "715927_20180205"  ,"748160_20180321" ,
                      "748160_20180329" , "748699_20180329" , "748699_20180410" , "752797_20170927"  ,"753522_20180606" ,
                      "756934_20181218" , "763742_20180129" , "768745_20171123" , "770590_20170925"  ,"770590_20180115" ,
                      "778851_20171204" , "785991_20171129" , "785991_20171206" , "785991_20180321"  ,"788707_20171213" ,
                      "788707_20180301" , "788707_20180313" , "788707_20181116" , "802971_20180605"  ,"825012_20181120" ,
                      "825012_20181126" , "892355_20180123" , "895293_20180502" , "983493_20180123" 
                      
)) ]

names(fxns)
str(fxns)
# 'data.frame':	395195 obs. of  59 variables:
#   $ 1068841_20180306: num  181 25 13 3 2 1 323 81 225 40 ...
# $ 1112926_20171212: num  43 0 3 1 1 1 30 11 43 12 ...
# $ 1128691_20171218: num  0 0 0 0 0 0 0 0 0 0 ...
# $ 1128691_20180116: num  0 0 0 0 0 0 0 0 0 0 ...
# $ 1255498_20171212: num  868 30 17 6 5 0 287 225 662 92 ...
# $ 1282052_20180206: num  113 2 0 0 0 0 73 18 68 37 ...
# $ 1316935_20180417: num  138 3 1 1 1 0 106 42 93 16 ...
# $ 1316979_20171215: num  83 40 0 0 0 0 65 36 124 15 ...
# $ 1447437_20171006: num  859 5 3 4 0 0 543 195 669 112 ...
# $ 1470026_20180502: num  4 0 0 2 0 0 14 5 7 0 ...
# $ 1565754_20171128: num  6 2 0 0 0 0 5 0 4 1 ...
# $ 1565754_20180403: num  12 0 0 0 0 0 1 22 54 10 ...
# $ 1586713_20180309: num  734 49 0 0 0 0 434 107 335 53 ...
# $ 1593967_20180424: num  161 23 1 0 0 0 262 102 274 49 ...
# $ 1593973_20180427: num  253 7 0 1 0 0 7 40 118 17 ...
# $ 1593973_20180504: num  492 2 0 0 0 0 211 122 353 61 ...
# $ 1598281_20180508: num  196 43 0 0 0 0 143 64 185 21 ...
# $ 1651490_20171010: num  28 11 2 0 0 0 18 5 18 8 ...
# $ 1651490_20180206: num  13 1 0 0 0 0 4 3 9 14 ...
# $ 1834617_20180501: num  262 8 0 0 0 0 50 96 196 53 ...
# $ 1845116_20180403: num  86 10 0 0 0 0 109 41 95 22 ...
# $ 623361_20180123 : num  486 75 26 4 0 0 124 131 348 59 ...
# $ 639354_20171206 : num  38 14 0 0 0 0 30 19 44 7 ...
# $ 650003_20180207 : num  0 0 0 0 0 0 0 0 0 0 ...
# $ 658355_20171204 : num  528 26 0 0 0 0 51 134 466 62 ...
# $ 658355_20180122 : num  883 61 0 0 0 0 497 144 448 71 ...
# $ 658355_20180321 : num  625 7 0 0 0 0 218 75 271 43 ...
# $ 673895_20180122 : num  39 7 0 0 0 0 0 8 11 1 ...
# $ 673895_20180205 : num  0 2 0 0 0 0 0 1 5 0 ...
# $ 676138_20180130 : num  60 1 0 0 0 0 48 32 149 20 ...
# $ 698917_20171207 : num  119 0 0 2 0 0 50 17 42 5 ...
# $ 698917_20180128 : num  0 0 0 0 0 0 1 0 0 1 ...
# $ 698917_20190119 : num  3 0 0 0 0 0 0 2 0 0 ...
# $ 715927_20180205 : num  79 16 4 0 0 0 25 22 83 11 ...
# $ 748160_20180321 : num  0 4 0 0 0 0 26 26 61 13 ...
# $ 748160_20180329 : num  0 0 0 0 0 0 6 1 4 2 ...
# $ 748699_20180329 : num  294 43 0 0 0 0 283 102 239 50 ...
# $ 748699_20180410 : num  224 0 0 0 0 0 109 57 139 20 ...
# $ 752797_20170927 : num  0 0 0 0 0 0 0 2 0 0 ...
# $ 753522_20180606 : num  109 34 0 0 0 0 131 59 94 12 ...
# $ 756934_20181218 : num  198 38 0 0 0 0 256 117 436 76 ...
# $ 763742_20180129 : num  155 2 0 0 0 0 98 57 132 18 ...
# $ 768745_20171123 : num  138 0 0 0 0 0 31 26 54 5 ...
# $ 770590_20170925 : num  0 26 35 10 5 0 24 15 48 9 ...
# $ 770590_20180115 : num  1066 60 8 1 0 ...
# $ 778851_20171204 : num  51 0 1 0 0 0 106 44 131 15 ...
# $ 785991_20171129 : num  185 4 0 0 0 0 53 5 37 7 ...
# $ 785991_20171206 : num  144 9 0 0 0 0 35 21 78 10 ...
# $ 785991_20180321 : num  427 1 66 24 12 3 163 71 201 33 ...
# $ 788707_20171213 : num  177 1 0 0 0 0 145 104 152 24 ...
# $ 788707_20180301 : num  284 0 0 0 0 0 262 110 195 31 ...
# $ 788707_20180313 : num  139 0 0 0 0 0 117 61 105 27 ...
# $ 788707_20181116 : num  348 10 0 0 0 0 199 88 269 38 ...
# $ 802971_20180605 : num  34 32 0 0 0 0 55 19 84 12 ...
# $ 825012_20181120 : num  48 0 0 0 0 0 59 38 135 25 ...
# $ 825012_20181126 : num  17 0 0 0 0 0 669 178 648 104 ...
# $ 892355_20180123 : num  10 0 0 0 0 0 6 2 11 12 ...
# $ 895293_20180502 : num  399 168 44 13 5 0 31 266 405 53 ...
# $ 983493_20180123 : num  136 19 0 0 0 0 54 63 113 18 ...


length(unique(raw$FIG_function)) # 10666
length(unique(raw$Uniref.function)) # 53685
length(unique(raw$Subsystem)) # 578
length(unique(raw$Subclass)) # 111
length(unique(raw$Class)) # 32
length(unique(raw$Superclass)) # 15

tax <- raw[ ,c("Superclass" , # 15
               "Class", # 32
               "Subclass", # 111
               "Subsystem", # 578
               "FIG_function", # 10666
               "Uniref.function"  )] # 53685


#### Tidy Data ####
## cells with missing data across all functional annotation 
## do not play nicely with phyloseq

sel.missing <- which(is.na(tax[]), arr.ind = TRUE)
length(sel.missing) # 0

sel.missing <- which(tax[]=="", arr.ind = TRUE)
length(sel.missing) # 723036

tax[sel.missing] <- NA

ok <- complete.cases(tax)
sel.ok <- which(ok==TRUE)
length(sel.ok) # 334942

100*length(sel.ok)/nreads0 # 84.7536 % retained
100 - 100*length(sel.ok)/nreads0 # 15.2464 % of reads have no functional annotation & were excluded

tax.clean <- tax[sel.ok, ]

# also clean fxns table

identical(row.names(tax), row.names(fxns)) # TRUE

fxns.clean <- fxns[sel.ok, ]



dim(tax.clean) # 334942      6

nreads1 <- dim(tax.clean)[1]



unique( tax.clean$Superclass )
# [1] "unknown"                             "Protein processing"                 
# [3] "RNA processing"                      "Energy"                             
# [5] "Dna processing"                      "Stress response, defense, virulence"
# [7] "Metabolism"                          "Membrane transport"                 
# [9] "Cellular processes"                  "Regulation and cell signaling"      
# [11] "DNA processing"                      "Rna processing"                     
# [13] "Cell envelope"                       "Miscellaneous" 

unique( tax.clean$Class )
# [1] "unknown"                                                      "Protein Synthesis"                                           
# [3] "RNA Processing"                                               "Energy and Precursor Metabolites Generation"                 
# [5] "DNA Processing"                                               "Stress Response, Defense and Virulence"                      
# [7] "Fatty Acids, Lipids, and Isoprenoids"                         "Cofactors, Vitamins, Prosthetic Groups"                      
# [9] "Carbohydrates"                                                "Secondary Metabolism"                                        
# [11] "Membrane Transport"                                           "Iron acquisition and metabolism"                             
# [13] "Cell Cycle, Cell Division and Death"                          "Regulation and Cell signaling"                               
# [15] "Nucleosides and Nucleotides"                                  "Amino Acids and Derivatives"                                 
# [17] "Sulfur Metabolism"                                            "Respiration"                                                 
# [19] "Clustering-based subsystems"                                  "Protein Fate (folding, modification, targeting, degradation)"
# [21] "Prokaryotic cell type differentiation"                        "Nitrogen Metabolism"                                         
# [23] "Cell Envelope, Capsule and Slime layer"                       "Phosphate Metabolism"                                        
# [25] "Metabolite damage and its repair or mitigation"               "Prophages, Transposable elements, Plasmids"                  
# [27] "Miscellaneous"                                                "Microbial communities"                                       
# [29] "Experimental Subsystems"                                      "Photosynthesis"                                              
# [31] "Motility and Chemotaxis" 

unique( tax.clean$Subclass )


## samples

head( meta$unique_ID )
# [1] "623361_20180123_S" "634207_20180510_S" "634207_20180517_S" "639354_20171206_S" "639354_20171213_S"
# [6] "642660_20180601_S"

meta$sample <- gsub(pattern = "_S", replacement = "", x = meta$unique_ID)

dim(fxns) # 395195     59

length(which(names(fxns.clean) %in% meta$sample )) # 54

## corrected sample names ???

sample_names_v0 <- names(fxns.clean)

crx <- read_excel("/Users/pedd0011/Documents/et.al.MS's/CF.Hackathon/CF_Metadata_Table.xlsx",
                  sheet="Corrected patient samples list", range="A1:C17", col_names = TRUE)
crx <- as.data.frame(crx)
str(crx)
# 'data.frame':	16 obs. of  3 variables:
#   $ Sequencer type : chr  "MGI" "MGI" "MGI" "MinION" ...
# $ Old sample name: chr  "649354_20170206_S" "652927_20180215_S" "658355_20180301_S" "698917_20190119_S" ...
# $ New sample name: chr  "639354_20171206_S" "715927_20180226_S" "658355_20180327_S" "698917_20180119_S" ...

crx <- crx[which(crx$`Sequencer type` == "MinION"), ]

crx$old <- gsub(pattern = "_S", replacement = "", x = crx$`Old sample name` )
crx$new <- gsub(pattern = "_S", replacement = "", x = crx$`New sample name` )

length(which(meta$sample %in% crx$old)) # 0
length(which(meta$sample %in% crx$new)) # 5 - i.e. meta already contains the new sample name

length(which(names(fxns) %in% crx$old)) # 5
length(which(names(fxns) %in% crx$new)) # 0

length(crx$new) # 5

meta.fixed <- meta

fxns.fixed <- fxns.clean

# replace $old for $new sample name
for (i in 1:length(crx$old)) {
  #i<-1
  this_old_name <- crx$old[i]
  sel_fxns_name <- which(names(fxns) == this_old_name)
  names(fxns.fixed)[sel_fxns_name] <- crx$new[i]
  print(paste0("completed ",i))
}

row.names(meta.fixed) <- gsub(pattern = "_S", replacement = "", x = row.names(meta.fixed))

length(which(row.names(meta.fixed) %in% names(fxns.fixed))) # 59

identical(row.names(meta.fixed), names(fxns.fixed)) # FALSE

samps <- meta.fixed

samps <- samps[ names(fxns.fixed), ]
dim(samps) # 59 38




#### Phyloseq object Fxn Minion - get into Phyloseq object ####


# sfx.wide - is equiv to OTU table

# tax.fxn - is equiv to TAX table

# meta - is equiv to sample table

## Create 'taxonomyTable'
#  tax_table - Works on any character matrix. 
#  The rownames must match the OTU names (taxa_names) of the otu_table if you plan to combine it with a phyloseq-object.
tax.m <- as.matrix( tax.clean )
dim(tax.m) # 334942      6

TAX <- tax_table( tax.m )


## Create 'otuTable'
#  otu_table - Works on any numeric matrix. 
#  You must also specify if the species are rows or columns
#otu.m <- as.matrix( sfx.wide )
otu.m <- as.matrix( fxns.fixed )
dim(otu.m)
# 334942     59

identical(row.names(otu.m), row.names(tax.m)) # TRUE

OTU <- otu_table(otu.m, taxa_are_rows = TRUE)


## Create a phyloseq object, merging OTU & TAX tables
phy = phyloseq(OTU, TAX)
phy
# phyloseq-class experiment-level object
# otu_table()   OTU Table:         [ 334942 taxa and 59 samples ]
# tax_table()   Taxonomy Table:    [ 334942 taxa by 6 taxonomic ranks ]


## metadata ? need dataframe with row.names as sample_names

SAMP <- sample_data(samps)

phy = merge_phyloseq(phy, SAMP)
phy
# phyloseq-class experiment-level object
# otu_table()   OTU Table:         [ 334942 taxa and 59 samples ]
# sample_data() Sample Data:       [ 59 samples by 38 sample variables ]
# tax_table()   Taxonomy Table:    [ 334942 taxa by 6 taxonomic ranks ]


head(taxa_names(phy))
# [1] "UniRef50_V8BD69"     "UniRef50_T0V120"     "UniRef50_E7MQS7"     "UniRef50_A0A7X7V2F8"
# [5] "UniRef50_A0A7S3ID01" "UniRef50_Q99XH4"

head(phy@tax_table)

getwd()  # "/Users/lidd0026/WORKSPACE/PROJ/CFHackathon2023-FAME/Fxns_minion"

saveRDS(object = phy, file = "phy-phyloseq-object-All-Minion-fxns-longreads.RDS")

#phy <- readRDS("phy-phyloseq-object-All-Minion-fxns-longreads.RDS")




####  Alpha & Beta diversity - Fxn Minion ####


phy
# phyloseq-class experiment-level object
# otu_table()   OTU Table:         [ 334942 taxa and 59 samples ]
# sample_data() Sample Data:       [ 59 samples by 38 sample variables ]
# tax_table()   Taxonomy Table:    [ 334942 taxa by 6 taxonomic ranks ]

sort( sample_sums(phy))
# 1128691_20171218  752797_20170927 1565754_20171128  698917_20180128  673895_20180205 
# 1477            10350            19108            22735            23606 
# 1128691_20180116  673895_20180122  698917_20180119 1565754_20180403  768745_20171123 
# 24948            64378            72391            73361            95739 
# 715927_20180205  650003_20180207 1651490_20171010  639354_20171206  748160_20180329 
# 118141           127817           135676           155588           164784 
# 676138_20180130  825012_20181120  753522_20180606  698917_20171207  802971_20180605 
# 165596           181287           182176           186625           188754 
# 1447437_20171212 1593973_20180427  788707_20180313  763742_20180129  748160_20180321 
# 204863           211216           255520           261702           265226 
# 892355_20180123  983493_20180123 1651490_20180206  778851_20171204 1316935_20180417 
# 269082           272348           278404           285296           308226 
# 1651490_20171215  785991_20171206  785991_20171129  788707_20181116  748699_20180410 
# 338206           339469           350971           394198           415731 
# 1845116_20180403  788707_20180301 1068841_20180306 1586713_20180309  658355_20180321 
# 430344           439492           443192           445698           458201 
# 748699_20180329 1588281_20180508 1593973_20180504  623361_20180123 1593967_20180424 
# 468837           505293           522735           531627           536559 
# 1470026_20180502  788707_20171213  770590_20170925  658355_20180122 1834617_20180501 
# 551294           657472           699018           718436           721901 
# 895293_20180502  658355_20171204  825012_20181126  756934_20181218  770590_20180115 
# 729768           757781           925008           925650           960896 
# 785991_20180321 1447437_20171006 1590009_20171212 1282052_20180206 
# 1050528          1053432          1136483          1196208 


summary(sample_sums(phy))
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1477  165190  308226  395438  534093 1196208

sort(table(phy@sam_data$Patient), decreasing = TRUE)
# 788707  658355  698917  785991 1651490  673895  748160  748699  770590  825012 1128691 1447437 
# 4       3       3       3       3       2       2       2       2       2       2       2 
# 1565754 1593973  623361  639354  650003  676138  715927  752797  753522  756934  763742  768745 
# 2       2       1       1       1       1       1       1       1       1       1       1 
# 778851  802971  892355  895293  983493 1068841 1282052 1316935 1470026 1586713 1588281 1590009 
# 1       1       1       1       1       1       1       1       1       1       1       1 
# 1593967 1834617 1845116 
# 1       1       1 

patients_with_3ormore_samps <- c("788707", "658355", "698917", "785991", "1651490")


## Normalize data by rarefying

# remove sample with low library size: "1128691_20171218"

keep_samps <- sample_names(phy)[ -which(sample_names(phy) == "1128691_20171218")]

phy2 <- prune_samples(keep_samps ,phy)

min(taxa_sums(phy2)) # 0
# prune taxa that have zero sequence reads
phy2 <- prune_taxa(taxa = taxa_sums(phy2) > 0, x = phy2)
phy2
# phyloseq-class experiment-level object
# otu_table()   OTU Table:         [ 334927 taxa and 58 samples ]
# sample_data() Sample Data:       [ 58 samples by 38 sample variables ]
# tax_table()   Taxonomy Table:    [ 334927 taxa by 6 taxonomic ranks ]

min(sample_sums(phy2)) # 10350
min(taxa_sums(phy2)) # 1





#### rarefy #1 #####
seed <- 123
r1.ps <- rarefy_even_depth(phy2, sample.size = min(sample_sums(phy2)),
                           rngseed = seed, replace = FALSE, trimOTUs = TRUE, verbose = TRUE)


min(taxa_sums(r1.ps)) # 1
sample_sums(r1.ps) # all 10350
ntaxa(r1.ps) # 95357

shan.r1.ps <- plot_richness(r1.ps, measures=c("Shannon"))
shan.r1.ps
str(shan.r1.ps$data)

out <- data.frame(sample=shan.r1.ps$data$sample,
                  shannon=shan.r1.ps$data$value,
                  patient=shan.r1.ps$data$Patient,
                  in_vs_out_patient = shan.r1.ps$data$IP.vs.OP
)

# calculate effective no of species
out$eff_no_fxn <- exp(out$shannon)
unique(out$patient)
# "X658355" "X788707" "X698917"

str(out)
# 'data.frame':	58 obs. of  5 variables:
# $ sample           : chr  "1068841_20180306" "1447437_20171212" "1128691_20180116" "1590009_20171212" ...
# $ shannon          : num  8.75 8.72 4.49 8.67 8.39 ...
# $ patient          : num  1068841 1447437 1128691 1590009 1282052 ...
# $ in_vs_out_patient: chr  "OP" "OP" "OP" "OP" ...
# $ eff_no_fxn       : num  6334 6147.5 89.5 5812.1 4383.5 ...

# out$sample <- gsub(pattern = "X", replacement = "", x = out$sample)
out$sample <- factor(out$sample, levels = sort(out$sample), ordered=TRUE)
# out$patient <- gsub(pattern = "X", replacement = "", x = out$patient)

out

shapes <- c( "OP"= 1, "IP"=16) # OP = outpatient = open circle; IP = inpatient = filled circle


table(out$in_vs_out_patient, useNA = "ifany")
# IP   OP <NA> 
# 25   32    1 

# fix missing IP/OP data ??
sel <- which(is.na(out$in_vs_out_patient))
out[sel, ]
#             sample  shannon patient in_vs_out_patient eff_no_fxn Xpatient
# 51 788707_20180313 8.511191  788707              <NA>    4970.08  X788707
out$in_vs_out_patient[sel] # NA
out$in_vs_out_patient[sel] <- "IP"

sel <- which(phy@sam_data$sample == "788707_20180313")
phy@sam_data$`IP vs OP`[sel] # NA
phy@sam_data$`IP vs OP`[sel] <- "IP"

sel <- which(phy2@sam_data$sample == "788707_20180313")
phy2@sam_data$IP.vs.OP[sel] # NA
phy2@sam_data$IP.vs.OP[sel] <- "IP"

table(out$in_vs_out_patient, useNA = "ifany")
# IP OP 
# 26 32

# colours?
# http://www.sthda.com/english/wiki/the-elements-of-choosing-colors-for-great-data-visualization-in-r
#library(colortools)
#col1 <- wheel("steelblue", num = (dim(out)[1])/2)

# https://stackoverflow.com/questions/13665551/generate-pairs-of-bright-and-dark-colours-for-ggplot2
library(grDevices)

dim(out)[1] # 58
# no of patients
no_patients <- length(unique(out$patient)) # 39

col1 <- rainbow(no_patients)

# include 'X' on named patient list to play nicely with ggplot scale_color_manual()
names(col1) <- paste0("X",unique(out$patient))
out$Xpatient <- paste0("X",out$patient)

head(col1)
# X1068841  X1447437  X1128691  X1590009  X1282052  X1316935 
# "#FF0000" "#FF2700" "#FF4E00" "#FF7600" "#FF9D00" "#FFC400" 

p <- ggplot(data=out, aes(x=sample, y=eff_no_fxn, color=Xpatient, shape = in_vs_out_patient)) +
  geom_point() +
  geom_line(aes(group = Xpatient), alpha=0.5)+
  ggtitle("Alpha diversity of Uniref Functions\n(rarefied to minimum library size)")+
  #geom_boxplot() +
  #geom_jitter(size=1.5, width = 0.15) +
  #theme(axis.text.x  = element_text(angle=90, hjust=1, vjust = 0.5) ) +
  labs(x = NULL, y = "Effective no of functions\nbased on exp(Shannon's diversity)")+
  theme_bw()+
  scale_shape_manual(values = shapes, name = "In-patient or out-patient")+
  scale_color_manual(values = col1)+
  guides(color = "none")+
  theme(
    #legend.position = c(0.15,0.18),
    legend.position = "bottom",
    legend.key.height = unit(0.8,"line"),
    legend.title = element_text(size = rel(0.9)),
    axis.text.x  = element_text(angle=60, hjust=1, vjust = 1, size = rel(0.8)),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )
p

#dev.print(tiff, file = paste0(workdir,"/plots/","Minion-Uniref-Function-Alpha-diversity.tiff"), width = 12, height = 9, units = "cm", res=450, compression="lzw",type="cairo")
# dev.print(jpeg, file = paste0(workdir,"/plots/","Minion-ALL-Uniref-Function-Alpha-diversity.jpeg"), width = 20, height = 12, units = "cm", res=450, type="cairo")
# dev.off



#### ordination plot ####
## PCoA + Bray-Curtis

set.seed(123)
#ord <- ordinate(r1.ps, "NMDS", "bray")
ord <- ordinate(r1.ps, "PCoA", "bray")

ord


str(r1.ps@sam_data)
names(sample_data(r1.ps))


sel <- which(r1.ps@sam_data$sample == "788707_20180313")
r1.ps@sam_data$IP.vs.OP[sel] # NA
r1.ps@sam_data$IP.vs.OP[sel] <- "IP"


#p <- plot_ordination(r1.ps, ord, type="samples", color="age_category", shape = "city")
p <- plot_ordination(r1.ps, ord, type="samples", color="Patient")
p

str(p$data)

p$labels$x # "Axis.1   [12.8%]"
x_lab <- "PCo1 (12.8%)"

p$labels$y # "Axis.2   [7.2%]"
y_lab <- "PCo2 (7.2%)"


p_df <- p$data

p_df$XPatient <- paste0("X",p_df$Patient)
p_df$sample <- factor( p_df$sample, levels = sort(p_df$sample), ordered=TRUE )
p_df$sample_select_display <- NA
sel <- which(p_df$Patient %in% patients_with_3ormore_samps)
p_df$sample_select_display[sel] <- as.character( p_df$sample[sel] )

p_df$IP.vs.OP


p <- ggplot(data = p_df, aes(x = Axis.1, y = Axis.2, color = XPatient))+
  ggtitle("Beta diversity of Uniref Functions\n(PCoA on Bray-Curtis distances\nrarefied to minimum library size)")+
  
  theme_bw()+
  xlim(-0.5, 0.4) + ylim(-0.4, 0.4)+
  #geom_polygon(aes(group=patient),alpha=0.1)+ # ,  inherit.aes = FALSE fill=NA,  alpha=0.2,
  
  #geom_line(aes(group=XPatient),alpha=0.6)+ # ,  inherit.aes = FALSE fill=NA,  alpha=0.2,
  
  #geom_path(aes(group=XPatient),alpha=0.6, arrow = arrow(type = "open", angle = 30, length = unit(0.2, "cm")))+ # ,  inherit.aes = FALSE fill=NA,  alpha=0.2,
  geom_path(aes(group=XPatient),alpha=0.6, linetype = "dotted", arrow = arrow(type = "open", angle = 30, length = unit(0.2, "cm")))+ # ,  inherit.aes = FALSE fill=NA,  alpha=0.2,
  
  geom_point(aes(shape = IP.vs.OP))+
  #geom_text(aes(x = Axis.1, y = Axis.2,label=label_display), nudge_x = 0.005, nudge_y = 0.005, size=2.5, inherit.aes = FALSE)+
  
  #geom_text(aes(x = Axis.1, y = Axis.2,label=sample_select_display), hjust=0, vjust=0, size=3, inherit.aes = FALSE)+
  
  xlab(x_lab) + ylab(y_lab)+
  scale_shape_manual(values = shapes, name = "In-patient or out-patient")+
  scale_color_manual(values = col1)+
  guides(color = "none")+
  theme(
    legend.position = "bottom",
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank())
p

#grid.text(label = "(c)", x = unit(0.03, "npc") , y = unit(0.97,"npc"), gp=gpar(fontsize=12, fontface="bold") )
#grid.text(label = "(c)", x = unit(0.03, "npc") , y = unit(0.97,"npc"), gp=gpar(fontsize=15, fontface="bold") )

#dev.print(tiff, file = paste0(workdir,"/plots/","Minion-Uniref-Functions-Beta-diversity-PCoA-Bray.tiff"), width = 16, height = 16, units = "cm", res=450, compression="lzw", type = "cairo")
#dev.print(jpeg, file = paste0(workdir,"/plots/","Minion-Uniref-ALL-Functions-Beta-diversity-PCoA-Bray.jpeg"), width = 18, height = 20, units = "cm", res=450,  type = "cairo")

#dev.print(jpeg, file = paste0(workdir,"/plots/","Minion-Uniref-ALL-Functions-Beta-diversity-PCoA-Bray--no-labels.jpeg"), width = 18, height = 20, units = "cm", res=450,  type = "cairo")



#### CCA Starts here ####

min(taxa_sums(r1.ps)) # 1
sample_sums(r1.ps) # all 10350 
ntaxa(r1.ps) # 95357

sample_names(r1.ps)
# # [1] "1068841_20180306" "1447437_20171212" "1128691_20180116" "1590009_20171212" "1282052_20180206"
# [6] "1316935_20180417" "1651490_20171215" "1447437_20171006" "1470026_20180502" "1565754_20171128"
# [11] "1565754_20180403" "1586713_20180309" "1593967_20180424" "1593973_20180427" "1593973_20180504"
# [16] "1588281_20180508" "1651490_20171010" "1651490_20180206" "1834617_20180501" "1845116_20180403"
# [21] "623361_20180123"  "639354_20171206"  "650003_20180207"  "658355_20171204"  "658355_20180122" 
# [26] "658355_20180321"  "673895_20180122"  "673895_20180205"  "676138_20180130"  "698917_20171207" 
# [31] "698917_20180128"  "698917_20180119"  "715927_20180205"  "748160_20180321"  "748160_20180329" 
# [36] "748699_20180329"  "748699_20180410"  "752797_20170927"  "753522_20180606"  "756934_20181218" 
# [41] "763742_20180129"  "768745_20171123"  "770590_20170925"  "770590_20180115"  "778851_20171204" 
# [46] "785991_20171129"  "785991_20171206"  "785991_20180321"  "788707_20171213"  "788707_20180301" 
# [51] "788707_20180313"  "788707_20181116"  "802971_20180605"  "825012_20181120"  "825012_20181126" 
# [56] "892355_20180123"  "895293_20180502"  "983493_20180123" 

## check sample variables
sample_variables(r1.ps)
# [1] "unique_ID"              "Patient"                "Date"                   "IP.vs.OP"              
# [5] "Hospital"               "Room"                   "Age"                    "Age.groups"            
# [9] "Paediatric.vs.Adult"    "Gender"                 "H2_Uncorrected"         "CH4_Uncorrected"       
# [13] "CO2"                    "H2_Corrected"           "CH4_Corrected"          "CH4.H2.ratio_corrected"
# [17] "Corr."                  "Antibiotics_YN"         "Antibiotics..duration." "Culture.Result"        
# [21] "NTM"                    "Previous.12.months"     "Others"                 "IgE"                   
# [25] "Spec.IgE"               "Spec.IgG"               "Precipitins"            "FVC"                   
# [29] "FEV1"                   "Best.FEV1"              "FEV1.best.FEV1"         "CFRD"                  
# [33] "PI"                     "CF.gene.1"              "CF.gene.2"              "Notes"                 
# [37] "CFLD"                   "sample"                    

## identify columns with all same data?
dat.temp <- as( sample_data(r1.ps) , "data.frame" )
uniquevals <- list()
for (i in 1:dim(dat.temp)[2]) {
  #i<-30
  vals <- dat.temp[ ,i]
  uniquevals[[i]] <- length(unique(vals, na.rm = TRUE))
  print(paste0("field ",i," has - ",uniquevals[[i]]," - unique values"))
}
sel <- which(unlist(uniquevals) == 1 | is.na(unlist(uniquevals)) ) # qty 0

names(dat.temp)[sel]
# "0"

## remove these fields - they don't offer any explanatory value
dat.temp2 <- dat.temp [ , -sel ]
dat.temp2
### join back to phyloseq object!
identical( row.names(r1.ps@sam_data), row.names(dat.temp2) ) # TRUE
sample_data(r1.ps) <- dat.temp2
sample_data(r1.ps)


sample_variables(r1.ps)
# [1] "unique_ID"              "Patient"                "Date"                   "IP.vs.OP"              
# [5] "Hospital"               "Room"                   "Age"                    "Age.groups"            
# [9] "Paediatric.vs.Adult"    "Gender"                 "H2_Uncorrected"         "CH4_Uncorrected"       
# [13] "CO2"                    "H2_Corrected"           "CH4_Corrected"          "CH4.H2.ratio_corrected"
# [17] "Corr."                  "Antibiotics_YN"         "Antibiotics..duration." "Culture.Result"        
# [21] "NTM"                    "Previous.12.months"     "Others"                 "IgE"                   
# [25] "Spec.IgE"               "Spec.IgG"               "Precipitins"            "FVC"                   
# [29] "FEV1"                   "Best.FEV1"              "FEV1.best.FEV1"         "CFRD"                  
# [33] "PI"                     "CF.gene.1"              "CF.gene.2"              "Notes"                 
# [37] "CFLD"                   "sample"     

cf_vars <- c( "Patient", "Date",   "IP.vs.OP",    "Hospital", "Room", "Age", "Age.groups",
              "Paediatric.vs.Adult" , "Gender",
              "H2_Uncorrected",  "CH4_Uncorrected",    "CO2",    "H2_Corrected", "CH4_Corrected",  
              "CH4.H2.ratio_corrected", "Corr.",  "Antibiotics_YN", 
              "Culture.Result", "FVC",   "FEV1",  "Best.FEV1", "FEV1.best.FEV1",  "CFRD",  "PI",  "CFLD"
)

## start with evenly sampled data

# rarefy #1
seed <- 123
r1.ps <- rarefy_even_depth(r1.ps, sample.size = min(sample_sums(r1.ps)),
                           rngseed = seed, replace = FALSE, trimOTUs = TRUE, verbose = TRUE)

min(taxa_sums(r1.ps)) # 1
sample_sums(r1.ps) # all 10350 

ntaxa(r1.ps) #  95357
sum(sample_sums(r1.ps)) # 600300

r1.ps
# phyloseq-class experiment-level object
# otu_table()   OTU Table:         [ 69741 taxa and 8 samples ]
# sample_data() Sample Data:       [ 8 samples by 35 sample variables ]
# tax_table()   Taxonomy Table:    [ 69741 taxa by 6 taxonomic ranks ]

unique(r1.ps@sam_data$Patient)
# [1] 1068841 1447437 1128691 1590009 1282052 1316935 1651490 1470026 1565754 1586713 1593967 1593973 1588281
# [14] 1834617 1845116  623361  639354  650003  658355  673895  676138  698917  715927  748160  748699  752797
# [27]  753522  756934  763742  768745  770590  778851  785991  788707  802971  825012  892355  895293  983493

r1.ps@sam_data$Patient <- factor( r1.ps@sam_data$Patient)

## rescore below detection thresholds to zero
## set values below detection limit to zero
# dat.temp <- as( sample_data(r1.ps), "data.frame")
# str(dat.temp)
# 
# sel <- lapply(dat.temp, function(x) grepl(pattern = "[$<]", x=x))
# 
# sel[[1]]
# 
# for (i in 1:length(sel)) {
#   #i <- 1
#   temp1 <- dat.temp[ ,i]
#   sel.fix <- which( sel[[i]] == TRUE)
#   if (length(sel.fix) >=1 ) { temp1[ sel.fix ] <- "0" }
#   dat.temp[ ,i] <- temp1
#   print(paste0("completed ",i))
# }

dat.temp
str(dat.temp)

str(cf_vars)

## change to numeric data
## Need to clarify here which data need to be num or chr, hashed out below line for now...
#dat.temp[ , cf_vars] <- lapply(X = dat.temp[ , cf_vars], FUN = as.numeric)
str(dat.temp)
cf_vars
# [1] "Patient"                "Date"                   "IP.vs.OP"               "Hospital"              
# [5] "Room"                   "Age"                    "Age.groups"             "Paediatric.vs.Adult"   
# [9] "Gender"                 "H2_Uncorrected"         "CH4_Uncorrected"        "CO2"                   
# [13] "H2_Corrected"           "CH4_Corrected"          "CH4.H2.ratio_corrected" "Corr."                 
# [17] "Antibiotics_YN"         "Culture.Result"         "NTM"                    "FVC"                   
# [21] "FEV1"                   "Best.FEV1"              "FEV1.best.FEV1"         "CFRD"                  
# [25] "PI"                     "CF.gene.1"              "CF.gene.2"              "CFLD"        

# rename soil vars
# cf_vars_new_names <- c("Veg_Cov_Total", "Tree_cov", 
#                        "Shrub_cov", "Grass_cov", "Ammonium_Nitrogen", "Nirate_Nitrogen", "Phosphorus_Colwell", "Potassium_Colwell", 
#                        "Sulphur", "Organic_Carbon", "Conductivity", "Ph_CaCl2", "pH_H2O", 
#                        "DTPA_Copper", "DTPA_Iron",  "DTPA_Manganese", "DTPA_Zinc",  "Exc_Aluminium", 
#                        "Exc_Calcium",  "Exc_Magnesium",   "Exc_Potassium",   "Exc_Sodium", "Boron_Hot_CaCl2"
# )
# 
# 
# length(cf_vars);length(cf_vars_new_names) # 23 23
# 
# names(dat.temp[ ,cf_vars])
# for (i in 1:length(cf_vars)) {
#   #i<-1
#   sel.df <- which(names(dat.temp) == cf_vars[i])
#   names(dat.temp)[sel.df] <- cf_vars_new_names[i]
#   print(paste0("completed ",i))
# }

names(dat.temp)
# [1] "Patient"                "Date"                   "IP.vs.OP"               "Hospital"              
# [5] "Room"                   "Age"                    "Age.groups"             "Paediatric.vs.Adult"   
# [9] "Gender"                 "H2_Uncorrected"         "CH4_Uncorrected"        "CO2"                   
# [13] "H2_Corrected"           "CH4_Corrected"          "CH4.H2.ratio_corrected" "Corr."                 
# [17] "Antibiotics_YN"         "Antibiotics..duration." "Culture.Result"         "NTM"                   
# [21] "Previous.12.months"     "Others"                 "IgE"                    "Spec.IgE"              
# [25] "Spec.IgG"               "Precipitins"            "FVC"                    "FEV1"                  
# [29] "Best.FEV1"              "FEV1.best.FEV1"         "CFRD"                   "PI"                    
# [33] "CF.gene.1"              "CF.gene.2"              "Notes"                  "CFLD"                

sample_data( r1.ps ) <- dat.temp
r1.ps@sam_data

vars_all <- r1.ps@sam_data[ , cf_vars ]
str(vars_all)
vars_all <- as(vars_all,"data.frame")
str(vars_all)
# 'data.frame':	58 obs. of  28 variables:
#   $ Patient               : num  1068841 1447437 1128691 1590009 1282052 ...
# $ Date                  : POSIXct, format: "2018-03-06" "2017-12-12" "2018-01-16" "2017-12-12" ...
# $ IP.vs.OP              : chr  "OP" "OP" "OP" "OP" ...
# $ Hospital              : chr  "RAH" "RAH" "RAH" "RAH" ...
# $ Room                  : chr  "Chest Clinic 7" "Chest Clinic 4" "Chest Clinic 4" "Chest Clinic 1" ...
# $ Age                   : num  47 31 47 29 33 33 26 31 23 25 ...
# $ Age.groups            : num  7 5 7 5 5 5 5 5 4 5 ...
# $ Paediatric.vs.Adult   : chr  "Adult" "Adult" "Adult" "Adult" ...
# $ Gender                : chr  "M" "M" "F" "M" ...
# $ H2_Uncorrected        : num  14 20 0 12 15 6 18 23 1 7 ...
# $ CH4_Uncorrected       : num  3 3 1 2 3 3 4 4 2 2 ...
# $ CO2                   : num  3.8 3.3 3 4.4 3.2 2 3.7 3.6 4 3.4 ...
# $ H2_Corrected          : num  20 33 0 15 26 17 27 35 1 11 ...
# $ CH4_Corrected         : num  4 5 2 3 5 8 6 6 3 3 ...
# $ CH4.H2.ratio_corrected: num  0.2 0.152 NA 0.2 0.192 ...
# $ Corr.                 : num  1.44 1.66 1.83 1.25 1.71 2.75 1.48 1.52 1.37 1.61 ...
# $ Antibiotics_YN        : chr  "0" "0" "1" "0" ...
# $ Culture.Result        : chr  "A. niger; A. terreus" "S. aureus; P. aeruginosa (x 2 strains; 1 mucoid)" "P. aeruginosa (mucoid); A. fumigatus" "S. aureus" ...
# $ NTM                   : chr  "0" "0" "0" "0" ...
# $ FVC                   : num  98 74 34 89 54 93 74 76 76 82 ...
# $ FEV1                  : num  95 68 27 87 48 84 72 72 62 75 ...
# $ Best.FEV1             : num  98 74 33 92 52 104 74 74 78 78 ...
# $ FEV1.best.FEV1        : num  0.969 0.919 0.818 0.946 0.923 ...
# $ CFRD                  : num  0 0 0 0 0 0 0 0 0 0 ...
# $ PI                    : num  1 1 1 1 1 1 1 1 1 1 ...
# $ CF.gene.1             : chr  "F508" "F508" "F508" "F508" ...
# $ CF.gene.2             : chr  "?" "?" "F508" "?" ...
# $ CFLD                  : chr  "0" "0" NA "0" ...

class(vars_all)# "data.frame"
dim(vars_all) # 58 28
names_vars_all <- names(vars_all)

# scale data
vars_all <- vars_all%>%mutate_if(is.numeric,scale)
#vars_all <- scale(vars_all)
str(vars_all)

otu_all <- r1.ps@otu_table
otu_all <- as.data.frame(otu_all)
str(head(otu_all))
class(otu_all)# data.frame
dim(otu_all) # 95357    58



## Are there highly correlated predictors?
## Methodology from caret package (see Applied Predictive Modeling text)
## to identify correlated predictors

# Determine correlations between numeric candidate predictors (independent variables)

#### check with Craig re: non-numeric variables and correlations

pairs( vars_all, gap=0 )

correlations <- cor( vars_all  )
correlations
#write.csv(x = correlations, file = "FitzStirl-soil-vars-allsites-correlations.csv", row.names=TRUE)

#library(caret)

# findCorrelation {caret}: This function searches through a correlation matrix and returns a vector of integers corresponding to columns to remove to reduce pair-wise correlations.
highCorr <- findCorrelation(correlations, cutoff = .75)
length(highCorr) # 0

highCorr
#0

names( vars_all )[highCorr] #0



## prepare correlation plot
#M <- cor( cases2[, c(outcome, neworder.names)], use="na.or.complete")
colnames(correlations)
# [1] "Patient"                "Date"                   "IP.vs.OP"               "Hospital"              
# [5] "Room"                   "Age"                    "Gender"                 "H2_Uncorrected"        
# [9] "CH4_Uncorrected"        "CO2"                    "H2_Corrected"           "CH4_Corrected"         
# [13] "CH4.H2.ratio_corrected" "Corr."                  "Antibiotics_YN"         "Culture.Result"        
# [17] "NTM"                    "IgE"                    "Spec.IgG"               "FVC"                   
# [21] "FEV1"                   "Best.FEV1"              "FEV1.best.FEV1"         "CFRD"                  
# [25] "PI"                     "CF.gene.1"              "CF.gene.2"              "CFLD"   


rownames(correlations)
# same as above

#install.packages('corrplot')
library(corrplot)

# dev.cur()
# dev.off(quartz2)
corrplot(corr = correlations, method="ellipse", type="upper") #  method="ellipse"  method="circle"
# saved w550, h700

# dev.print(tiff, filename = paste0(workdir,"/plots/", "All.sites.correlation-plot-soil-vars-FitzStirl.tiff"),
#           width = 16, height = 16, units = "cm", res=600,
#           compression = "lzw", type="cairo")
#dev.off

# -highCorr hashed out to bypass for now
vars_trim <- vars_all#[ ,-highCorr]

names(vars_trim)
#character(0)    

# ## choose alternative variables 
# choose_vars <- c(
#   "Gravel_perc_0_10"   ,   "BD_fine_earth_2_7"  ,  "OC_percent"     , "P_Colwell_mgperkg",  "K_Colwell_mgperkg",
#   "Ammonium_N_mgperkg" ,   "Nitrate_N_mgperkg"  ,  "Sulfur_mgperkg" , "EC_dSperm"        ,  "pH_H2O"  ,  "PBI"  
# )
# vars_trim2 <- vars_all[ , choose_vars]

# http://www.sthda.com/english/wiki/scatter-plot-matrices-r-base-graphs

# Correlation panel
panel.cor <- function(x, y){
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  r <- round(cor(x, y), digits=2)
  txt <- paste0("r = ", r)
  cex.cor <- 0.8/strwidth(txt)
  text(0.5, 0.5, txt, cex = cex.cor * r)
}

pairs( vars_trim, gap=0, lower.panel = panel.cor )

#Remove rows with NA data for model selection
ok <- complete.cases(vars_trim)
sel.ok <-which(ok==TRUE)
sel.ok # 30
vars_trim <- vars_trim[sel.ok, ]
str(vars_trim)

#Check all factors have >1 unique value
sapply(lapply(vars_trim, unique), length)

str(vars_trim)
str(otu_all)

#Need to make both df same length
otu.new = otu_all[ ,row.names(vars_trim) ]


#create null model
#changed otu_all to otu.new below
m0 <- cca( t(otu.new) ~ 1, vars_trim) # X = community matrix, Y = constraining matrix
# ~1 means fit an intercept only
plot(m0)

fig <- ordiplot(m0, labels=TRUE)         # display = sp (species), = sites (=wa), =cn (centroids)
#identify(fig, "sites", cex=0.8) # in this case "species" means locations

#create full model 
m1 <- cca( formula = t(otu.new) ~ ., data = vars_trim )
summary(m1)

################################## Riley's script from here
#this is getting all CCA coordinates into a ggplot object to improve final plot

# Use full and null models for 'ordistep'. Ordistep will choose a model by permutation tests in constrained ordination 
# perform forward and backward selection of explanatory variables
step.env <- ordistep(m0, scope=formula(m1), direction='both')

# output not shown

step.env$call # should give you chosen model
# cca(formula = t(otu.new) ~ Paediatric.vs.Adult + FEV1.best.FEV1 + 
#       H2_Corrected, data = vars_trim)

#Create an object containing all chosen variables
vars.ordistep <- gsub('^. ', '', rownames(step.env$anova))
vars.vif <- names(which(vif.cca(m1) <= 10))
vars <- unique(c(vars.ordistep, vars.vif))

# select variables to keep from table 'Y'
X1 <- vars_trim[, vars.ordistep]
str(X1)

# CCA model
res <- cca(t(otu.new) ~ ., data = X1)
summary(res, display=NULL)

anova(res)
# Permutation test for cca under reduced model
# Permutation: free
# Number of permutations: 999
# 
# Model: cca(formula = t(otu.new) ~ Paediatric.vs.Adult + FEV1.best.FEV1 + H2_Corrected, data = X1)
# Df ChiSquare      F Pr(>F)    
# Model     3    1.4129 1.3082  0.001 ***
#   Residual 26    9.3605                  
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1


# Plots
plot(res)
plot(res, type = "t")

library(gridExtra)

# dataframes for displaying the results
#sit = sample sites
#spp = taxa

sit <- cbind(vars_trim, scores(res, display='sites', choices = c(1,2,3)))
length(unique(sit$Patient)) #25

# spp <- cbind(data.frame(tax_table(r1.ps.rhiz)), scores(res, display='species'))

merge.a <- data.frame(tax_table(r1.ps))
merge.b <- data.frame(scores(res, display='species', choices = c(1,2,3)) )
class(merge.b)

spp <- merge(merge.a, merge.b, by = "row.names")
#View(spp)

spp <- data.frame(spp[,-1], row.names=spp[,1])

nrow(tax_table(r1.ps))
nrow(scores(res, display='species'))
nrow(spp)

vec <- data.frame(scores(res, display='bp',choices = c(1,2,3)))

# use these to adjust length of arrows and position of arrow labels
adj.vec <- 2.5
adj.txt <- 2.8

#Model: cca(formula = t(otu.new) ~ Paediatric.vs.Adult + FEV1.best.FEV1 + H2_Corrected, data = X1)
# Plot CCA1 x CCA2 # Plots can be produced with CCA2-CCA3 etc.

sit$XPatient = paste0("X", sit$Patient)

p.CCA.funcx <- ggplot(sit, aes(x=CCA1, y=CCA2, color=XPatient)) +
  theme(legend.position = "none") +
  geom_point(size=8, alpha=0.6) + 
  geom_segment(data=vec, inherit.aes=F, 
               mapping=aes(x=0, y=0, xend=adj.vec*CCA1, yend=adj.vec*CCA2), 
               arrow=arrow(length=unit(0.2, 'cm'))) + 
  geom_text(data=vec, inherit.aes=F, 
            mapping=aes(x=adj.txt*CCA1, y=adj.txt*CCA2, 
                        label=c('Paediatric.vs.Adult', "FEV1.best.FEV1" , 'H2_Corrected'))) #+ 
 # theme_bw()+labs( x = "CCA1 (36.3%)", y= "CCA2 (25.3%)")
p.CCA.funcx

ggsave(plot=p.CCA.funcx, filename = "CCA.all.samps.funct.pdf", width = 18, height = 16, units = "cm", dpi = 600,)











#-------------------------

