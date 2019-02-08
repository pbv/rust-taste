
TEMPLATE=revealjs-template.html

CSS=reveal.js/css/theme/white.css

#slides.html : slides.md $(TEMPLATE) $(CSS) Makefile
#	pandoc -s -t revealjs --mathjax -V css=$(CSS) -V math="<script type="text/javascript" src="file:///home/pbv/MathJax-2.7.4/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>" -V transition=linear --template=$(TEMPLATE) slides.md -o slides.html


slides.html : slides.md $(TEMPLATE) $(CSS) Makefile
	pandoc -s -t dzslides -V css=dzslides.css --mathjax -V math="<script typ="text/javascript" src="file:///home/pbv/MathJax-2.7.4/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>" slides.md -o slides.html


