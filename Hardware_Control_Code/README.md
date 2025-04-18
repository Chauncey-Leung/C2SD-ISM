# Hardware Parameter Settings

This section describes the **LabVIEW parameter settings** and the corresponding **camera software (HCImageLive)** parameters that align with the LabVIEW configuration.

We also include **Table 1**, which explains the meanings of various parameters on the **LabVIEW front panel**. For details on the camera software parameters, please refer to the official documentation of the Hamamatsu camera:  
👉 [https://hcimage.com/support/](https://hcimage.com/support/)

## Table 1. Explanation of Parameters in the LabVIEW Front Panel

| **Parameter Name**        | **Adjustable** | **Notes**                                                                                      |
|---------------------------|----------------|------------------------------------------------------------------------------------------------|
| X size                    | ✅             | Number of scanning steps of the galvo along the fast axis.                                     |
| Y size                    | ✅             | Number of scanning steps of the galvo along the slow axis.                                     |
| Amplitude X              | ✅             | Total step voltage of the galvo in the fast axis direction.                                    |
| Amplitude Y              | ✅             | Total step voltage of the galvo in the slow axis direction.                                    |
| Scan range (μm)          | ✅             | Axial (z-axis) scan depth.                                                                     |
| Step size (μm)           | ✅             | Axial (z-axis) step increment.                                                                 |
| Multicolor               | ✅             | Number of laser wavelengths used in multicolor imaging.                                        |
| Exposure time            | ✅             | Exposure duration per image.                                                                   |
| Vertical                 | ✅             | Number of rows in each acquired image, affecting camera readout time.                          |
| Point precision (μs/pt)  | ✅             | Sampling resolution, typically 10 μs/point.                                                     |
| Slope                    | ✅             | Ratio of galvo movement time to total readout time. Generally 30%.                             |
| Dwell time               | ✅             | Ratio of galvo stabilization time to total readout time. Generally 70%.                        |
| Z calibration            | ✅             | Calibrate piezo stage so that the initial axial position aligns with the desired reference.    |
| First                    | ✅             | First galvo step’s voltage multiple compared to others.                                        |
| Num of cycle             | ✅             | Total cycles for multicolor and axial scanning.                                                |
| Num of captured cycle    | ✅             | Number of captured cycles.                                                                     |
| Time consumed            | ❌ (auto)       | Automatically calculated total scan duration.                                                  |
| Camera frame rate        | ❌ (auto)       | Frames per second under external trigger. Must match HCImageLive settings.                     |
| Number of camera frames  | ❌ (auto)       | Total frames acquired per scan cycle. Must be set in HCImageLive.                              |
| Acquisition rate         | ❌ (auto)       | Automatically calculated rate based on time per cycle.                                         |

## Figure

**Figure 1**. LabVIEW control code front panel.  
(*Figure not included in this version.*)

---
