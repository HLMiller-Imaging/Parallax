Once you have data and calibration you want to track it.
We do this by running the Matlab code 'TrackFolder2_noSim' in your data folder.
Now is the time to explain what the tracking software does and what the parameters do:

The following is adapted from the code preamble:

TrackFolder2_noSIM(OutputFolder,linkcons,n,pixsize,corr_coeff,p,CalibFileName,p_calib,tolfactor,minCorr,addextra)
TrackFolder2_noSIM('Analysis2',[500 0.01 100],2,51.5,0.9,p,CalibFileName,p_calib,5,2,1)
% INPUTS
% OUTPUTFOLDER - where you want all the analysis put e.g. 'Analysis1'
% LINKCONS     - params for linking [max_dist min_intensity_ratio max_intensity_ratio] e.g. [500 0.01 100]
% N            - number of steps that can be jumped and still linked together e.g.2
% PIXSIZE      - size of pixels in nm. This depends on your magnification. e.g. 51.5
% CORR_COEFF   - threshold correlation to accept the particles as the same.
%                range [-1 1]. 1 is most correlated. setting to 0.9 strongly recommended
% P            - pstructure for spot finding using ADEMS code. (N.B. ADEMS 
%                code spits out a linking but that is discarded here in 
%                favour of my own linking routines). See documentation on ADEMS code written by
%		 Adam Wollman in the appropriate folder e.g. p
% CALIBFILENAME- The name of the image used for calibration e.g. 'calib504'
% P_CALIB      - ADEMS code P structure for use on the calibration data
% TOLFACTOR    - the number of pixels tolerance (+/-) in linking correlated
%                trajectories. 5 is strongly recommended
% MINCORR      - minimum number of localisations in tracks to try
%                correlation. Use 2 for maximum  data linkage, but a higher
%                value if you have noise on otherwise clear tracks.
% ADDEXTRA     - A switch to look for missing localisations in the last
%                step of making 3D trajectories e.g. 1
%

Output is saved into the folder specified; in this example, this is 'Analysis'

So you will likely need to change OutputFolder, CalibFileName and pixsize for your own microscope and file naming conventions. The 
other parameters should only be adjusted slightly (if at all) as these will change functionality.

So adjust your command line input approriately, and hit enter. Hopefully, everything tracks!