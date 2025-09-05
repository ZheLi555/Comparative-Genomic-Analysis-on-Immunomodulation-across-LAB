# 获取命令行参数
args <- commandArgs(trailingOnly = TRUE)

# 参数检查
if (length(args) == 0) {
  stop("Error: Please provide working directory as an argument.")
}

# 设置工作目录
input_dir <- args[1]
setwd(input_dir)
cat("Working directory set to:", input_dir, "\n")


#input(.fasta)需要保存在目录"~/IL-12_avss/avss_cds"

library(extrafont)
library(dbplyr)
library(writexl)
library(readxl)
library(tidyverse)
library(ggplot2)
library(pheatmap)
library(RColorBrewer)
library(Biostrings)
library(seqinr)
library(msa)
library(ggpubr)

# set the folder for calculated fasta files
multi_compare_folder <- "~/Downloads/Master_Graduation/comparative_genome_analyses/statistic_analyses2/IL-12_avss/avss_cds/avss_cds_multi_compare"
# set the folder for concatenated fasta
multi_cat_folder <- paste0(multi_compare_folder, "/cds_cat_seq")
# set the folder for separate distance matrices
multi_dist_folder <- paste0(multi_compare_folder, "/cds_dist")
# set the folder for distance zero fasta and distance matrix
# genes with non-zero active_WGSS and "Inf" index are not in this folder
multi_dist_zero_folder <- paste0(multi_compare_folder, "/cds_dist_zero")
# set the folder for clustering plot and distance matrix
multi_cluster_folder <- paste0(multi_compare_folder, "/cds_cluster")



# list all fasta files
fasta_files <- sort(list.files(pattern = "\\.fasta$", full.names = TRUE))
# initialize an empty data frame
IL_12_dist_index <- data.frame(Gene = character(), active_BGSS = numeric(), silent_BGSS = numeric(), BGSS = numeric(),
                               active_WGSS = numeric(), silent_WGSS = numeric(), WGSS = numeric(), CH_index = numeric(),
                               a_count = numeric(), s_count = numeric(), as_ratio = numeric(), as_sum = numeric(),
                               zero_dist_count = numeric(), zero_dist_ratio = numeric(), seq_dist_factor = numeric(),
                               potential_gene_index = numeric())
ch_index_log_file <- file.path('~/Downloads/Master_Graduation/comparative_genome_analyses/statistic_analyses2/IL-12_avss/', 
                               "cds_12_dist_log.txt")

