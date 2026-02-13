function T = scrapeAKC()

    url = "https://www.akc.org/public-education/resources/general-tips-information/dog-breeds-sorted-groups/";
    opts = weboptions("UserAgent","Mozilla/5.0","Timeout",30);

    html = webread(url, opts);
    tree = htmlTree(html);

    % Find all group container blocks
    groupBlocks = findElement(tree, "li.o-hidden");

    data = [];

    for i = 1:length(groupBlocks)

        block = groupBlocks(i);

        % -------------------------
        % Extract Group Name
        % -------------------------
        groupNode = findElement(block, ...
            "span.content-accordion__trigger");

        if isempty(groupNode)
            continue
        end

        groupName = strtrim(string(extractHTMLText(groupNode)));

        % Clean "+" symbol if present
        groupName = erase(groupName, "+");
        groupName = strtrim(groupName);

        % -------------------------
        % Extract Breed Links
        % -------------------------
        breedLinks = findElement(block, "ol li a");

        for j = 1:length(breedLinks)

            breedName = strtrim(string(extractHTMLText(breedLinks(j))));
            breedURL  = string(getAttribute(breedLinks(j), "href"));

            data = [data; {breedName, groupName, breedURL}];
        end
    end

    T = cell2table(data, ...
        "VariableNames", ["Breed","Group","URL"]);
end
