# install packages
pkgs.needs <- c("XML", "dplyr", "stringr")
pkgs.installed <- installed.packages()[,"Package"] 
new.pkgs <- pkgs.needs[!(pkgs.needs %in% pkgs.installed)]
if(length(new.packages)) install.packages(new.pkgs)                         
library(XML)      # readHTMLTable
library(dplyr)    # data manipulation & pipe line
library(stringr)  # str_pad

# define function
getPop <- function(yy, mm) {
  domain <- "http://cabu.kcg.gov.tw/Web/"
  url <- paste0(domain, "StatRpts/StatRpt1.aspx?yq=", yy, "&mq=", mm, "&dq=")
  tb = url %>% readHTMLTable 
  tbn = names(tb)
  check = paste0("高雄市各區", yy, "年", mm, "月戶口數月統計")
  tb = tb %>% .[[1]] %>% transform(年月 = paste0(yy, '.', mm))
  if(nrow(tb) > 1 & tbn == check) {return(tb)} else {stop("fail")}
}

# main proc
## init tables and progress bar
yy1 <- 100  # start
yy2 <- 106  # end
df <- data.frame(區域名 = character(),
                 里數 = integer(),
                 鄰數 = integer(),
                 戶數 = integer(),
                 人口數 = integer(),
                 男 = integer(),
                 女 = integer(),
                 年月 = character(),
                 stringsAsFactors = FALSE)
download_rec <- data.frame(ym = character(), status = character())
allComb <- length(c(yy1:yy2)) * length(c(1:12))
pb <- txtProgressBar(min = 0, max = allComb, init = 0, style = 3)
prog = 0

## get data
for(y in c(yy1:yy2)) {
  yy <- y
  for(m in c(1:12)) {
    mm <- m
    ym <- paste0(yy, '.', mm)
    rec <- data.frame()
    tryCatch({
      p <- getPop(yy, mm)
      df <- rbind(df, p)
      status <- "OK" 
    }, warning = function(w) {
      status <<- w$message
    }, error = function(e) {
      status <<- e$message 
    }, finally = {
      prog = prog + 1
      setTxtProgressBar(pb, prog)
    })
    rec <- cbind(ym, status) %>% as.data.frame
    download_rec <- rbind(download_rec, rec)
  }
}

# check data
df %>% head
df %>% tail
download_rec %>% head
download_rec %>% tail
