/*
	Backdoors (intentionally or not) are often implemented using http calls.
        http.Fetch -> could download arbitrary lua code from a attacker and run it on the server without you noticing.
        http.Post -> could leak all the server's files and send them to the attacker.

    Therefore we go the safest way and block each connection by default. Only a handful of script do really need to
    fetch or post data to/from the internet. Most often they just want to check for new updates or send analytics.

    Unsafe sites like pastebin.com should not be whitelisted.

    Check the code that you put on your own server in the first place and dont upload lua-scripts blindly.
*/

// lua_run http.Post("http://example.com", {param1 = "4", param2 = "5"}, function() end, function() end, {header1 = "4", header2 = "5"})
// lua_run http.Fetch("http://example.com",  function() end, function() end, {header1 = "4", header2 = "5"})
// lua_run HTTP({url = "http://example.com", method = "POST", parameters = {param1 = "4", param2 = "5"}, headers = {header1 = "4", header2 = "5"}})
// lua_run RunString([[http.Post("http://example.com", {param1 = "4", param2 = "5"}, function() end, function() end, {header1 = "4", header2 = "5"})]])
Nova.overrides = Nova.overrides or {}
Nova.overrides["http.Post"] = Nova.overrides["http.Post"] or nil
Nova.overrides["http.Fetch"] = Nova.overrides["http.Fetch"] or nil
Nova.overrides["HTTP"] = Nova.overrides["HTTP"] or nil

local unsafePatterns = {
    "%@lua_run",
    "%@lua_openscript",
    "%@runstring%(ex%)",
}

local function IsUnsafeSrc(src)
    if not src then return false end
    if src == "" then return false end

    src = string.lower(src)

    for _, pattern in pairs(unsafePatterns or {}) do
        if string.find(src, pattern) then
            return true
        end
    end

    return false
end

local function Log(method, domain, url, headers, parameters)
    if not Nova.getSetting("networking_http_logging", false) then return end

    // get file that executed the function
    local src = debug.getinfo(3, "S") and debug.getinfo(3, "S").source or nil
    local request = {
        ["Method"] = method,
        ["Domain"] = domain,
        ["URL"] = url,
        ["Headers"] = headers and Nova.truncate(util.TableToJSON(headers), 100, "...") or "Empty",
        ["Parameters"] = parameters and Nova.truncate(util.TableToJSON(parameters), 100, "...") or "Empty",
        ["Source"] = src or "Unknown",
        ["Unsafe Src"] = IsUnsafeSrc(src) and "Yes" or "No",
        ["Time"] = os.date(Nova.config["language_time"]),
    }

    local printableString = ""
    for key, value in pairs(request) do
        printableString = string.format("%s%s:\t%s\n", printableString, key, value)
    end
    Nova.log("i", string.format("Logging HTTP request: \n%s", printableString))
end

