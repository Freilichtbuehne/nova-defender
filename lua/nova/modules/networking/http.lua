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
// lua_run RunString([[http.Post("http://example.com", {param1 = "4", param2 = "5"}, function() end, function() end, {header1 = "4", header2 = "5"})]])
Nova.overrides = Nova.overrides or {}
Nova.overrides["http.Post"] = Nova.overrides["http.Post"] or nil
Nova.overrides["http.Fetch"] = Nova.overrides["http.Fetch"] or nil

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

local function Log(method, domain, url, ...)
    // get file that executed the function
    local src = debug.getinfo(3, "S") and debug.getinfo(3, "S").source or nil
    local request = {}
    if method == "fetch" then
        local headers = type(select(4 - 1, ...)) == "table" and select(4 - 1, ...) or nil

        request = {
            ["Method"] = "FETCH",
            ["Domain"] = domain,
            ["URL"] = url,
            ["Headers"] = headers or "Empty",
            ["Source"] = src or "Unknown",
            ["Unsafe Source"] = IsUnsafeSrc(src) and "Yes" or "No",
            ["Time"] = os.date(Nova.config["language_time"]),
        }
    elseif method == "post" then
        local params = type(select(2 - 1, ...)) == "table" and select(2 - 1, ...) or nil
        local headers = type(select(5 - 1, ...)) == "table" and select(5 - 1, ...) or nil

        request = {
            ["Method"] = "POST",
            ["Domain"] = domain,
            ["URL"] = url,
            ["Headers"] = headers or "Empty",
            ["Parameters"] = params or "Empty",
            ["Source"] = src or "Unknown",
            ["Unsafe Source"] = IsUnsafeSrc(src) and "Yes" or "No",
            ["Time"] = os.date(Nova.config["language_time"]),
        }
    end
    if table.IsEmpty(request) then return end
    Nova.log("i", string.format("Logging HTTP request: \n%s", util.TableToJSON(request, true)))
end

local function OverwritePost(active)
    if active then
        if Nova.overrides["http.Post"] then return end
        Nova.overrides["http.Post"] = http.Post
        function http.Post(url, ...)
            local postDomains = Nova.getSetting("networking_post_domains", {})
            local enableWhitelist = Nova.getSetting("networking_post_whitelist", false)
            local enableLogging = Nova.getSetting("networking_post_logging", false)
            local blockUnsafe = Nova.getSetting("networking_post_blockunsafe", false)
            local domain = Nova.extractDomain(url)
            local src = debug.getinfo(2, "S") and debug.getinfo(2, "S").source or nil

            if enableLogging then
                Log("post", domain, url, ...)
            end

            // custom hook check
            local res = hook.Run("nova_networking_post", domain, url, ...)
            if res == false then
                Nova.log("w", string.format("http.Post: Custom hook blocked request to domain %q (%q)", domain, url))
                return
            end

            if blockUnsafe and IsUnsafeSrc(src) then
                Nova.log("w", string.format("http.Post: Blocked request from unsafe source %q to domain %q (%q)", src, domain, url))
                return
            end

            if not enableWhitelist then
                // we generate debug logs independent from the optional detailed logging
                Nova.log("d", string.format("http.Post: Request to %q", url))
                Nova.overrides["http.Post"](url, ...)
                return
            end

            // if domain is invalid and whitelist is enabled, we block the request
            if not domain then
                Nova.log("e", string.format("http.Post: Blocked request to invalid url %q", url))
                return
            end

            // block request if domain is not whitelisted
            if not table.HasValue(postDomains, domain) then
                Nova.log("w", string.format("http.Post: Blocked not whitelisted request to domain %q (%q)", domain, url))
                return
            end

            // we generate debug logs independent from the optional detailed logging
            Nova.log("d", string.format("http.Post: Request to %q", url))
            Nova.overrides["http.Post"](url, ...)
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
        function http.Fetch(url, ...)
            local fetchDomains = Nova.getSetting("networking_fetch_domains", {})
            local enableWhitelist = Nova.getSetting("networking_fetch_whitelist", false)
            local enableLogging = Nova.getSetting("networking_fetch_logging", false)
            local blockUnsafe = Nova.getSetting("networking_fetch_blockunsafe", false)
            local domain = Nova.extractDomain(url)
            local src = debug.getinfo(2, "S") and debug.getinfo(2, "S").source or nil

            if enableLogging then
                Log("fetch", domain, url, ...)
            end

            // custom hook check
            local res = hook.Run("nova_networking_fetch", domain, url, ...)
            if res == false then
                Nova.log("w", string.format("http.Fetch: Custom hook blocked request to domain %q (%q)", domain, url))
                return
            end

            if blockUnsafe and IsUnsafeSrc(src) then
                Nova.log("w", string.format("http.Fetch: Blocked request from unsafe src %q to domain %q (%q)", src, domain, url))
                return
            end

            if not enableWhitelist then
                // we generate debug logs independent from the optional logging setting
                Nova.log("d", string.format("http.Fetch: Request to %q", url))
                Nova.overrides["http.Fetch"](url, ...)
                return
            end

            // if domain is invalid and whitelist is enabled, we block the request
            if not domain then
                Nova.log("e", string.format("http.Fetch: Blocked request to invalid url %q", url))
                return
            end

            // block request if domain is not whitelisted
            if not table.HasValue(fetchDomains, domain) then
                Nova.log("w", string.format("http.Fetch: Blocked not whitelisted request to domain %q (%q)", domain, url))
                return
            end

            // we generate debug logs independent from the optional logging setting
            Nova.log("d", string.format("http.Fetch: Request to %q", url))
            Nova.overrides["http.Fetch"](url, ...)
        end
    elseif Nova.overrides["http.Fetch"] then
        http.Fetch = Nova.overrides["http.Fetch"]
        Nova.overrides["http.Fetch"] = nil
    end
end

hook.Add("nova_mysql_config_loaded", "security_http_overwrite", function()
    if Nova.getSetting("networking_post_overwrite", false) then
        OverwritePost(true)
    end

    if Nova.getSetting("networking_fetch_overwrite", false) then
        OverwriteFetch(true)
    end
end)

hook.Add("nova_config_setting_changed", "security_http_overwrite", function(key, value, oldValue)
    if key == "networking_fetch_overwrite" and value != oldValue then
        OverwriteFetch(value)
        Nova.log("d", string.format("http.Fetch overwriting %s", value and "enabled" or "disabled"))
    elseif key == "networking_post_overwrite" and value != oldValue then
        OverwritePost(value)
        Nova.log("d", string.format("http.Post overwriting %s", value and "enabled" or "disabled"))
    end
end)