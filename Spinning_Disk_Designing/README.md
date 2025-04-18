# Spinning Disk Designing

**Main Program**: `generateSpiralMask.m`  
**Purpose**: Generate a spiral-arranged circular pinhole pattern and export it as a DXF file for use in spinning disk design (e.g., for spinning disk confocal microscopy or optical modulation masks).

---

## Dependencies

This script relies on the following helper functions:

- `makeSector()`  
  Computes spiral pinhole positions based on input parameters (radius, spacing, number of spirals).

- `addDXFEntities()`  
  Starts the DXF `ENTITIES` section.

- `addDXFCircles()`  
  Writes circular features to the DXF file with specified positions, radii, colors, and layers.

- `endDXFEntities()`  
  Ends the DXF `ENTITIES` section.

---

## Author

**Qianxi Liang (梁谦禧)**  
Peking University  
Email: [chaunceyl@stu.pku.edu.cn](mailto:chaunceyl@stu.pku.edu.cn)

---

## License

2025 Qianxi Liang  
Licensed under the **MIT License**.

> You are free to use, modify, and distribute this code with proper attribution.
