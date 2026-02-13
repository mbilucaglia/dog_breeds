function T = scrapeRKC()

    baseURL = "https://www.royalkennelclub.com";
    url = baseURL + "/search/breeds-a-to-z";

    opts = weboptions("UserAgent","Mozilla/5.0","Timeout",30);
    html = webread(url, opts);

    tree = htmlTree(html);

    % Find all breed cards
    cards = findElement(tree, "div.m-breed-card");

    data = [];

    for i = 1:length(cards)

        card = cards(i);

        % --- Category ---
        catNode = findElement(card, "div.m-breed-card__category");
        if ~isempty(catNode)
            category = strtrim(string(extractHTMLText(catNode)));
        else
            category = string(missing);
        end

        % --- Breed Name ---
        breedNode = findElement(card, "strong.m-breed-card__title");
        if ~isempty(breedNode)
            breedName = strtrim(string(extractHTMLText(breedNode)));
        else
            breedName = string(missing);
        end

        % --- URL ---
        linkNode = findElement(card, "a.m-breed-card__link");
        if ~isempty(linkNode)
            href = string(getAttribute(linkNode,"href"));
            breedURL = baseURL + href;
        else
            breedURL = string(missing);
        end

        data = [data; {breedName, category, breedURL}];
    end

    T = cell2table(data, ...
        "VariableNames", ["Breed","Category","URL"]);
end