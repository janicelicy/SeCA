# Selective Colour Restoration of Underwater Surfaces 
 <p align="center">
 Chau Yi Li*, Andrea Cavallaro</br>
 Queen Mary University of London, London, United Kingdom</br>
 *chauyi.li@qmul.ac.uk</br>
 </p>

This is the repository for our Selective Colour Restoration of Underwater Surfaces (SeCA), in BMVC 2023. [Paper](https://bmvc2022.mpi-inf.mpg.de/228/)

SeCA is designed for images captured in blue water (Jerlov oceanic water) without artifical lights. 

![oki_23](https://user-images.githubusercontent.com/26412181/203165920-24142171-96e2-4ebe-8271-e60e8072a785.png)

Depeloying on images taken with artifical lights might over-enhanced some areas... Stay tuned for updates :ocean::ocean:

![651_img_](https://user-images.githubusercontent.com/26412181/203153605-2e88defb-c3ea-4686-a7d9-79cd70e34f84.png)

SeCA is a stable algorthm - you can extend it directly to videos without enforcing any temporal constraint! 

https://user-images.githubusercontent.com/26412181/166123110-7dcc50d6-0adf-4ec2-a521-dee660cc70a5.mp4

https://user-images.githubusercontent.com/26412181/166123202-a08c88ec-5738-43f6-b9e5-c71f25670a0b.mp4

## Using SeCA
 Put your test image in ./demo file and run the MATLAB file
 ```
 SeCA_BMVC
 ```

## Citation
 If you use the sample code or part of it in your research, please cite the following:
```
@inproceedings{Li_SeCA_2022_BMVC,
author    = {Chau Yi Li and ANDREA CAVALLARO},
title     = {Selective Colour Restoration of Underwater Surfaces},
booktitle = {33rd British Machine Vision Conference 2022, {BMVC} 2022, London, UK, November 21-24, 2022},
year      = {2022}
}
```
