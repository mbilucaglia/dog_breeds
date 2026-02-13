function T = scrapeUKC()

    baseURL = "https://www.ukcdogs.com";
    url = baseURL + "/breed-standards";   % adjust if needed

    opts = weboptions("UserAgent","Mozilla/5.0","Timeout",30);
    html = webread(url, opts);
    tree = htmlTree(html);

    data = [];

    % -------------------------
    % Find main container
    % -------------------------
    container = findElement(tree, "div.dog_breeds");

    if isempty(container)
        error("dog_breeds container not found.");
    end

    % First UL inside container
    mainUL = findElement(container, "ul");

    if isempty(mainUL)
        error("Main UL not found.");
    end

    % Direct LI children (categories)
    categories = findElement(mainUL(1), "li");

    for i = 1:length(categories)

        catBlock = categories(i);

        % -------------------------
        % Category name (h3)
        % -------------------------
        catNode = findElement(catBlock, "h3");
        if isempty(catNode)
            continue
        end

        categoryName = strtrim(string(extractHTMLText(catNode)));

        % -------------------------
        % Inner UL with breeds
        % -------------------------
        innerUL = findElement(catBlock, "ul");

        if isempty(innerUL)
            continue
        end

        breedLinks = findElement(innerUL(1), "a");

        for j = 1:length(breedLinks)

            breedName = strtrim(string(extractHTMLText(breedLinks(j))));
            slug = string(getAttribute(breedLinks(j),"href"));

            if startsWith(slug,"http")
                breedURL = slug;
            else
                breedURL = baseURL + "/" + slug;
            end

            data = [data; {breedName, categoryName, breedURL}];
        end
    end

    T = cell2table(data, ...
        "VariableNames", ["Breed","Category","URL"]);

    T = unique(T);
end
