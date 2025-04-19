// Read macro arguments
args = getArgument();
print("Macro Args: " + args);

inputPath = "";
outputDir = "";

// Parse input and output parameters
if (args != "") {
    parts = split(args, " ");
    for (i = 0; i < parts.length; i++) {
        if (startsWith(parts[i], "input=")) {
            inputPath = replace(parts[i], "input=", "");
            inputPath = replace(inputPath, "\"", "");  // 去除双引号
        }
        if (startsWith(parts[i], "output=")) {
            outputDir = replace(parts[i], "output=", "");
            outputDir = replace(outputDir, "\"", "");
        }
    }
}

// Check for valid paths
if (inputPath == "") {
    print("Error: input path is empty!");
    exit();
}
if (outputDir == "") {
    outputDir = File.getParent(inputPath);
}
File.makeDirectory(outputDir);

// Open image
print("Opening: " + inputPath);
open(inputPath);

// Check if the image was successfully opened
if (isOpen(File.getName(inputPath)) == 0) {
    print("Error: Failed to open input image!");
    exit();
}

// Check if the image is a stack
if (nSlices < 2) {
    print("Error: Opened image is not a stack!");
    exit();
}

// Get base file name
name = File.getNameWithoutExtension(inputPath);

// Run alignment
run("Linear Stack Alignment with SIFT",
    "initial_gaussian_blur=1.60 " +
    "steps_per_scale_octave=3 " +
    "minimum_image_size=64 " +
    "maximum_image_size=1024 " +
    "feature_descriptor_size=4 " +
    "feature_descriptor_orientation_bins=8 " +
    "closest/next_closest_ratio=0.92 " +
    "maximal_alignment_error=25 " +
    "inlier_ratio=0.05 " +
    "expected_transformation=Affine interpolate");

// Save only the second slice
outFile = outputDir +  "\\resDPAPR.tif";
print("Saving to: " + outFile);
//saveAs("Tiff", outFile);
setSlice(2);
// Duplicate the current slice to a new image
run("Duplicate...", "title=Slice2");
saveAs("Tiff", outFile);
// Close the new image
close("Slice2");
// Close the original image
close();
