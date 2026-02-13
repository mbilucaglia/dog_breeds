function T = scrapeFCI()

% SCRAPEFCI
% Scrapes all FCI breeds dynamically using available initials
% from the FCI nomenclature page.

    baseURL = "https://fci.be";
    mainURL = baseURL + "/en/nomenclature/";
    opts = weboptions("UserAgent","Mozilla/5.0","Timeout",30);

    data = [];

    % ==========================================
    % STEP 1 — Get available initials dynamically
    % ==========================================
    [letters, letterURLs] = getAvailableLetters();

    % ==========================================
    % STEP 2 — Loop over available letters
    % ==========================================
    for L = 1:length(letters)

        breedTable = getBreedList(letterURLs(L));

        for i = 1:height(breedTable)

            try
                info = parseBreedPage(breedTable.URL(i));

                data = [data; {
                    breedTable.Breed(i), ...
                    info.BreedNumber, ...
                    info.Section, ...
                    info.Subsection, ...
                    info.Country, ...
                    info.Status, ...
                    info.DateAcceptance, ...
                    info.DateStandard, ...
                    info.Language, ...
                    info.WorkingTrial, ...
                    breedTable.URL(i)
                }];

            catch ME
                warning("Failed: %s (%s)", ...
                    breedTable.Breed(i), ME.message);
            end

            pause(0.2); % polite delay
        end
    end

    % ==========================================
    % Final table
    % ==========================================
    T = cell2table(data, ...
        "VariableNames", ...
        ["Breed","FCINumber","Section","Subsection","Country", ...
         "Status","DateAcceptance","DateStandard", ...
         "Language","WorkingTrial","URL"]);

    T = unique(T);

    % ====================================================
    % ================= NESTED FUNCTIONS =================
    % ====================================================

    function [letters, letterURLs] = getAvailableLetters()

        html = webread(mainURL, opts);
        tree = htmlTree(html);

        initBlock = findElement(tree, "ul.initiales");

        links = findElement(initBlock, "a");

        letters = strings(length(links),1);
        letterURLs = strings(length(links),1);

        for k = 1:length(links)

            letters(k) = strtrim(string(extractHTMLText(links(k))));

            href = string(getAttribute(links(k),"href"));

            % Normalize relative URL
            href = replace(href, "../../", "/en/");

            letterURLs(k) = baseURL + href;
        end
    end


    function Tlist = getBreedList(letterURL)

        html = webread(letterURL, opts);
        tree = htmlTree(html);

        breedList = findElement(tree, "ul.listeraces");

        if isempty(breedList)
            Tlist = table();
            return
        end

        links = findElement(breedList, "a");

        tmp = [];

        for k = 1:length(links)

            breedName = strtrim(string(extractHTMLText(links(k))));
            href = string(getAttribute(links(k),"href"));

            if startsWith(href,"/")
                breedURL = baseURL + href;
            else
                breedURL = baseURL + "/en/nomenclature/" + href;
            end

            tmp = [tmp; {breedName, breedURL}];
        end

        Tlist = cell2table(tmp, ...
            "VariableNames", ["Breed","URL"]);
    end


    function info = parseBreedPage(breedURL)

        html = webread(breedURL, opts);
        tree = htmlTree(html);

        info = struct();

        % Extract FCI number from URL
        token = regexp(breedURL, '-(\d+)\.html$', 'tokens', 'once');
        if ~isempty(token)
            info.BreedNumber = token{1};
        else
            info.BreedNumber = string(missing);
        end

        function val = getByID(id)
            node = findElement(tree, "#" + id);
            if isempty(node)
                val = string(missing);
            else
                val = strtrim(string(extractHTMLText(node)));
            end
        end

        info.Section        = getByID("ContentPlaceHolder1_SectionLabel");
        info.Subsection     = getByID("ContentPlaceHolder1_SousSectionLabel");
        info.DateAcceptance = getByID("ContentPlaceHolder1_DateReconnaissanceLabel");
        info.Language       = getByID("ContentPlaceHolder1_LangueOrigineLabel");
        info.DateStandard   = getByID("ContentPlaceHolder1_DateStandardEnVigueurLabel");
        info.Status         = getByID("ContentPlaceHolder1_StatutLabel");
        info.Country        = getByID("ContentPlaceHolder1_PaysOrigineLabel");
        info.WorkingTrial   = getByID("ContentPlaceHolder1_EpreuveTravailLabel");

    end

end