# loop all the fasta files for calculation
for (i in seq(1, length(fasta_files), by = 2)) {
  a_file <- fasta_files[i]
  s_file <- fasta_files[i+1]
  
  # for empty file
  if (file.size(a_file) == 0 | file.size(s_file) == 0) {
    if (file.size(a_file) == 0) {
      file.rename(a_file, paste0(no_compare_zero_folder, "/", basename(a_file)))
    } else {
      file.rename(a_file, paste0(no_compare_a_folder, "/", basename(a_file)))
    }
    if (file.size(s_file) == 0) {
      file.rename(s_file, paste0(no_compare_zero_folder, "/", basename(s_file)))
    } else {
      file.rename(s_file, paste0(no_compare_s_folder, "/", basename(s_file)))
    }
    ch_index_msg <- paste(Sys.time(), ": Processed", a_file, "and", s_file, "\n")
    cat(ch_index_msg, file = ch_index_log_file, append = TRUE)
    next
  }
  
  # for file with one sequence
  # NA value in distance matrix is set to for subsequent analyses (heatmap generation)
  a_lines <- sum(grepl("^>", readLines(a_file, warn = FALSE)))
  s_lines <- sum(grepl("^>", readLines(s_file, warn = FALSE)))
  
  if (a_lines == 1 | s_lines == 1) {
    # active and silent concatenated fasta sequences
    cat_gene_name <- gsub("_a\\.fasta$", ".fasta", a_file)
    system(paste("cat", a_file, s_file, ">", cat_gene_name))
    concat_seq <- readDNAStringSet(cat_gene_name)
    aln_as <- msaConvert(msaClustalOmega(concat_seq, cluster="default", gapOpening="default",
                                         gapExtension="default", maxiters="default",
                                         substitutionMatrix="default",
                                         type="default", order=c("aligned", "input"),
                                         verbose=FALSE, help=FALSE), type = "seqinr::alignment")
    as_dist <- as.matrix(dist.alignment(aln_as, matrix = "similarity"), gap = FALSE)
    as_dist_final <- as_dist
    as_dist_final[is.nan(as_dist_final)] <- 1
    
    if (all(as_dist_final == 0)) {
      file.rename(cat_gene_name, paste0(one_dist_zero_folder, "/", basename(cat_gene_name)))
      write.csv(as_dist_final, quote = FALSE,
                paste0(one_dist_zero_folder, "/",
                       basename(gsub("\\.fasta$", ifelse(any(is.nan(as_dist)), "_NA", ""),
                                     basename(cat_gene_name))),
                       ".csv")
      )
    } else {
      heatmap_title <- gsub("\\.fasta$", "", basename(cat_gene_name))
      heatmap_name <- file.path(one_cluster_folder, gsub("\\.fasta$", "_heatmap.pdf", cat_gene_name))
      pheatmap(as_dist_final, color = colorRampPalette(rev(brewer.pal(n = 7, name = "RdYlBu")))(100),
               kmeans_k = NA, border_color = NA, cellwidth = NA, cellheight = NA,
               cluster_rows = TRUE, cluster_cols = TRUE,
               clustering_distance_rows = "euclidean", clustering_distance_cols = "euclidean",
               clustering_method = "complete",
               scale = "none", show_colnames = TRUE, number_color = "black",
               fontsize = 8, fontsize_number = 6, main = heatmap_title,
               filename = heatmap_name, breaks = NA)
      
      file.rename(cat_gene_name, paste0(one_cat_folder, "/", basename(cat_gene_name)))
      write.csv(as_dist_final, quote = FALSE,
                paste0(one_cluster_folder, "/",
                       basename(gsub("\\.fasta$", ifelse(any(is.nan(as_dist)), "_NA", ""),
                                     basename(cat_gene_name))),
                       ".csv")
      )
    }
    
    file.rename(a_file, paste0(one_compare_folder, "/", basename(a_file)))
    file.rename(s_file, paste0(one_compare_folder, "/", basename(s_file)))
    ch_index_msg <- paste(Sys.time(), ": Processed", a_file, "and", s_file, "\n")
    cat(ch_index_msg, file = ch_index_log_file, append = TRUE)
    next
  }
  
  # active cluster sequences
  aln_a <- msaConvert(msaClustalOmega(readDNAStringSet(a_file), cluster = "default", gapOpening = "default",
                                      gapExtension = "default", maxiters = "default",
                                      substitutionMatrix = "default",
                                      type= "default", order = c("aligned", "input"),
                                      verbose = FALSE, help = FALSE), type = "seqinr::alignment")
  a_dist <- as.matrix(dist.alignment(aln_a, matrix = "similarity", gap = FALSE))[drop = FALSE]
  a_dist_final <- a_dist
  a_dist_final[is.nan(a_dist_final)] <- 1
  # number of active strains
  active_count <- nrow(a_dist_final)
  write.csv(a_dist_final, quote = FALSE,
            paste0(multi_dist_folder, "/",
                   basename(gsub("_a\\.fasta$", ifelse(any(is.nan(a_dist)), "_a_NA", "_a"),
                                 basename(a_file))),
                   ".csv")
  )
  
  # silent cluster sequences
  aln_s <- msaConvert(msaClustalOmega(readDNAStringSet(s_file), cluster = "default", gapOpening = "default",
                                      gapExtension = "default", maxiters = "default",
                                      substitutionMatrix = "default",
                                      type = "default", order = c("aligned", "input"),
                                      verbose = FALSE, help = FALSE), type = "seqinr::alignment")
  s_dist <- as.matrix(dist.alignment(aln_s, matrix = "similarity", gap = FALSE))[drop = FALSE]
  s_dist_final <- s_dist
  s_dist_final[is.nan(s_dist_final)] <- 1
  # number of silent strains
  silent_count <- nrow(s_dist_final)
  write.csv(s_dist_final, quote = FALSE,
            paste0(multi_dist_folder, "/",
                   basename(gsub("_s\\.fasta$", ifelse(any(is.nan(s_dist)), "_s_NA", "_s"),
                                 basename(s_file))),
                   ".csv")
  )
  
  # active and silent concatenated fasta sequences
  cat_gene_name <- gsub("_a\\.fasta$", ".fasta", a_file)
  system(paste("cat", a_file, s_file, ">", cat_gene_name))
  concat_seq <- readDNAStringSet(cat_gene_name)
  aln_as <- msaConvert(msaClustalOmega(concat_seq, cluster="default", gapOpening="default",
                                       gapExtension="default", maxiters="default",
                                       substitutionMatrix="default",
                                       type="default", order=c("aligned", "input"),
                                       verbose=FALSE, help=FALSE), type = "seqinr::alignment")
  as_dist <- as.matrix(dist.alignment(aln_as, matrix = "similarity"), gap = FALSE)
  as_dist_final <- as_dist
  as_dist_final[is.nan(as_dist_final)] <- 1
  # ratio of active strain on silent strain
  a_s_ratio <- active_count / silent_count
  # number of all strains
  a_s_sum <- nrow(as_dist_final)
  # should not to except the first column
  # count zero distance value and calculate its' ratio in the whole distance matrice
  zero_count <- sum(as_dist_final[] == 0, na.rm = TRUE)
  total_count <- nrow(as_dist_final) * (ncol(as_dist_final))
  zero_ratio <- zero_count / total_count
  # calculate the sequence_distance-value_factor
  factor <- a_s_sum / zero_count
  
  # cluster analyses
  # centroid calculation (幾何中心/きかちゅうしん)
  # nrow is number of strains
  # calculate the lower triangle of the matrix because of the diagonal value is 0
  # 2 is sum half of the matrix since the other half is mirror
  a_centroid <- sum(a_dist_final[lower.tri(a_dist_final)]) * 2 / (nrow(a_dist_final) * (nrow(a_dist_final) - 1))
  s_centroid <- sum(s_dist_final[lower.tri(s_dist_final)]) * 2 / (nrow(s_dist_final) * (nrow(s_dist_final) - 1))
  avss_centroid <- sum(as_dist_final[lower.tri(as_dist_final)]) * 2 / (nrow(as_dist_final) * (nrow(as_dist_final) - 1))
  
  # BGSS: between group sum of squares
  a_BGSS <- (nrow(a_dist_final)) * sum((a_centroid - avss_centroid)^2, na.rm = TRUE)
  s_BGSS <- (nrow(s_dist_final)) * sum((s_centroid - avss_centroid)^2, na_rm = TRUE)
  as_BGSS <- a_BGSS + s_BGSS
  
  # WGSS: within group sum of squares
  a_WGSS <- sum(rowSums((a_dist_final - a_centroid)^2, na.rm = TRUE))
  s_WGSS <- sum(rowSums((s_dist_final - s_centroid)^2, na.rm = TRUE))
  as_WGSS <- a_WGSS + s_WGSS
  
  # Calinski-Harabasz Index
  # Cluster number: K = 2; Sample number: N = nrow(a_dist) + nrow(s_dist); 1 is constant
  # (as_BGSS / (2 - 1)) / (as_WGSS / ((nrow(a_dist) + nrow(s_dist)) - 2)) == (as_BGSS / as_WGSS) * (nrow(a_dist) + nrow(s_dist) - 2) / (2 - 1)
  avss_ch_index <- (as_BGSS / (2 - 1)) / (as_WGSS / ((nrow(a_dist) + nrow(s_dist)) - 2))
  # potential gene index
  potential_index <- avss_ch_index * factor
  
  # extract gene name
  # append a BGSS, WGSS and CH-index to the empty data frame
  extract_gene_name <- function(filename) {
    base_name <- basename(filename)
    gene_name <- gsub("_a\\.fasta$", "", base_name)
    return(gene_name)
  }
  gene_name <- extract_gene_name(a_file)
  IL_12_dist_index <- rbind(IL_12_dist_index, data.frame(Gene = gene_name,
                                                         active_BGSS = a_BGSS, silent_BGSS = s_BGSS, BGSS = as_BGSS,
                                                         active_WGSS = a_WGSS, silent_WGSS = s_WGSS, WGSS = as_WGSS,CH_index = avss_ch_index,
                                                         a_count = active_count, s_count = silent_count, as_ratio = a_s_ratio, as_sum = a_s_sum,
                                                         zero_dist_count = zero_count, zero_dist_ratio = zero_ratio, seq_dist_factor = factor,
                                                         potential_gene_index = potential_index))
  
  if (all(as_dist_final == 0)) {
    file.rename(cat_gene_name, paste0(multi_dist_zero_folder, "/", basename(cat_gene_name)))
    write.csv(as_dist_final, quote = FALSE,
              paste0(multi_dist_zero_folder, "/",
                     basename(gsub("\\.fasta$", ifelse(any(is.nan(as_dist)), "_NA", ""),
                                   basename(cat_gene_name))),
                     ".csv")
    )
  } else {
    heatmap_title <- gsub("\\.fasta$", "", basename(cat_gene_name))
    heatmap_name <- file.path(multi_cluster_folder, gsub("\\.fasta$", "_heatmap.pdf", cat_gene_name))
    pheatmap(as_dist_final, color = colorRampPalette(rev(brewer.pal(n = 7, name = "RdYlBu")))(100), 
             kmeans_k = NA, border_color = NA, cellwidth = NA, cellheight = NA,
             cluster_rows = TRUE, cluster_cols = TRUE,
             clustering_distance_rows = "euclidean", clustering_distance_cols = "euclidean",
             clustering_method = "complete",
             scale = "none", show_colnames = TRUE, number_color = "black",
             fontsize = 8, fontsize_number = 6, main = heatmap_title,
             filename = heatmap_name, breaks = NA)
    # move the processed and alignment file to correspondent folder
    file.rename(cat_gene_name, paste0(multi_cat_folder, "/", basename(cat_gene_name)))
    write.csv(as_dist_final, quote = FALSE,
              paste0(multi_cluster_folder, "/",
                     basename(gsub("\\.fasta$", ifelse(any(is.nan(as_dist)), "_NA", ""),
                                   basename(cat_gene_name))),
                     ".csv")
    )
  }
  
  # move the processed file to correspondent folder
  file.rename(a_file, paste0(multi_compare_folder, "/", basename(a_file)))
  file.rename(s_file, paste0(multi_compare_folder, "/", basename(s_file)))
  
  # log progress
  ch_index_msg <- paste(Sys.time(), ": Processed", a_file, "and", s_file, "\n")
  cat(ch_index_msg, file = ch_index_log_file, append = TRUE)
}

