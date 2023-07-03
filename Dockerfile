FROM rocker/r-ver:4.3.1

RUN apt-get update && apt-get install -y  wget git-core libcurl4-openssl-dev libgit2-dev libicu-dev libssl-dev libxml2-dev libmagick++-dev make pandoc pandoc-citeproc --fix-missing && rm -rf /var/lib/apt/lists/*

RUN echo "options(repos = 'https://packagemanager.rstudio.com/all/__linux__/focal/latest', download.file.method = 'libcurl')" >> /usr/local/lib/R/etc/Rprofile.site
RUN R -e 'install.packages("remotes")'
RUN R -e "install.packages('shiny')"
RUN R -e "install.packages('renv')"
RUN R -e 'renv::install("stringi@1.7.6",rebuild = TRUE, repos = "https://cran.rstudio.com/")'
RUN R -e "update.packages(ask=FALSE,repos='https://cran-r.c3sl.ufpr.br/',checkBuilt=TRUE,Ncpus=4)"
RUN Rscript -e 'remotes::install_version("rlang",upgrade="never", version = "0.4.10")'
RUN Rscript -e 'remotes::install_version("magrittr",upgrade="never", version = "2.0.1")'
RUN Rscript -e 'remotes::install_version("htmltools",upgrade="never", version = "0.5.4")'
RUN Rscript -e 'remotes::install_version("config",upgrade="never", version = "0.3.1")'
RUN Rscript -e 'install.packages("torch", repos="https://cloud.r-project.org")'
RUN Rscript -e 'torch::install_torch()'
RUN Rscript -e 'remotes::install_github("mlverse/torchvision")'
RUN Rscript -e 'remotes::install_github("decryptr/captcha@adcb53ce4c77b88dd928d36835ee39c8c636e4b6")'
RUN Rscript -e "remotes::install_github('LuizFelipeNeves/receita-cnpj-lib@607a4865546243febb2145f475658bce4835a958')"

# copy everything from the current directory into the container
COPY / /

# open port 80 to traffic
EXPOSE 80

# when the container starts, start the main.R script
ENTRYPOINT ["Rscript", "./inst/cnpj/app.R"]
