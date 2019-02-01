%% script for looking matrices calculated for each input record
% I posted a .mat file that should contains everything needed to run this

% indexes will be in this order for anything that corresponds to a specific
% class
labelNames = {'biking', 'class', 'cooking', 'driving', 'exercising', 'meeting', 'research', 'schoolwork', 'walking'};

%option to randomize; otherwise many instances of the same class appear
%together and can be annoying to step through
randomize = false;
if randomize
    inds = randperm(size(cTrainingRaw,1), size(cTrainingRaw,1));
    cTrainingRawDisp = cTrainingRaw(inds);
else
    cTrainingRawDisp = cTrainingRaw; %conserve the original data
end


%I'd recommend putting a breakpoint over the 'end' so these can be viewed
%one-by-one
for i=1:size(cTrainingRawDisp,1)
    disp([cTrainingRawDisp(i,2), '     ', cTrainingRawDisp(i,4)]); %display the label and timestamp
    %display the probabilities; rows correspond to activities, and the
    %columns correspond to rows
    disp(cTrainingRawDisp{i,1}); %display the probabilities
    
    %Note that if uniform distribution, then no pattern was applicable
    disp('----------------------------------------------------------------')
end