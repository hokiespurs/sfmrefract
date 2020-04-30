# sfmrefract
Matlab implementation of Dietrich(2017) to account for refraction in Structure from Motion(SfM) pointcloud data. The algorithm has been written to read standard outputs from from Agisoft Metashape

## References
Algorithm implemented is from:
> Dietrich JT. 2017. Bathymetric Structure-from-Motion: extracting shallow stream bathymetry from multi-view stereo photogrammetry. Earth Surface Processes and Landforms 42 : 355–364. DOI: 10.1002/esp.4060

Python implementation and more documentation on the algorithm from Dietrich here:
> https://geojames.github.io/py_sfm_depth/

NOAA Technical Memorandum on using SfM for bathymetric coastal mapping:
> https://coastalscience.noaa.gov/data_reports/guidelines-for-bathymetric-mapping-and-orthoimage-generation-using-suas-and-sfm-an-approach-for-conducting-nearshore-coastal-mapping/

## Quick Start with Agisoft Metashape
1. Process SfM project and export:
   * pointcoud in LAS format (File -> Export Points)
   * camera interior orientation (Tools -> Camera Calibration -> Adjusted Tab -> Save icon > \*.xml (Agisoft Camera Calibration)
   * camera exterior orientation (File -> Export Cameras -> \*.txt (omega phi kappa)
2. Estimate the mean water elevation using one of the following methods:
   * Tide gauge
   * visually by clicking points along shoreline
3. Modify `runsfmrefract.m`
   * update the pointcloud, io, and eo files
   * modify the ior, and input the mean water elevation (ensure the correct vertical datum)
4. Run the script.

## SfM for Bathymetry Considerations
SfM and UAS provide an inexpensive, low cost method to acquire bathymetric data over clear, calm water.  There are many parameters which should be considered in order to maximize the probability of the generated data being accurate.  For example: Low seafloor texture, low quality UAS GNSS, large waves, whitecaps, water turbidity, sensor noise, and more can all independently reduce the SfM accuracy to a point where the final data is inaccurate. This algorithm assumes the commercial SfM software was able to generate an accurate pointcloud.  Often times with SfM, you can get a pointcloud that "looks" good, but is actually very inaccurate.  This algorithm can not fix bad data, it can only make good data better.

More detailed suggestions can be found at the link provided in a [NOAA Technical Memorandum(2019)](https://coastalscience.noaa.gov/data_reports/guidelines-for-bathymetric-mapping-and-orthoimage-generation-using-suas-and-sfm-an-approach-for-conducting-nearshore-coastal-mapping/)

## Performance
The algorithm is currently very slow, which was ok for my applications.  There are however, a few ways to speed it up:
1. The algorithm is "embarassingly parallel", and you could easily change one of the for loops to a parfor
2. If you ultimately just want a DSM, you can grid the data first, then pass the gridded data to the `sfmrefract.m` script through the pcdata field as an [Nx3] xyz array.  Understand that there are assumptions that go into this, which may yield less accurate results than if you were to refraction correct the pointcloud, then grid it.  
3. If you want to get a pointcloud, you can use the same DSM correction method to compute a gridded mesh of "correction factors". For every point in the pointcloud, use its horizontal coordinates to interpolate a correction factor from the gridded mesh, and adjust the eleavtion of that point.  Again, this is a bit of a shortcut and you should ensure that this shortcut isn't causing you to lose significant accuracy.
