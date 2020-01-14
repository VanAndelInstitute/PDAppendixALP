objects=\
	IndexPage/index.html \

all: navbar $(objects)


navbar: include/before_body.html

# Prepare navigation bar
include/before_body.html: code/generateNavigationBar.R index.json
	Rscript code/generateNavigationBar.R

# Rendering a Rmd file
# has to be redone if navbar has changed
%.html: %.Rmd include/before_body.html
	Rscript -e 'rmarkdown::render("$<", knit_root_dir="./")'
	touch $(dir $<)restart.txt

runAmiGO:
	# run by hand
	mkdir -p AmiGO/index
	cd AmiGO/index
	curl -O http://release.geneontology.org/2019-07-01/products/solr/golr-index-contents.tgz
	tar -zxvf golr-index-contents.tgz
	cd ..
	docker run -p 8080:8080 -p 9999:9999 -v ${PWD}:/srv/solr/data -t geneontology/amigo-standalone

run:
	docker run -p 3838:3838 -v ${PWD}:/srv/shiny-server/myapp:ro vugene/shinyserver


exportenv:
	conda env export --from-history | grep -v "^prefix: " > env.yml

importenv:
	conda env create --force --file env.yml