% script_dump_xml.m
%
% dump the features of one patient into one xml file

idx_obj = 40;

reg_metrics = mtable_at_ext(idx_obj, :);
metric_cat_ex;
metric_cat_ex{1} = 'aero(insp)(below -50)';
metric_cat_ex{2} = 'aero(exp)(below -50)';
metric_cat_ex{3} = 'severe(below -960)';

p11 = mtable_exp(idx_obj, 1:31); p12 = mtable_insp(idx_obj, 1:31);
p13 = p12-p11;
p1 = [p11, p12, p13];

metric_cat_mrmr;

xml_values = [p1, reg_metrics];
xml_keys = {metric_cat_mrmr{:}, metric_cat_ex{:}};


fid = fopen('/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/40i_20080918122237465_CT/reg2_exp2insp/xml/features.xml', 'wt');


fprintf(fid, '<patient id="%d">\n', idx_obj);

fprintf(fid, '<image src="dynamic_over_exp.png" alt="dynamic air trapping (below 50) over expiration volume " />\n');
fprintf(fid, '<image src="expiration.png" alt="expiration" />\n');
fprintf(fid, '<image src="inspiration.png" alt="inspiration" />\n');
fprintf(fid, '<image src="seg_mixed_3d.png" alt="3D snapshot of segmented anatomy" />\n');
fprintf(fid, '<image src="seg_mixed.png" alt="segmented anatomy" />\n');
fprintf(fid, '<image src="emphysema.png" alt="emphysema (below -960) over inspiration volume" />\n');


for ii=1:length(xml_values)
    fprintf(fid, '\t<feature name="%s">\n', xml_keys{ii});
    fprintf(fid, '\t\t<value>%.4e</value>\n', xml_values(ii));
    fprintf(fid, '\t</feature>\n');
end;
fprintf(fid, '</patient>\n');

fclose(fid);



