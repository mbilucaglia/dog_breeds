function [T_def] = scrapeENCI()
letters=string(('A':'Z').');
N=numel(letters);

baseURL = "https://www.enci.it";
url = strcat(baseURL, "/libro-genealogico/razze?startWith=");

T=table();

for i=1:N
    letter_temp=letters(i);

    tab_temp=extractByletter(baseURL,url,letter_temp);

    T=[T; tab_temp];


end

T_def=table();

for i=1:size(T,1)

    url_temp=T(i,:).URL;

    tab_temp=parseBREED(url_temp);
    T_def=[T_def;tab_temp];

end

end

function T = extractByletter(baseURL,url,letter)

url=strcat(url,upper(letter));

    opts = weboptions("UserAgent","Mozilla/5.0","Timeout",30);
    html = webread(url, opts);

    tree = htmlTree(html);

    % Get elements in document order
    nodes = findElement(tree, "h3.razza-sezione, h4.razza-sezione, a.hover-plus");

    if isempty(nodes)
        T=[];
        return;
    end
    currentGroup = "";
    currentSection = "";

    data = [];

    for i = 1:length(nodes)

        classAttr = string(getAttribute(nodes(i),"class"));
        tagName   = lower(string(nodes(i).Name));  % <- safer now

        % --------------------
        % GROUP (h3.razza-sezione)
        % --------------------
        if contains(classAttr,"razza-sezione") && tagName=="h3"
            currentGroup = strtrim(extractHTMLText(nodes(i)));
            continue
        end

        % --------------------
        % SECTION (h4.razza-sezione)
        % --------------------
        if contains(classAttr,"razza-sezione") && tagName=="h4"
            currentSection = strtrim(extractHTMLText(nodes(i)));
            continue
        end

        % --------------------
        % BREED LINK
        % --------------------
        if contains(classAttr,"hover-plus")

            href = string(getAttribute(nodes(i),"href"));
            breedURL = baseURL + href;

            % Breed name inside child h3.razza-desc
            breedNode = findElement(nodes(i),"h3.razza-desc");
            breedName = strtrim(string(extractHTMLText(breedNode)));

            data = [data; {breedName, currentGroup, currentSection, breedURL}];
        end
    end

    T = cell2table(data, ...
        "VariableNames", ["Breed","Group","Section","URL"]);
end

function [T] = parseBREED(breedURL)

    opts = weboptions("UserAgent","Mozilla/5.0","Timeout",30);
    html = webread(breedURL, opts);
    tree = htmlTree(html);

    % Default values
    FCI = "";
    GroupId = "";
    GroupName = "";
    SectionId = "";
    SectionName = "";
    Varieties = strings(0);

    % Find specification table
    specTable = findElement(tree, "table.razza-spec-table");
    rows = findElement(specTable, "tr");

    for i = 1:length(rows)

        cells = findElement(rows(i), "td");
        if length(cells) < 2
            continue
        end

        label = strtrim(string(extractHTMLText(cells(1))));
        valueCell = cells(2);

        switch label

            case "Codice FCI"
                FCI = strtrim(string(extractHTMLText(valueCell)));

            case "Gruppo"
                txt = strtrim(string(extractHTMLText(valueCell)));
                tok = regexp(txt, '^(\d+)\s*-\s*(.*)$', 'tokens','once');
                if ~isempty(tok)
                    GroupId = string(tok{1});
                    GroupName = string(tok{2});
                end

            case "Sezione"
                txt = strtrim(string(extractHTMLText(valueCell)));
                tok = regexp(txt, '^(\d+)\s*-\s*(.*)$', 'tokens','once');
                if ~isempty(tok)
                    SectionId = string(tok{1});
                    SectionName = string(tok{2});
                end

            case "Varietà"
                varietyDivs = findElement(valueCell,"div");
                if ~isempty(varietyDivs)
                    Varieties = strtrim(string(extractHTMLText(varietyDivs)));
                end
        end
    end

    % Extract breed name from page title
    titleNode = findElement(tree,"h1");
    BreedName = strtrim(string(extractHTMLText(titleNode)));

    % ---------------------------------------
    % EXPANSION LOGIC
    % ---------------------------------------

if isempty(Varieties)

    T = table( ...
        BreedName, FCI, GroupId, GroupName, ...
        SectionId, SectionName, ...
        string(missing), string(missing), ...
        breedURL, ...
        'VariableNames', ...
        ["Breed","FCI","GroupId","GroupName","SectionId","SectionName", ...
         "VarietyCode","VarietyName","URL"]);

else

    n = length(Varieties);

    VarietyCode = strings(n,1);
    VarietyName = strings(n,1);

    for k = 1:n
        tok = regexp(Varieties(k), '^([A-Z0-9]+)\s*-\s*(.*)$', 'tokens', 'once');

        if ~isempty(tok)
            VarietyCode(k) = tok{1};
            VarietyName(k) = tok{2};
        else
            % fallback if format unexpected
            VarietyName(k) = Varieties(k);
        end
    end

    T = table( ...
        repmat(BreedName,n,1), ...
        repmat(FCI,n,1), ...
        repmat(GroupId,n,1), ...
        repmat(GroupName,n,1), ...
        repmat(SectionId,n,1), ...
        repmat(SectionName,n,1), ...
        VarietyCode, ...
        VarietyName, ...
        repmat(breedURL,n,1), ...
        'VariableNames', ...
        ["Breed","FCI","GroupId","GroupName","SectionId","SectionName", ...
         "VarietyCode","VarietyName","URL"]);
end

end