local function OverwritePost(active)
    if active then
        if Nova.overrides["http.Post"] then return end
        Nova.overrides["http.Post"] = http.Post
        function http.Post(url, parameters, onSuccess, onFailure, headers, ...)
            local whitelistDomains = Nova.getSetting("networking_http_whitelistdomains", {})
            local enableWhitelist = Nova.getSetting("networking_post_whitelist", false)
            local blockUnsafe = Nova.getSetting("networking_post_blockunsafe", false)
            local domain = Nova.extractDomain(url)
            local src = debug.getinfo(2, "S") and debug.getinfo(2, "S").source or nil

            Log("post", domain, url, headers, parameters)

            // custom hook check
            local res = hook.Run("nova_networking_post", domain, url, parameters, headers)
            if res == false then
                Nova.log("w", string.format("http.Post: Custom hook blocked request to domain %q (%q)", domain, url))
                if isfunction(onFailure) then onFailure("Blocked by Nova Defender URL filtering") end
                return
            end

            if blockUnsafe and IsUnsafeSrc(src) then
                Nova.log("w", string.format("http.Post: Blocked request from unsafe source %q to domain %q (%q)", src, domain, url))
                if isfunction(onFailure) then onFailure("Blocked by Nova Defender URL filtering") end
                return
            end

            if not enableWhitelist then
                // we generate debug logs independent from the optional detailed logging
                Nova.log("d", string.format("http.Post: Request to %q", url))
                Nova.overrides["http.Post"](url, parameters, onSuccess, onFailure, headers, ...)
                return
            end

            // if domain is invalid and whitelist is enabled, we block the request
            if not domain then
                Nova.log("e", string.format("http.Post: Blocked request to invalid url %q", url))
                if isfunction(onFailure) then onFailure("Blocked by Nova Defender URL filtering") end
                return
            end

            // block request if domain is not whitelisted
            if not table.HasValue(whitelistDomains, domain) then
                Nova.log("w", string.format("http.Post: Blocked not whitelisted request to domain %q (%q)", domain, url))
                if isfunction(onFailure) then onFailure("Blocked by Nova Defender URL filtering") end
                return
            end

            // we generate debug logs independent from the optional detailed logging
            Nova.log("d", string.format("http.Post: Request to %q", url))
            Nova.overrides["http.Post"](url, parameters, onSuccess, onFailure, headers, ...)
        end
    elseif Nova.overrides["http.Post"] then
        http.Post = Nova.overrides["http.Post"]
        Nova.overrides["http.Post"] = nil
    end
end

local function OverwriteFetch(active)
    if active then
        if Nova.overrides["http.Fetch"] then return end
        Nova.overrides["http.Fetch"] = http.Fetch
        function http.Fetch(url, onSuccess, onFailure, headers, ...)
            local whitelistDomains = Nova.getSetting("networking_http_whitelistdomains", {})
            local enableWhitelist = Nova.getSetting("networking_fetch_whitelist", false)
            local blockUnsafe = Nova.getSetting("networking_fetch_blockunsafe", false)
            local domain = Nova.extractDomain(url)
            local src = debug.getinfo(2, "S") and debug.getinfo(2, "S").source or nil

            Log("fetch", domain, url, headers)

            // custom hook check
            local res = hook.Run("nova_networking_fetch", domain, url, headers)
            if res == false then
                Nova.log("w", string.format("http.Fetch: Custom hook blocked request to domain %q (%q)", domain, url))
                if isfunction(onFailure) then onFailure("Blocked by Nova Defender URL filtering") end
                return
            end

            if blockUnsafe and IsUnsafeSrc(src) then
                Nova.log("w", string.format("http.Fetch: Blocked request from unsafe src %q to domain %q (%q)", src, domain, url))
                if isfunction(onFailure) then onFailure("Blocked by Nova Defender URL filtering") end
                return
            end

            if not enableWhitelist then
                // we generate debug logs independent from the optional logging setting
                Nova.log("d", string.format("http.Fetch: Request to %q", url))
                Nova.overrides["http.Fetch"](url, onSuccess, onFailure, headers, ...)
                return
            end

            // if domain is invalid and whitelist is enabled, we block the request
            if not domain then
                Nova.log("e", string.format("http.Fetch: Blocked request to invalid url %q", url))
                if isfunction(onFailure) then onFailure("Blocked by Nova Defender URL filtering") end
                return
            end

            // block request if domain is not whitelisted
            if not table.HasValue(whitelistDomains, domain) then
                Nova.log("w", string.format("http.Fetch: Blocked not whitelisted request to domain %q (%q)", domain, url))
                if isfunction(onFailure) then onFailure("Blocked by Nova Defender URL filtering") end
                return
            end

            // we generate debug logs independent from the optional logging setting
            Nova.log("d", string.format("http.Fetch: Request to %q", url))
            Nova.overrides["http.Fetch"](url, onSuccess, onFailure, headers, ...)
        end
    elseif Nova.overrides["http.Fetch"] then
        http.Fetch = Nova.overrides["http.Fetch"]
        Nova.overrides["http.Fetch"] = nil
    end
