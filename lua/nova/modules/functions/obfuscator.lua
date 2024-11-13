local payloads = {
    ["check"] = [==[function(b,c)local d=util.SHA256;local function e(f)local q=table.concat if type(f)=="table"then return q(f,",")end local l=-1;local g,m={},jit.util.funck(f,l);while m do local n=type(m)if n=="number"then g[#g+1]=m elseif n=="string"then g[#g+1]=string.format("%q",m)elseif n=="boolean"then g[#g+1]=m and 1 or 0 end;l,m=l-1,jit.util.funck(f,l)end;return q(g,",")end;local h=jit.util.funcinfo(d)local o="@addons/"local p=h.source;if p and string.sub(p,1,#o)~=o then return false,"sha detour"end;local q=type(b)local r=q=="function"and d(e(b))or q=="string"and d(b)or nil;if not r then return false,"invalid input"end;if r~=c then return false,"hash mismatch"end;return true end]==],
    ["decode"] = [==[function(s)local d=""local i=1 while i<=#s do local c=string.sub(s,i,i)if c=="\\" then local cc=tonumber(string.sub(s,i+1,i+3))d=d..string.char(cc)i=i+3 else d=d..c end i=i+1 end return d end]==],
    ["getfenv"] = [==[getfenv(0)]==],
    ["banme"] = [==[function(r)net.Start("nova_anticheat_detection")net.WriteString("anticheat_manipulate_ac")net.WriteString(r)net.SendToServer()end]==],
}

local enable_debugging = false

local function DumpFunction(func)
    /*local v, f = {}, jit.util.funcinfo(func)
    for i = 0, f.bytecodes-1 do
        local inst, op = jit.util.funcbc(func, i)
        v[#v + 1] = "ins"..inst
        v[#v + 1] = " op"..op
    end*/
    if type(func) == "table" then return table.concat(func, ",") end
    local v = {}
    local cntr = -1
    local const = jit.util.funck(func, cntr)
    while const do
        local tp = type(const)
        if tp == "number" then
            v[#v + 1] = const
        elseif tp == "string" then
            v[#v + 1] = string.format("%q", const)
        elseif tp == "boolean" then
            v[#v + 1] = const and 1 or 0
        end
        cntr, const = cntr - 1, jit.util.funck(func, cntr)
    end
    return table.concat(v, ",")
end

Nova.obfuscator = Nova.obfuscator or {}
Nova.obfuscator.getFunctionChecksum = function(inputFunction)
    local inputType = type(inputFunction)
    local dmp = nil
    if inputType == "function" then
        dmp = util.SHA256(DumpFunction(inputFunction))
    elseif inputType == "string" then
        dmp = util.SHA256(inputFunction)
    elseif inputType == "table" then
        dmp = util.SHA256(table.concat(inputFunction, ","))
    end
    return dmp
end

Nova.obfuscator.variable = {identifier = {}, lookup = {}}
function Nova.obfuscator.variable:Get(identifier)
    if not self.identifier[identifier] then
        local varName = ""
        // Repeat until at least 8 characters and varName doesn't exist already
        while string.len(varName) < 8 or self.lookup[varName] do
            varName = varName .. (math.random(0,1) == 1 and "K" or "k")
        end

        self.lookup[varName] = identifier

        // if debugging is enabled, we use the identifier as the variable name
        if enable_debugging then
            self.identifier[identifier] = identifier
        else
            self.identifier[identifier] = varName
        end

    end
    return self.identifier[identifier]
end
function Nova.obfuscator.variable:Set(identifier, value, notLocal, quotes)
    if not self.identifier[identifier] then self:Get(identifier) end
    if quotes then value = string.format("[==[%s]==]", value) end
    return string.format("%s%s = %s", notLocal and "" or "local ", self.identifier[identifier], value)
end

Nova.obfuscator.randomOrder = function(tbl)
    table.Shuffle(tbl)
    local varString = ""
    for i = 1, #tbl do varString = varString .. tbl[i] .. "; " end
    return varString
end

Nova.obfuscator.line = {}
function Nova.obfuscator.line:Register(id, code, total)
   self[id] = {code = code, total = total, counter = 1, lineToInsert = math.random(1, total or 1)}
   return self
end

function Nova.obfuscator.line:Insert(id)
    if not self[id] then return "" end
    if self[id].total and self[id].counter != self[id].lineToInsert then
        self[id].counter = self[id].counter + 1
        return ""
    end
    local code = self[id].code
    // we only delete the line if we have a total
    // else we can insert the same line as many times as we want
    if self[id].total then self[id] = nil end
    return code
end

local function Encode(str)
    local encoded = ""
    for i = 1, #str do
        local char = string.sub(str, i, i)
        local charCode = string.byte(char)
        encoded = encoded .. string.format("\\%03d", charCode)
    end
    return encoded
end

local compilerCache = {}
Nova.obfuscator.obfuscate = function(source, replaceText)
    local vars = Nova.obfuscator.variable

    local sourceChecksum = util.SHA1(source)
    local compiled = compilerCache[sourceChecksum]
    if not compiled then
        // Step 1: Compiling source for the first time
        local has_no_error
        has_no_error, compiled = pcall(Nova.compile, source)
        // check for debugging
        // we always compile the source, even if debugging is enabled
        if enable_debugging then
            compiled = source
        end
        if not has_no_error then Nova.log("e", string.format("Compile error: %s", compiled)) return false end
        compilerCache[sourceChecksum] = compiled
        Nova.log("d", string.format("Compiled source for the first time: %s", sourceChecksum))
    end

    // Step 2: String replacement
    for k, v in pairs(replaceText or {}) do
        compiled = string.Replace(compiled, k, v)
    end

    // Step 3: Compressing compiled
    local compressed = Nova.lzw.compress(compiled)

    // Step 4: Encrypt compressed
        // Step 4.1: Generating encryption key
        vars:Get("encryptionKey")

        // Step 4.2: Encrypting compressed
        local encrypted = Nova.cipher.encrypt(compressed, vars:Get("encryptionKey"))

    // Step 5: Assembling code
        // Step 5.1: Registering variables
        local lines = Nova.obfuscator.line:Register("key", vars:Set("key", vars:Get("encryptionKey"), false, true))
        lines:Register("cipherAttribute", vars:Set("cipherAttribute", "\\099\\105\\112\\104\\101\\114", false, true))
        lines:Register("decode", vars:Set("decode", payloads["decode"], false))
        lines:Register("integrityCheck", vars:Set("integrityCheck", payloads["check"], false))
        lines:Register("cipher", vars:Set("cipher", "NOVA_SHARED.decrypt", false))
        lines:Register("interpreter", vars:Set("interpreter", "NOVA_SHARED.interpreter", false))
        lines:Register("decompress", vars:Set("decompress", "NOVA_SHARED.decompress", false))
        lines:Register("getfenv", vars:Set("getfenv", payloads["getfenv"], false))
        lines:Register("banme", vars:Set("banme", payloads["banme"], false))
        lines:Register("code", vars:Set("code", encrypted, false, true))

        // Step 5.2: Defining integrity checks
        lines:Register("integrity_cipher", string.format("local s1,e = %s(%s.cipher, %q) if not s1 then %s('cipher integrity check failed: ' .. e)  end ",
            vars:Get("integrityCheck"),
            vars:Get("cipher"),
            Nova.obfuscator.getFunctionChecksum(NOVA_SHARED.decrypt.cipher),
            vars:Get("banme")
        ))
        lines:Register("integrity_interpreter", string.format("local s2,e = %s(%s, %q) if not s2 then %s('interpreter integrity check failed: ' .. e)  end ",
            vars:Get("integrityCheck"),
            vars:Get("interpreter"),
            Nova.obfuscator.getFunctionChecksum(NOVA_SHARED.interpreter),
            vars:Get("banme")
        ))
        lines:Register("integrity_decompress", string.format("local s3,e = %s(%s, %q) if not s3 then %s('decompress integrity check failed: ' .. e)  end ",
            vars:Get("integrityCheck"),
            vars:Get("decompress"),
            Nova.obfuscator.getFunctionChecksum(NOVA_SHARED.decompress),
            vars:Get("banme")
        ))

        // Step 5.3: Defining executer
        lines:Register("decoded", vars:Set("decoded", string.format("%s(%s)", vars:Get("decode"), vars:Get("code"))))
        lines:Register("decrypted", vars:Set("decrypted", string.format("%s[%s](%s,%s)", vars:Get("cipher"), string.format("%s(%s)", vars:Get("decode"), vars:Get("cipherAttribute")), vars:Get("decoded"), vars:Get("key"))))
        lines:Register("decompressed", vars:Set("decompressed", string.format("%s(%s)", vars:Get("decompress"), vars:Get("decrypted"))))
        if enable_debugging then
            lines:Register("run", vars:Set("run", string.format("s1 and s2 and s3 and RunString(%s) or nil;", vars:Get("decompressed"))))
        else
            // The code will not run if any of the integrity checks failed
            // We do this because a client could just block the reporting to the server
            lines:Register("run", vars:Set("run", string.format("s1 and s2 and s3 and %s(%s)() or nil;", vars:Get("interpreter"), vars:Get("decompressed"))))
        end

        // Step 5.4: Assembling functions
        local funcImports = {
            lines:Insert("decode"),
            lines:Insert("integrityCheck"),
            lines:Insert("cipherAttribute"),
            lines:Insert("decompress"),
            lines:Insert("interpreter"),
            lines:Insert("cipher"),
            lines:Insert("key"),
            lines:Insert("code"),
            lines:Insert("banme"),
        }

        for i = 1, math.random(2,4) do
            table.insert(funcImports, vars:Set("import_f_key_" .. i, vars:Get("import_f_val_" .. i), false, true))
        end
        for i = 1, math.random(1,5) do
            table.insert(funcImports, vars:Set("encryptionkey_f_key_" .. i, vars:Get("encryptionkey_f_val_" .. i), false, true))
        end
        for i = 1, math.random(2,3) do
            table.insert(funcImports, vars:Set("encoding_f_key_" .. i, Encode(vars:Get("encoding_f_val_" .. i)), false, true))
        end

        table.insert(funcImports, vars:Set("encoded_f_key", Encode(math.random(1,2) == 1 and payloads["decode"] or "NOVA_SHARED.decrypt"), false, true))
        //TODO: Add more randomization
        lines:Register("fake1", vars:Set("fake1", string.format("%s[%s](%s, %s)", vars:Get("cipher"), string.format("%s(%s)", vars:Get("decode"), vars:Get("cipherAttribute")), vars:Get("encoded_f_key"), vars:Get("encryptionkey_f_key_1"))), 2)
        lines:Register("fake2", vars:Set("fake2", string.format("%s(%s)", vars:Get("decode"), vars:Get("encoding_f_key_1"))), 2)
        lines:Register("fake3", vars:Set("fake3", string.format("%s(%s)", vars:Get("decode"), vars:Get("encoding_f_key_2"))), 2)

        local obfuscated = Nova.obfuscator.randomOrder(funcImports)

        // Step 5.3: Add integrity checks

        // Step 5.3: Assembling executor
        obfuscated = obfuscated ..
            lines:Insert("integrity_cipher") ..
            lines:Insert("integrity_interpreter") ..
            lines:Insert("integrity_decompress") ..
            lines:Insert("decoded") .. lines:Insert("fake1") .. lines:Insert("fake2") ..
            lines:Insert("decrypted") ..  lines:Insert("fake2") .. lines:Insert("fake3") ..
            lines:Insert("decompressed") .. lines:Insert("fake1") ..
            lines:Insert("run") .. lines:Insert("fake3")

        // Step 5.4: Appending fake variables
        local fakeVars = {}
        local fakeVarsCount = math.random(2,6)
        for i = 1, fakeVarsCount do
            if i != 1 and i != fakeVarsCount then
                table.insert(fakeVars, vars:Set("append_f_key_" .. i, vars:Get("append_f_key_" .. i - 1), false))
            else
                table.insert(fakeVars, vars:Set("append_f_key_" .. i, vars:Get("append_f_val_" .. i), false, true))
            end
        end
        obfuscated = obfuscated .. Nova.obfuscator.randomOrder(fakeVars)

    Nova.log("d",string.format("Finished obfuscated code size: %d", string.len(obfuscated)))
    return obfuscated
end