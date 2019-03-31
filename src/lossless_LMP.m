try
    load data/KaggleLoads.mat
catch error
    disp('Load .mat file does not exist. Generating...')
    data_preprocess,
end