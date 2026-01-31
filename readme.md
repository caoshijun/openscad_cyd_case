
---

# CYD2USB Case - 2026 New Edition (Parametric & Snap-Fit)

After nearly half a month of development following the original cyd2usb case, I am excited to release the **2026 New Edition**. This version is a complete ground-up redesign focusing on printability, aesthetics, and extreme customization.

---

## ✨ Key Features

* **🔧 High-Precision Snap-Fit:** A pure mechanical design. No screws or glue required. The case fits "tight as a glove" but remains easy to open and close.
* **🚀 Support-Free Design:** Clever internal geometry avoids all overhangs. The top and bottom parts can be printed flat on the bed without any support structures, saving time and filament while ensuring a clean finish.
* **💎 Premium Ergonomics:** Newly added **fillets and chamfers** provide a modern look and a much more comfortable handheld experience compared to the previous version.
* **🏗️ Revamped Internal Structure:** Reinforced support columns make the base sturdier and ensure all internal components align perfectly upon insertion.
* **🎨 Modular Logo System:** Features an optional "Split-Logo" design. If you change your CYD’s firmware, you only need to swap the printed logo tag.
* **🖊️ Integrated Stylus Storage:** A secure, built-in slot for the stylus. It clicks into place to prevent it from ever falling out, even in such a compact form factor.
* **🔌 Universal I/O Access:** Every single port and minor component is accounted for and customizable.

---

## ⚙️ Parametric Customization

Since there are many hardware revisions of the **Cheap Yellow Display (CYD)**, this project uses a parametric approach. You can toggle or adjust the following details to match your specific board:

### Components & Layout

* **Toggle Parts:** Choose to print the Bottom Case, Top Case, or Stylus Holder individually.
* **Logo Customization:** Enable/Disable the logo, use split-part printing, and adjust text, font size, or position.
* **Port Cutouts:** Optional openings for Speaker, MicroUSB, UART, MicroSD, and Temperature/Humidity sensors.

### Technical Adjustments

* **Hardware Compatibility:** Toggle openings for the Light Sensor and custom shrouds for the **WS2812 LED**.
* **Precision Fit:** Manually define **Screen Thickness** and **PCB Thickness**.
* **Alignment Fixes:** Adjust the horizontal/vertical offset for the screen (useful for third-party boards with misaligned displays).
* **Scale:** Define your own custom case height.

---

## 🛠 Printing Recommendations

* **Material:** PLA, PETG, or ABS/ASA (for better heat resistance).
* **Supports:** **None**. (This model is designed to be printed support-free).
* **Layer Height:** 0.2mm recommended for the snap-fit tolerances.
* **Infill:** 15% - 20% (Grid or Gyroid).

---

## 📥 How to Use

1. **Select your configuration** using the provided `.json` or within the CAD software (OpenSCAD/Fusion 360).
2. **Export the STL/STEP files.**
3. **Slice and Print.**
4. **Snap together**—no hardware needed!

---

**Would you like me to add a "License" (如 MIT 或 CC) section to the bottom, or perhaps a section on how people can support your work?**
