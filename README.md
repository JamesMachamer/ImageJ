# Muscle fiber analysis
This macro allows the user to perform two coupled tasks:

1) Identify muscle fibers based on staining and measure their cross sectional area.
2) Identify the myosin subtypes present in the muscle fiber based on visually determined lower threshold levels

Requirements:  This macro utilized plugins that are loaded with FIJI v X.X.  Additionally, this macro requires LSM files that has atleast one channel.  If no myosin channels are present, only the area will be measured.  

After starting the macro, select a folder that contains the LSM files that you want to analyze.  When each LSM file is loaded, a folder is created with the same name that will contain the results.  When the file is loaded, the identity of each channel has to be set. Fibers will then be identified in the X channel using the following toolsets: 

Erroneoussly identified fibers can be eliminated by first thresholding based on upper and lower size limits as well as roundness and second by direct selection and deletion of ROIs that don't repre
