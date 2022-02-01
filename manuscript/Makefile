ALL: ms.html

optimg:
	optipng -o5 ../figures/*.png
	
ms.html: ms.Rmd
	Rscript -e 'rmarkdown::render("$(<F)", output_format = "bookdown::html_document2")'
	open $@
	
%.pdf: %.Rmd
	Rscript -e 'rmarkdown::render("$(<F)", output_format = "bookdown::pdf_document2")'
	open $@
	
%.docx: %.Rmd
	Rscript -e 'rmarkdown::render("$(<F)", output_format = "bookdown::word_document2")'
	open $@

diff.pdf: diff.tex 
	xelatex -interaction nonstopmode diff
	bibtex diff
	xelatex -interaction nonstopmode diff
	xelatex -interaction nonstopmode diff
	xelatex -interaction nonstopmode diff
	open diff.pdf

# diff.tex: geb_1st_submit.tex cooc.tex
# 	latexdiff geb_1st_submit.tex cooc.tex > diff.tex

diff.tex: ms.tex ms_submitted.tex
	latexdiff ms.tex ms_submitted.tex > diff.tex

clean:
	rm -f *.aux *.log *.out *.blg *.bbl
