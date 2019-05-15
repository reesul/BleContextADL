# BleContextADL
This repo was created for a project on context detection using Bluetooth Low Energy (BLE) scans of advertisement packets. The information scanned is freely available, and thus, is noisy. Methods are developed and implemented within the repo, along with many files and functions for data extraction from text files across many days, association of data across different modalities, e.g., accelerometer signals and scans from BLE, feature extraction, implementation of the methods, and writing data to file for use in Weka, a prototyping tool for machine learning. 

## Usage
The scripts beginning with BleProcessingMaster_vX.m are intended to be the central scripts for this entire repository. Nearly all components of this repo are built to run via function calls originating from this script. This file is broken down into sections to keep different portions contained. Several file paths must be hardcoded, there are a few places throughout the script where this should be done. 

It is highly recommended to use the newest version of this script, _v7, as this was updated to be the most generalized. v6 contains the same functionalities, but is subject specific as it was being used to test data for various subjects prior to submission. 

The main other script that will be useful is 'PlotToolsForUbicomp', as this contains hardcoded values used to generate the plots for a submission to IMWUT journal (which feeds into UbiComp). For whoever (Reese or Ali) works on responding to feedback, the values needed for those plots are already contained in that script. Look for the appropriate section to find whichever plot is needed

