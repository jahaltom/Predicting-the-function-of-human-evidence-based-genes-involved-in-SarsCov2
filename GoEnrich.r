library(clusterProfiler)

# SET THE DESIRED ORGANISM HERE
organism = "org.Hs.eg.db"
BiocManager::install(organism, character.only = TRUE)
library(organism, character.only = TRUE)


df = read.csv('MCL', header=TRUE,sep='\t')

#Keep track of the number of clusters analized
cNum=0
        
#For storing best p.adjust
padj=c()
for (i in 1:nrow(df)){
     #Loop through rows (clusters) df[row,col]   
    cluster= unlist(strsplit(df[i,2], split = ";"))
    #Remove EB and SarsCov2.   
    cluster=cluster[!cluster %in% grep(paste0("EB.chr", collapse = "|"), cluster, value = T)]
    cluster=cluster[!cluster %in% grep(paste0("SarsCov2", collapse = "|"), cluster, value = T)]

    if (length(cluster)>=10){
   
        #Keep track of the number of clusters analized
        cNum=cNum+1
        gse=enrichGO(
        cluster,
        OrgDb=organism,
        keyType = "SYMBOL",
        ont = "BP",
        pvalueCutoff = 0.05,
        pAdjustMethod = "BH",
        qvalueCutoff = 0.2,
        minGSSize = 10,
        maxGSSize = 500,
        readable = FALSE,
        pool = FALSE
        )
        
        #Get min p-value for each cluster. If there are any. Save reuslts. 
        if (length(gse$p.adjust) != 0){
            padj=c(padj,min(gse$p.adjust))
            
            result=gse@result
            write.table(result,paste("results/MCL_Cluster",i,"GoEnrichmentResults",sep="_"),sep = '\t',row.names = TRUE)
    
            
            }
    }
    
 }

########  

#Average best p.adjust
bestAvg=mean(padj)


#Write output
fileConn<-file("results/MCL_output.txt","a")
writeLines(paste("Mean of the best p-values:",bestAvg), fileConn)
writeLines(paste("total clusters analized:",cNum), fileConn)
close(fileConn)
