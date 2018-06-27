function [data, params] = openrs2d(pathname)
% opens the data.dat file in the path specified by the string pathname.
% Combines the real and imaginary parts into single entries. The params
% file is a structure where every part of the xml data is stored in its own
% field.

pathname  = num2str(pathname);
fileid = fopen([pathname filesep 'data.dat']);
if fileid < 0
    error('File data.dat cannot be read');
end
data = fread(fileid,'float32','b');
data = data(1:2:end)+1j*(data(2:2:end));
fclose(fileid);


filename = [pathname filesep 'header.xml'];
xmldata = xml2struct(filename);

for n = 1:size(xmldata.header.params.entry,2)
param_name = regexprep(xmldata.header.params.entry{n}.key.Text,' ','_');
if isfield(xmldata.header.params.entry{n}.value, 'value')~=0
    if size(xmldata.header.params.entry{n}.value.value,2)==1
eval(sprintf('params.%s = ''%s'';', param_name, xmldata.header.params.entry{n}.value.value.Text));
    else
        for m = 1:size(xmldata.header.params.entry{n}.value.value,2)
            if strcmp(xmldata.header.params.entry{n}.value.Attributes.xsi_colon_type, 'listTextParam')
               temp{m} = (xmldata.header.params.entry{n}.value.value{m}.Text); 
            else
            temp(m) = str2num(xmldata.header.params.entry{n}.value.value{m}.Text);
            end
        end
    eval(sprintf('params.%s = temp;', param_name)); clear temp;
    end
end
end