# Check the format of values in CH_index column
class(IL_12_dist_index$potential_gene_index)
# filter out the Inf value
IL_12_dist_index_filtered <- IL_12_dist_index[!is.infinite(IL_12_dist_index$potential_gene_index), ]
range(IL_12_dist_index_filtered$potential_gene_index)
IL_12_dist_index_filtered$poten_order <- NA
write_xlsx(IL_12_dist_index_filtered, path = '~/Downloads/Master_Graduation/comparative_genome_analyses/statistic_analyses2/IL-12_avss/12_cds_dist_index_filtered.xlsx', format_headers = TRUE)

# The returned results is the csv file with "_NA"
setwd('~/Downloads/Master_Graduation/comparative_genome_analyses/statistic_analyses2/IL-12_avss/avss_cds/avss_cds_multi_compare/cds_dist')
all_files <- list.files(pattern = "\\.csv$")
a_csv <- grep('_a.csv', all_files, value = TRUE)
a_basename <- gsub('_a.csv$', "", a_csv)

s_csv <- grep('_s.csv', all_files, value = TRUE)
s_basename <- gsub('_s.csv$', "", s_csv)

missing_a <- setdiff(s_basename, a_basename)
missing_s <- setdiff(a_basename, s_basename)

if (length(missing_a) > 0) {
  cat("The following _s.csv don't have a corresponding _a.csv: \n")
  cat(paste0(missing_a, "_s.csv", collapse = "\n"), "\n\n")
}

if (length(missing_s) > 0) {
  cat("The following _a.csv don't have a corresponding _s.csv: \n")
  cat(paste0(missing_s, "_a.csv", collapse = "\n"), "\n\n")
}

IL_12_dist_index_filtered <- readWorkbook(loadWorkbook('~/Downloads/Master_Graduation/comparative_genome_analyses/statistic_analyses2/IL-12_avss/12_cds_dist_index_all.xlsx'), sheet = "Sheet1")

# 将 potential_gene_index 列转换为数值型，处理数据
# 查看潜在的问题字符
table(IL_12_dist_index_filtered$potential_gene_index)

# 将 potential_gene_index 列转换为数值型
IL_12_dist_index_filtered$potential_gene_index <- as.numeric(IL_12_dist_index_filtered$potential_gene_index)

