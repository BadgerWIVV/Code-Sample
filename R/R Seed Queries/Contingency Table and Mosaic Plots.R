#Data should be either a table or a matrix

Data <- HairEyeColor

(x <- margin.table(HairEyeColor, c(1, 2)) )

mosaicplot( ~ Hair + Eye + Sex
            , data = Data
            #,color = hcl(c(120, 10))
            #, shade = TRUE
            ,shade = c(3)
            , main = "Mosaic Plot of Hair/Eye Color"
            #, sub = "Title on the Floor"
            , type = "pearson"
            #, type = "FT"
            #, type = "deviance"
            )



library( vcd )
assoc(HairEyeColor, shade=TRUE) 


#Another example

require(stats)
mosaicplot(Titanic, main = "Survival on the Titanic", color = TRUE)
## Formula interface for tabulated data:
mosaicplot(~ Sex + Age + Survived, data = Titanic,  shade = TRUE )