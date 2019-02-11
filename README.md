# Muscle fiber analysis

Requirements

ImageJ Requirements:  This macro was coded to run on FIJI v 2.0.0-rc-65/1.52i/Java 1.8_066 (64-bit).
Image requirements: This macro requires LSM files containing a dystrophin channel.  If no myosin channels are present, only the area will be measured. 

Macro Summary

  This macro allows the user to perform two tasks, the second being dependent on the completion of the first:
  1) Identify muscle fibers based on dystrophin staining, exclude fibers based on measurement thresholding, directly delete erroneously detected fiber, and measure the cross-sectional areas of all detected fibers.
  2) Measure the intensity of staining for each other channel (myosin), determine if a fiber is positive or negative for each myosin based on a minimum intensity threshold, and count the number of fibers positive for each myosin subtype and combination of myosin subtypes.

Starting analysis

  First, all of the LSM files that you want to analyze need to be placed in a single folder. To analyze images, run the macro and select the folder containing the LSM files when prompted.  Each LSM file will be loaded sequentially and after the analysis is completed the results will be saved in a folder with the same name as the LSM file.

Setting Channels

  When the file is loaded, the identity of each channel has to be set. The macro will detect how many channels are present and an identity has to be assigned for each channel: dystrophin, myosin 1, myosin 2, myosin 3, or not analyzed.  The dystrophin channel will be used to identify individual fibers and measure cross-sectional area.  The myosin channels will be used identify the myosin subtypes presence in each fiber.

Fiber identification

First, putative muscle fibers are identified through the application of the following steps:

1) A local thresholding algorithm will be applied to create a binary image of dystrophin stain.
2) A neurite tracing algorithm used the binary image to identify single pixel width skeletons of the binary dystrophin thresholding.  
3) Neurite end branches are pruned to eliminate false or incomplete dystrophin staining.
4) Areas completely surrounded by the skeletonized dystrophin staining are selected as muscle fibers.

Fiber area thresholding 

1) Muscle fibers are identified by outline in dystrophin image that have areas above the preset minimum threshold area (X um), below the preset maximum threshold area (Y um) and above the preset minimum roundness (X)
2) The user may adjust the threshold values by sliding the bar or entering in values directly
3) Updating the analysis will generate a new set of fiber outlines reflecting the new threshold values.
4) Value adjustments and updating can be performed until the user is satisfied with the identified fibers
5) The user may proceed to the next step by selecting "finished" from the pull-down menu and pressing ok.

Direct elimination of fibers

Next, select individual fiber outlines and press delete to eliminate them from analysis.  Press "OK" when satisfied with the remaining fibers.

Determining fiber myosin subtype identity

The average signal intensity for each myosin subtype channel within the area of each identified fibers is measured and values below the selected threshold are identified as "negative" and those above the selected threshold level are identified as "positive" 
