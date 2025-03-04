library(yaml)
library(formattable)

# args <- commandArgs(T)
# folder <- args[1]
# folder <- 'CMU-DS'
folder <- ''
# setwd("C:/Users/RY/git/stateacher/Data/")
setwd(paste0('/home/runner/work/stateacher/stateacher/Data/', folder, '/'))

load_yaml <- function(x){
  yaml_end_idx <- which(!is.na(stringr::str_locate(readLines(x, encoding = 'utf-8'), pattern = '^(---)'))[,1])[2]
  x <- readLines(x, encoding = 'utf-8')[1:yaml_end_idx]
  x <- yaml.load(x)
  return(x)
}

f <- list.files(pattern = paste0('.*md$'), recursive = TRUE, full.names = TRUE)
f <- grep('.md', f, value = TRUE)
f_yaml_length <- unlist(lapply(f, function(x) length(unlist(load_yaml(x)))))


md_Stat <- function(x, section = templateNames) {
  txt = readLines(x, encoding = 'UTF-8')
  txt_N = length(txt)
  txt_nchar = nchar(txt)
  txtSectionInd = grep('^# ', txt)
  ind_N = length(txtSectionInd)
  
  ind1 = txtSectionInd + 1
  ind2 = c(txtSectionInd[-1] - 1, txt_N)
  
  # 乘数调整
  flag = 1 * (sign(ind2 -ind1) > 0.5)   
  tab = unlist(lapply(1:length(ind1), 
                      function(i) flag[i] * sum(txt_nchar[ind1[i]:ind2[i]])))
  # 减去![name](link)的长度
  tab[1] = tab[1] - 13
  names(tab) = grep('^# ', txt, value = TRUE)
  tab[which(is.na(tab))] = 0
  return(tab)
}

md_tab = unlist(lapply(f, function(x) sum(md_Stat(x)>0)))
dat = data.frame(id = seq_len(length(f)), name = f, yaml_inut = f_yaml_length, md_input = md_tab)

tb <- formattable(dat, list(yaml_inut = color_tile("white", "orange")))
html_header="
<head>
<meta charset=\"utf-8\">
<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
<link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css\">
</head>
<body>
"
write(paste(html_header, tb, sep=""), file = paste0("summary.html"))
print("Your summary.html file has been generated")
