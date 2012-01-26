function conf = guiConfigLoad(inifile)

conf = TAiniFileRead(inifile);

% Parse config values
blockNames = fieldnames(conf);
for k=1:length(blockNames)
    fieldNames = fieldnames(conf.(blockNames{k}));
    for m=1:length(fieldNames)
        if ~isnan(str2double(conf.(blockNames{k}).(fieldNames{m})))
            conf.(blockNames{k}).(fieldNames{m}) = ...
                str2double(conf.(blockNames{k}).(fieldNames{m}));
        end
    end
end
