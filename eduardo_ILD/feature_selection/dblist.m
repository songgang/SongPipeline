function [datelist, imglist, dbroot]=dblist(txtfilename)

% datelist(1)={'120406'};

% imglist(1)={{'forcedair50L2hr1', 'forcedair50L2hr2'}};


% parse dblist.sh
fp = fopen(txtfilename);

if fp==0 
    fprintf(2, 'Could not open: %s', txtfilename)
    error('error!');
end;

while (1)
    [tline, bf] = locate_str_in_file('dbroot=', fp);
    
    if feof(fp)==1
        error('can not find ''dbroot'' before the end of file.');
    end;
    
    if bf
        k = strfind(tline, 'dbroot=');

        if strfind(tline(1:k-1), '#') ~= 0
            continue;
        else
            break;
        end;
    end;
    
    
end;
k = strfind(tline, '''');
dbroot=tline(k(1)+1 : k(2)-1);

[tline, bf] = locate_str_in_file('phaselist="', fp);
datelist = {};
while(1)
    tline = fgetl(fp);
    if strcmp(tline, '"')==1
        break;
    end;
    datelist = {datelist{:}, tline};
end;

nb_date = length(datelist);
imglist = cell(1, nb_date);

for ii = 1:nb_date
    mydate = datelist{ii};
    fseek(fp, 0, -1);
    % [tline, bf] = locate_str_in_file(['d', mydate,'(){'], fp);
    [tline, bf] = locate_str_in_file('subjectlist="', fp);
    imglist{ii}= {};
    while(1)
        tline = fgetl(fp);
        if strcmp(tline, '"')==1
            break;
        end;
        imglist{ii} = {imglist{ii}{:}, tline};
    end;
    
end;


fclose(fp);
