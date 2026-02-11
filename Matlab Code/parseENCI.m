function [T_def] = parseENCI()
letters=string(('A':'Z').');
N=numel(letters);

baseURL = "https://www.enci.it";
url = strcat(baseURL, "/libro-genealogico/razze?startWith=");

T=table();

for i=1:N
    letter_temp=letters(i);

    tab_temp=extractByletter(letter_temp);

    T=[T; tab_temp];


end

T_def=table();

for i=1:size(T,1)

    url_temp=T(i,:).URL;

    tab_temp=parseBREED(url_temp);
    T_def=[T_def;tab_temp];



end

end