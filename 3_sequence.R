
## ==============================================================================
## Paper:     Employment Stability and Social Origin: Cumulative Advantages in Young Adults' Homeownership and Financial Asset Accumulation
## Author:    Vincent Jerald Ramos and Ann Berrington
## Date:      May 2026
## Purpose:   Replication Codes for Figures and Tables in Text
## File:	    3_sequence
## Describe:  sequence analysis
## ==============================================================================


set.seed(12345) 


# Load packages
library(here)
library(haven)
library(TraMineR)
library(TraMineRextras)
library(cluster)
library(WeightedCluster)
library(FactoMineR)
library(ade4)
library(RColorBrewer)
library(questionr)
library(descriptio)
library(dplyr)
library(purrr)
library(ggplot2)
library(seqhandbook)

library(descr)
library(haven)
library(reshape2)
library(here)


# If 3_sequence.R is in the project root, use this:
here::i_am("3_sequence.R")

# Define project-relative folders
tables_dir  <- here("output", "tables")
figures_dir <- here("output", "figures")

# Input and output files
activity_file <- file.path(tables_dir, "activity_merged.dta")
clusters_file <- file.path(tables_dir, "activity_clusters.dta")

# Read the Stata-created activity histories
ns_hist <- read_dta(activity_file)
ns_hist <- ns_hist %>% mutate_if(is.labelled, funs(as_factor(.)))
ns_hist$W9FINWTALLB <- as.numeric(as.character(ns_hist$W9FINWTALLB))

# Subset for M and F
ns_hist_m <- subset(ns_hist, sex=="Male")
ns_hist_f <- subset(ns_hist, sex=="Female")


labs <- c("employment", "education", "unemp/inactive", "caregiving", "training", "other")
palette <- brewer.pal(length(labs), 'Set2')
DATA03 <- seqdef(ns_hist[,3:123],  labels=labs, cpal=palette, weights = ns_hist$W9FINWTALLB, right=NA)
custom_labels <- gsub("^y|m.*", "", colnames(DATA03))

#by gender
DATA03M <- seqdef(ns_hist_m[,3:123],  labels=labs, cpal=palette, weights = ns_hist_m$W9FINWTALLB, right=NA)
#custom_labels <- gsub("y", "", colnames(DATA03M))
DATA03F <- seqdef(ns_hist_f[,3:123],  labels=labs, cpal=palette, weights = ns_hist_f$W9FINWTALLB, right=NA)
#custom_labels <- gsub("y", "", colnames(DATA03F))

################################################################################
# Figure 2. Activity Distributions of the 1989-90 cohort from 16 to 25, by Sex.
################################################################################

# Plot 1. Draw a state distribution plot 
seqtab(DATA03, idx=0) %>% nrow # 4730 distinct sequences

par(mar = c(1, 3, 2, 1))
seqdplot(DATA03, cex.legend=1.0, 
         legend.prop = 0.3, 
         bty="n", ncol=3, 
         xtlab=custom_labels, 
         xtstep = 12,
         border=NA,
         main= "Activity Distributions of the 1989/90 UK cohort")

dev.off() 

# By gender
pdf(
  file = file.path(figures_dir, "figure2_activity_distributions_by_sex.pdf"),
  width = 10,
  height = 6
)

par(mar = c(1, 3, 2, 1))

seqdplot(
  DATA03,
  group = ns_hist$sex,
  cex.legend = 1.2,
  legend.prop = 0.3,
  bty = "n",
  ncol = 3,
  xtlab = custom_labels,
  xtstep = 12,
  border = NA,
  main = "Activity Distributions"
)

dev.off()


# Cluster selection: dendogram and wardrange plot

# Using Optimal Matching
# Create substitution cost matrix and save to the object "costmatrix"
costmatrix <- seqsubm(DATA03,               # Sequence object
                      method = "CONSTANT",  # Method to determine costs
                      cval = 2,             # Substitution cost
                      with.missing = TRUE,  # Allows for missingness state
                      miss.cost = 1,        # Cost for substituting a missing state
                      time.varying = FALSE, # Does not allow the cost to vary over time
                      weighted = TRUE)      # Allows weights to be used when applicable
