## This is an example on how to annotate variables and store
## different properties in attributes and export them as codebook.
## Both individual variable handling and bulk in/export are shown.

library(data.table)

## Prepare for demonstration (not needed for actual use)

## First, make a test dataset
d <- data.table(
  id = c("CL12345", "CL23456", "CL34567"),
  age = c(16, 17.5, 18),
  sex = c("male", "female", "female"),
  dep = c(48, 50.5, 46),
  anx = c(50, 45, 48.5))

## There may already be a codebook to bulk import variable info, in that case read in.
## Here we just make one up
d.attri <- data.table(
  vname = c("id", "age", "sex", "dep", "anx"),
  vinfo = c("ID variable",
            "Participant age in years",
            "2 categories: males or females",
            "Score of depression",
            "Score of anxiety"),
  scale = c("none", "demo", "demo", "mood", "mood"))

## Example of adding variable information manually
## This will create an attribute field called "vinfo",
## and store "whatever..." into this field for the variable age
setattr(d$age, "vinfo", "whatever you want to label")

## Example of matching to the attribute table for a single variable.
setattr(d$id, "vinfo", d.attri[vname == "id"]$vdes)

## Example of merging in attributes in bulk from imported codebook
## Make sure variable names are exactly the same across data and the imported codebook
for (var in names(d)){
  setattr(d[[var]], "vinfo", d.attri[vname == var]$vinfo)
  setattr(d[[var]], "scale", d.attri[vname == var]$scale)
}

## Example of checking individual variable attribute
## This one below checks which "scale" variable age is from
attr(d$age, "scale")

## Exporting all variable names with their attributes for complete codebook
codebook <- data.table(
  vname = names(d),
  vinfo = unlist(lapply(d, attr, "vinfo")),
  scale = unlist(lapply(d, attr, "scale"))) ## keep adding other attributes if more types

## Save codebook in csv if needed
write.csv(codebook, "codebookexport.csv")

