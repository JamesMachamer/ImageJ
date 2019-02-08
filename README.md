# Muscle fiber analysis
This macro allows the user to perform two coupled tasks:

1) Identify muscle fibers based on staining and measure their cross sectional area.
2) Identify the myosin subtypes present in the muscle fiber based on visually determined lower threshold levels

Requirements:  This macro utilized plugins that are loaded with FIJI v 2.0.0-rc-65/1.52i/Java 1.8_066 (64-bit).  Additionally, this macro requires LSM files that has atleast a dystrophin channel.  If no myosin channels are present, only the area will be measured.  

After starting the macro, select a folder that contains the LSM files that you want to analyze.  When each LSM file is loaded, a folder is created with the same name that will contain the results.  When the file is loaded, the identity of each channel has to be set. Analysis of muscle fiber area will be peformed by a semiautomated analysis of the dystrophine channel using the following method:

1) A local thresholding algorithm will be applied to identify the dystrophine stain.
2) A neurite tracing algorithm identifies putative signle dimensional borders of the fibers based on the dystrophin thresholding.  
3) Neurites that dont form loops are trimmed.
4) The area between the dystrophin borders are selected as muscle fibers.
5) The user then inputs the upper and lower thresholds for muscle fiber size (initialized at >X um and <Y um) and the minimum roundness (initialized at X)
6) 

