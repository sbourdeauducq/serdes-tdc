all: tdc.pdf testreport.pdf

tdc.pdf: tdc.tex
	pdflatex $<
	pdflatex $<

mhist.pdf: mhist.py measurements.csv
	./mhist.py measurements.csv mhist.pdf 01 fit

testreport.pdf: testreport.tex #mhist.pdf
	pdflatex $<
	pdflatex $<

clean:
	rm -f tdc.pdf tdc.aux tdc.log
	rm -f mhist.pdf
	rm -f testreport.pdf testreport.aux testreport.log

.PHONY: clean
