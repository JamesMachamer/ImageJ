# Muscle fiber analysis
Requirements

ImageJ Requirements:  This macro was coded to run on FIJI v 2.0.0-rc-65/1.52i/Java 1.8_066 (64-bit). 
Image requirements: This macro requires LSM files containing a dystrophin channel.  If no myosin channels are present, only the  will be measured. 

Macro Summary

  This macro allows the user to perform two tasks, the second being dependent on the completion of the first:
  1) Identify muscle fibers based on dystrophin staining, exclude fibers based on measurement thresholding, directly delete erroneously detected fiber, and measure the cross sectional areas of all detected fibers.
  2) Measure the intensity of staining for each other channel (myosin), determine if a fiber is positive or negative for each myosin based on a minimum intensity threshold, and count the number of fibers positive for each myosin subtype and combination of myosin subtypes.

Starting analysis

  First, all of the LSM files that you want to analyze need to be placed in a single folder. To analyze images, run the macro and select the folder containing the LSM files when prompted.  Each LSM file will be loaded sequentially and after the analysis is completeed the results will be saved in a folder with the same name as the LSM file.

Setting Channels

  When the file is loaded, the identity of each channel has to be set. The macro will detect how many channels are present and an identity has to be assigned for each channel: dystrophine, myosin 1, myosin 2, myosin 3, or not analzed.  The dystrophin channel will be used to identify individual fibers and measure cross-sectional area.  The myosin channels will be used identify the myosin subtypes presence in each fiber.

Fiber area identification

The dystrophin channel will be used to identify muscle fibers through the following steps:

1) A local thresholding algorithm will be applied to create a binary image of dystrophine stain.
2) A neurite tracing algorithm used the binary image to identify single pixel width skeletons of the binary dystrophin thresholding.  
3) Neurite end branches are pruned to eliminate false or incomplete dystrophin staining.
4) The area between the dystrophin borders are selected as muscle fibers.
5) The user then inputs the upper and lower thresholds for muscle fiber size (initialized at >X um and <Y um) and the minimum roundness (initialized at X)
6) 

