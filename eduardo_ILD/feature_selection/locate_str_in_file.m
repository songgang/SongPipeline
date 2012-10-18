function [tline, bf] = locate_str_in_file(str, fp)

tline = fgetl(fp);
bf = strfind(tline, str);
while( (isempty(bf) || (bf==0)) && feof(fp)==0 )
    tline = fgetl(fp);
    bf = strfind(tline, str); 
    if bf 
        if tline(1)=='#'
            bf=0;
        end;
    end;
end;

if isempty(bf), bf=0; end;