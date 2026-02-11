function T = extractByletter(letter,url)

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
