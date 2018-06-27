function params = xmlheader(expno)
%%
expno = 1661
filename = [num2str(expno) filesep 'header.xml'];
xmldata = xml2struct(filename);

for n = 1:size(xmldata.header.params.entry,2)
param_name = regexprep(xmldata.header.params.entry{n}.key.Text,' ','_');
if isfield(xmldata.header.params.entry{n}.value, 'value')~=0
    if size(xmldata.header.params.entry{n}.value.value,2)==1
eval(sprintf('params.%s = ''%s'';', param_name, xmldata.header.params.entry{n}.value.value.Text));
    end
end
%%
end