# Conduct sequence analysis 
dist_om <- seqdist(DATA03,            # Sequence object
                   method = "OM",       # Optimal matching algorithm
                   indel = 1.0,         # Insert/deletion costs set to 1
                   sm = costmatrix,     # Substitution cost matrix
                   with.missing = TRUE)

# Insert dissimilarity matrix ("dist_om"), 
# indicate that we are using a dissimilarity matrix, and
# indicate that we want to use Ward's single linkage clustering method
clusterward <- agnes(dist_om, diss = TRUE, method = "ward")

# Plot the results of the cluster analysis using a dendrogram
# Insert cluster analysis results object ("clusterward")
plot(clusterward, which.plot = 2)

# Other indicators of clustering quality
wardRange <- as.clustrange(clusterward, diss=dist_om, ncluster = 10)
summary(wardRange, max.rank=3)
#plot(wardRange, stat=c('ASW','PBC'))

    # 1. Plot the lines 
    plot(wardRange,
         stat = c("ASW", "PBC"),
         lwd = 3,                       # Thicker lines
         col = c("blue", "seagreen"),
         legend.pos = NA,               # <--- CRITICAL: Turns off the broken default legend
         legend=FALSE,
         xlab = "Number of Clusters",
         ylab = "Quality Measure (0-1)",
         main = "Cluster Quality Indices (Optimal Matching, INDEL=1)"
    )
    
    # 2. Add clean legend manually
    legend("topright",                # Try "bottomleft" or "bottomright" depending on empty space
           legend = c("ASW (Silhouette)", "PBC (Point Biserial)"),
           col = c("blue", "seagreen"),
           lwd = 3,                     # Match the line thickness
           bty = "n",                   # No box border (clean look)
           cex = 0.9                    # Normal text size
    )


# From the tests above: 3 and 6 seem equally compelling. Try 3 cluster membership

# 3 Cluster solution (OM)
# Insert cluster analysis results object ("clusterward") and the number of cut points
    
c3om <- cutree(clusterward, k = 3) 

# Turn cut points into a factor variable and label them
c3om.fac <- factor(c3om, labels = c("Early STW", "Late STW", "Intermittent")) 


# Plot the sequences for each cluster
seqplot(DATA03,              # Sequence object
        group = c3om.fac,      # Grouping factor level variable
        type = "I",            # Create whole sequence plot
        cex.legend = 0.8,      # Change size of legend
        border = NA,           # No plot border
        xtlab=custom_labels,
        xtstep=12,
        weighted=TRUE,
        sortv = "from.start")           

# Save into dataframe
ns_hist$CLUSTERS.OM3 <- c3om.fac

# 6 Cluster solution (OM)
# Insert cluster analysis results object ("clusterward") and the number of cut points
c6om <- cutree(clusterward, k = 6) 

# Turn cut points into a factor variable and label them
c6om.fac <- factor(c6om, labels = c("Early STW", "Late STW", "Training", "Higher Educ", "Intermittent", "Extended Unemp/Inactive")) 

pdf(
  file = file.path(figures_dir, "figure3_sequence_index_plots_by_cluster.pdf"),
  width = 10,
  height = 7
)

par(mar = c(2, 2, 3, 1))

seqplot(
  DATA03,
  group = c6om.fac,
  type = "I",
  cex.legend = 1.4,
  ncol = 3,
  border = NA,
  xtstep = 12,
  weighted = TRUE,
  sortv = "from.start",
  xtlab = custom_labels,
  bty = "n",
  legend.prop = 0.18
)

dev.off()

# Save into dataframe
ns_hist$CLUSTERS.OM6 <- c6om.fac



# Step 4. Extract ns_hist NSID and CLUSTERS
ns_hist_clusters <- subset(ns_hist, select=c(NSID, CLUSTERS.OM3, CLUSTERS.OM6))

colnames(ns_hist_clusters) <- c("NSID", "clusters_om3", "clusters_om6")

# Save the data frame
write_dta(ns_hist_clusters, "/_rr_out_ns/activity_clusters.dta")
