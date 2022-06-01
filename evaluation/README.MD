##  Colour Accuracy Evaluation ##

We have annotated 42 colour charts from the [Sea-thru datasets](http://csms.haifa.ac.il/profiles/tTreibitz/datasets/sea_thru/index.html) using [LabelMe](http://labelme.csail.mit.edu/Release3.0/). 

Each of the 18 colour patch on the charts is indvidually labelled and indexed from 7 to 24. See below for the positions.

![dgk_reference_indexed](https://user-images.githubusercontent.com/26412181/171492093-db6ca66b-9418-43a5-be6c-78a712d7467b.png)

Evaluate the colour accuracy measured by [CIEDE2000](http://www2.ece.rochester.edu/~gsharma/ciede2000/ciede2000noteCRNA.pdf).  

1. Download the [LabelMe Matlab toolbox](http://labelme2.csail.mit.edu/Release3.0/browserTools/php/matlab_toolbox.php)
2. Run the provided Matlab code (run_evaluate.m)
