all: stdc.pdf demodesign.pdf

stdc.pdf: stdc.tex
	pdflatex $<
	pdflatex $<

demodesign.pdf: demodesign.tex
	pdflatex $<
	pdflatex $<

clean:
	rm -f stdc.pdf stdc.aux stdc.log
	rm -f demodesign.pdf demodesign.aux demodesign.log

.PHONY: clean
