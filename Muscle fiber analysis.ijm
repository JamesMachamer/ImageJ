//Select files to be analyzed
target_directory = getDirectory("Choose a Directory for analysis");
file_list = getFileList(target_directory);
setBatchMode(true);

//Open files and convert to 8 bit
for (i=0; i<lengthOf(file_list); i++) {
	if (endsWith(file_list[i],".lsm") == true) {
		call("ij.gui.ImageWindow.setNextLocation", 0, 0);
		open(target_directory+file_list[i]);
		setBatchMode("show");
		run("Set Measurements...", "area redirect=None decimal=3");
		if (bitDepth != 8) {
			run("8-bit");
		}

//Assign channel identities 
		Dialog.create("Assign identity of myosin isoform to channels"); 
		stain = newArray("Dystrophin", "Myosin 1", "Myosin 2", "Myosin 3", "Myosin 4", "Don't Analyze");
		staindefault = newArray("Dystrophin", "Myosin 1", "Myosin 2", "Myosin 3");
		zoom = getZoom();
		getDimensions(xx, yy, channels, slices, frames);
		for(p=1; p<=channels; p++){
			Dialog.addRadioButtonGroup("Channels " + p, stain, 1, 4, staindefault[p-1]);
		}		
		Dialog.setLocation((xx*zoom)+10,0);
		Dialog.show; 
		
//create a list for each channel and set the second column to the value of stain
		for(p=1; p<=channels; p++){
		ab = Dialog.getRadioButton;
		List.set(ab, p);
		List.set(p,ab);
		}
		
// file naming conventions and folder creations
		name = File.name;
		nameonly = File.nameWithoutExtension ;
		namepart = File.nameWithoutExtension + " threshold";
		new_directory = target_directory+nameonly;
		File.makeDirectory(new_directory);
		run("Split Channels");

// rename windows

		for(p=1;p<=channels; p++){
			selectWindow("C"+p+"-"+name);
			rename(List.get(p)+"-"+name);
			if(List.get(p) == "Don't Analyze"){
				close();
			}
		}

// fiber area auto analysis
		
		selectWindow("Dystrophin-"+name);
		setBatchMode("show");
		setLocation(0,0,screenHeight*0.85,screenHeight*0.85);
		run("Enhance Contrast...", "saturated=0.3");
		thname = "Threshold "+ getTitle();
		run("Duplicate...", "title=&thname");
		run("8-bit");
		run("Auto Local Threshold", "method=Median radius=10 parameter_1=0 parameter_2=0 white");
		run("Invert");
		run("Fill Holes");
		run("Invert");
		run("Options...", "iterations=3 count=4 black edm=8-bit do=Close");
		run("Skeletonize");
		run("Analyze Skeleton (2D/3D)", "prune=none prune_0");
		run("Clear Results");
		selectWindow(thname);
		run("Invert");
		run("Options...", "iterations=1 count=2 black edm=8-bit do=Erode");
		setBatchMode("show");
		setLocation(screenHeight*0.85,0,screenHeight*0.85,screenHeight*0.85);

//Thresholding fiber size
		
		ROI_AREA_MIN_STORE = 150;
		ROI_AREA_MAX_STORE = 2500;
		ROI_CIRC_STORE = 35;
		ROI_CIRC_SCALE = ROI_CIRC_STORE/100;
		
		run("Select All");
		run("Analyze Particles...", "size=ROI_AREA_MIN_STORE-ROI_AREA_MAX_STORE circularity=ROI_CIRC_SCALE_STORE-1.0 show=Nothing exclude clear add");
		run("Analyze Particles...", "size=ROI_AREA_MIN_STORE-ROI_AREA_MAX_STORE circularity=ROI_CIRC_SCALE_STORE-1.0 show=Nothing exclude clear add");
		
		selectWindow(thname);
		roiManager("show all with labels");
		items = newArray("Finished", "Update"); 
		Rerun1 = "Update";
		
		while(Rerun1 == "Update"){
			Dialog.create("Create fiber outlines"); 
			Dialog.addSlider(List.get(p) + " Minimum Area threshold", 0, 1000, ROI_AREA_MIN_STORE);
			Dialog.addSlider(List.get(p) + " Maximum Area threshold", 0, 4000, ROI_AREA_MAX_STORE);
			Dialog.addSlider(List.get(p) + " Circularity", 0, 100, ROI_CIRC_STORE);
			Dialog.addChoice("Choose_to_move_to_the_next_step", items, "Update");
			Dialog.setLocation(600,830);
			Dialog.show; 
			
			Rerun1 = Dialog.getChoice();
			ROI_AREA_MIN = Dialog.getNumber();
			ROI_AREA_MAX = Dialog.getNumber();
			ROI_CIRC = Dialog.getNumber();
			ROI_AREA_MIN_STORE = ROI_AREA_MIN;
			ROI_AREA_MAX_STORE = ROI_AREA_MAX;
			ROI_CIRC_STORE = ROI_CIRC;
			ROI_CIRC_SCALE = ROI_CIRC_STORE/100;
			
			run("Select All");
			run("Analyze Particles...", "size=ROI_AREA_MIN_STORE-ROI_AREA_MAX_STORE circularity=ROI_CIRC_SCALE-1.0 show=Nothing exclude clear add");
			run("Analyze Particles...", "size=ROI_AREA_MIN_STORE-ROI_AREA_MAX_STORE circularity=ROI_CIRC_SCALE-1.0 show=Nothing exclude clear add");
			selectWindow(thname);
			roiManager("show all with labels");			
			run("Clear Results");
		}

//Removing erroneously detected fibers by hand
		
		setTool("wand");
		waitForUser("Remove erroneous fibers, then press OK");
		
//Measuring fibers and saving data
		run("Hide Overlay");
		run("Select All");
		run("Analyze Particles...", "size=ROI_AREA_MIN-ROI_AREA_MAX circularity=ROI_CIRC_SCALE-1.0 show=Nothing exclude clear add");
		Table.create(nameonly+" myosin identities");
		
		for (k=0; k < roiManager("count"); k++) {
			roiManager("select", k);
			roiManager("measure");
			ROI_AREA = getResult("Area",k);
			Table.set("ROI", k , k, nameonly+" myosin identities"); 
			Table.set("Area", k, ROI_AREA, nameonly+" myosin identities");
		}
		
		
		run("Clear Results");
		roiManager("Save", new_directory + "\\" + nameonly + " ROIs.zip");
		selectWindow("Dystrophin-"+name);
		close();
		selectWindow(thname);
		saveAs("Tiff", new_directory + "\\" + thname); 
		close();
	
//Finding maximum average intensity of selected channel 
	
	for(p=1; p<=channels; p++){
		
		if(List.get(p)!=stain[0] && List.get(p)!=stain[5]){
		selectWindow(List.get(p)+"-"+name);
		run("8-bit");
		setBatchMode("show");
		setLocation(0,0,screenHeight*0.85,screenHeight*0.85);
		
		run("Set Measurements...", "area mean integrated redirect=None decimal=3");
		run("Select All");
		run("Measure");
		DENSITY_TOTAL = getResult("IntDen", 0);
		AREA_SUM = getResult("Area", 0);
		run("Clear Results");

		ROI_DENSITY_TOTAL = 0;
		ROI_AREA_SUM = 0;
		ROI_AVG_MAX = 0;
		
		for (k=0; k < roiManager("count"); k++) {
			roiManager("select", k);
			Roi.setStrokeColor("yellow")
			roiManager("measure");
			ROI_AVG = getResult("Mean",k);
			ROI_DENSITY = getResult("IntDen",k);
			ROI_AREA = getResult("Area",k);
			ROI_AREA_SUM = ROI_AREA_SUM + ROI_AREA;
			ROI_DENSITY_TOTAL = ROI_DENSITY_TOTAL + ROI_DENSITY;
			if(ROI_AVG > ROI_AVG_MAX){
				ROI_AVG_MAX = ROI_AVG;
			}
		}
		
		run("Clear Results");
		roiManager("show all without labels");
		run("Enhance Contrast...", "saturated=0.3");
	
	//Create dialog box to threshold channel
	
		BACKGROUND = (DENSITY_TOTAL-ROI_DENSITY_TOTAL)/(AREA_SUM-ROI_AREA_SUM);
		ROI_AVG_MIN_STORE = (ROI_AVG_MAX-BACKGROUND)/4 + BACKGROUND;
		
		for (k=0; k < roiManager("count"); k++) {
				roiManager("select", k);
				roiManager("measure");
				ROI_AVG = getResult("Mean",k);
				if (ROI_AVG < ROI_AVG_MIN_STORE){
					Roi.setStrokeColor("blue");
					Table.set(List.get(p), k , 0, nameonly+" myosin identities");
					Table.set(List.get(p)+ " MEAN", k , ROI_AVG, nameonly+" myosin identities");
				}
				if (ROI_AVG > ROI_AVG_MIN_STORE){
					Roi.setStrokeColor("red");
					Table.set(List.get(p), k , 1, nameonly+" myosin identities"); 
					Table.set(List.get(p)+ " MEAN", k , ROI_AVG, nameonly+" myosin identities");
				}
			}
			run("Clear Results");
			roiManager("show all without labels");
		
		Rerun2 = "Update";
		while(Rerun2 == "Update"){
			Dialog.create(List.get(p) + " Thresholding"); 
			Dialog.addChoice("Choose_to_move_to_the_next_step", items, "Update");
			Dialog.addSlider(List.get(p) + " Lower intensity threshold", 0, ROI_AVG_MAX, ROI_AVG_MIN_STORE);
			Dialog.setLocation(screenHeight*0.85,0);
			Dialog.show; 
			Rerun2 = Dialog.getChoice();
			ROI_AVG_MIN = Dialog.getNumber();
			ROI_AVG_MIN_STORE = ROI_AVG_MIN;
	
	//Alter ROI colors based on threshold and populate data table of results
			for (k=0; k < roiManager("count"); k++) {
				roiManager("select", k);
				roiManager("measure");
				ROI_AVG = getResult("Mean",k);
				if (ROI_AVG < ROI_AVG_MIN_STORE){
					Roi.setStrokeColor("blue");
					Table.set(List.get(p), k , 0, nameonly+" myosin identities");
					Table.set(List.get(p)+ " MEAN", k , ROI_AVG, nameonly+" myosin identities");
				}
				if (ROI_AVG > ROI_AVG_MIN_STORE){
					Roi.setStrokeColor("red");
					Table.set(List.get(p), k , 1, nameonly+" myosin identities"); 
					Table.set(List.get(p)+ " MEAN", k , ROI_AVG, nameonly+" myosin identities");
				}
			}
			run("Clear Results");
			roiManager("show all without labels");
		}
		setBatchMode("Hide");
		}
		
	}
	Table.update;
	Table.save(new_directory + "\\" + nameonly + " Channel_results.csv");
// Analyze fiber type numbers and ratios
	
	m0 = 0;
	m1 = 0;
	m2 = 0;
	m3= 0;
	m12= 0;
	m13= 0;
	m123= 0;
	m23= 0;
	myoname = newArray("myosin 1 only", "myosin 2 only", "myosin 3 only", "myosin 1 and 2", "myosin 1 and 3", "myosin 2 and 3", "myosin 1 and 2 and 3", "myosin 1 total", "myosin 2 total", "myosin 3 total", "unstained");
	
	for (k=0; k<roiManager("count"); k++) {
		if (Table.get("Myosin 1", k)==1 && Table.get("Myosin 2", k)==1 && Table.get("Myosin 3", k)==1) {
			m123++;}
		if (Table.get("Myosin 1", k)==1 && Table.get("Myosin 2", k)==1 && (Table.get("Myosin 3", k)==0||Table.get("Myosin 3",k)==NaN)) {
			m12++;}
		if (Table.get("Myosin 1", k)==1 && Table.get("Myosin 3", k)==1 && (Table.get("Myosin 2", k)==0||Table.get("Myosin 2",k)==NaN)) {
			m13++;}
		if (Table.get("Myosin 2", k)==1 && Table.get("Myosin 3", k)==1 && (Table.get("Myosin 1", k)==0||Table.get("Myosin 1",k)==NaN)) {
			m23++;}
		if (Table.get("Myosin 1", k)==1 && (Table.get("Myosin 2", k)==0||Table.get("Myosin 2",k)==NaN) && (Table.get("Myosin 3", k)==0||Table.get("Myosin 3",k)==NaN)) {
			m1++;}
		if (Table.get("Myosin 2", k)==1 && (Table.get("Myosin 1", k)==0||Table.get("Myosin 1",k)==NaN) && (Table.get("Myosin 3", k)==0||Table.get("Myosin 3",k)==NaN)) {
			m2++;}
		if (Table.get("Myosin 3", k)==1 && (Table.get("Myosin 2", k)==0||Table.get("Myosin 2",k)==NaN) && (Table.get("Myosin 1", k)==0||Table.get("Myosin 1",k)==NaN)) {
			m3++;}
		if ((Table.get("Myosin 3", k)==0||Table.get("Myosin 3",k)==NaN) && (Table.get("Myosin 2", k)==0||Table.get("Myosin 2",k)==NaN) && (Table.get("Myosin 1", k)==0||Table.get("Myosin 1",k)==NaN)) {
			m0++;}
	}
	
	m1t = m1+m12+m13+m123;
	m2t = m2+m12+m23+m123;
	m3t = m3+m13+m23+m123;
	mtotal = m1+m2+m3+m12+m23+m13+m123+m0;
	mtotalexclude = m1+m2+m3+m12+m23+m13+m123;
	myo = newArray(m1,m2,m3,m12,m13,m23,m123,m1t,m2t,m3t,m0);
	Table.create(nameonly+" myosin totals");
	
	for (k=0; k<11; k++){
		Table.set("Name", k ,myoname[k], nameonly+" myosin totals");
		Table.set("counts", k ,myo[k], nameonly+" myosin totals");
		Table.set("percent", k ,myo[k]*100/mtotal, nameonly+" myosin totals");
		Table.set("percent excluding unstained", k ,myo[k]*100/mtotalexclude, nameonly+" myosin totals");
	}
	Table.update;
	Table.save(new_directory + "\\" + nameonly + " Sorted_results.csv");
	}
	
}
	