end

local function OverwriteHTTP(active)
    if active then
        if Nova.overrides["HTTP"] then return end
        Nova.overrides["HTTP"] = HTTP
        function HTTP(params, ...)
            local url = params.url
            local method = params.method

            local whitelistDomains = Nova.getSetting("networking_http_whitelistdomains", {})
            local enableWhitelist = Nova.getSetting("networking_http_whitelist", false)

            local blockUnsafe = Nova.getSetting("networking_http_blockunsafe", false)
            local domain = Nova.extractDomain(url)
            local src = debug.getinfo(2, "S") and debug.getinfo(2, "S").source or nil

            local failed = params.failed

            Log(method, domain, url, params.headers, params.parameters)

            // custom hook check
            local res = hook.Run("nova_networking_http", method, domain, url, params)
            if res == false then
                Nova.log("w", string.format("HTTP (%s): Custom hook blocked request to domain %q (%q)", method, domain, url))
                if isfunction(failed) then failed("Blocked by Nova Defender URL filtering") end
                return
            end

            if blockUnsafe and IsUnsafeSrc(src) then
                Nova.log("w", string.format("HTTP (%s): Blocked request from unsafe src %q to domain %q (%q)", method, src, domain, url))
                if isfunction(failed) then failed("Blocked by Nova Defender URL filtering") end
                return
            end

            if not enableWhitelist then
                // we generate debug logs independent from the optional logging setting
                Nova.log("d", string.format("HTTP (%s): Request to %q", method, url))
                Nova.overrides["HTTP"](params, ...)
                return
            end

            // if domain is invalid and whitelist is enabled, we block the request
            if not domain then
                Nova.log("e", string.format("HTTP (%s): Blocked request to invalid url %q", method, url))
                if isfunction(failed) then failed("Blocked by Nova Defender URL filtering") end
                return
            end

            // block request if domain is not whitelisted
            if not table.HasValue(whitelistDomains, domain) then
                Nova.log("w", string.format("HTTP (%s): Blocked not whitelisted request to domain %q (%q)", method, domain, url))
                if isfunction(failed) then failed("Blocked by Nova Defender URL filtering") end
                return
            end

            // we generate debug logs independent from the optional logging setting
            Nova.log("d", string.format("HTTP (%s): Request to %q", method, url))
            Nova.overrides["HTTP"](params, ...)
        end
    elseif Nova.overrides["HTTP"] then
        HTTP = Nova.overrides["HTTP"]
        Nova.overrides["HTTP"] = nil
    end
end

local function LoadConfig()
    if Nova.getSetting("networking_post_overwrite", false) then
        OverwritePost(true)
    end

    if Nova.getSetting("networking_fetch_overwrite", false) then
        OverwriteFetch(true)
    end

    if Nova.getSetting("networking_http_overwrite", false) then
        OverwriteHTTP(true)
    end
end

// To avoid breaking other addons, we con only override http functions if we know
// that the option is enabled. This is after the settings were loaded.
// TODO: Add fast loading options that we can access before MySQL (based on local files?)
if not Nova.defaultSettingsLoaded then
    hook.Add("nova_mysql_config_loaded", "security_http_overwrite", LoadConfig)
else
    LoadConfig()
end

hook.Add("nova_config_setting_changed", "security_http_overwrite", function(key, value, oldValue)
    if key == "networking_fetch_overwrite" and value != oldValue then
        OverwriteFetch(value)
        Nova.log("d", string.format("http.Fetch overwriting %s", value and "enabled" or "disabled"))
    elseif key == "networking_post_overwrite" and value != oldValue then
        OverwritePost(value)
        Nova.log("d", string.format("http.Post overwriting %s", value and "enabled" or "disabled"))
    elseif key == "networking_http_overwrite" and value != oldValue then
        OverwriteHTTP(value)
        Nova.log("d", string.format("HTTP overwriting %s", value and "enabled" or "disabled"))
    end
end)