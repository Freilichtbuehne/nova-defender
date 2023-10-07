local seed = 0
local mod = 2 ^ 32

local function lrotate(x, disp)
    return bit.lshift(x, disp) + bit.rshift(x, 32 - disp)
end
local function rrotate(x, disp)
    return bit.rshift(x, disp) + bit.lshift(x, 32 - disp)
end

local function SetSeed(input)
    local hash = util.SHA1(input)
    // take first 11 chars
    hash = string.sub(hash, 1, 8)
    // convert to number
    local hash_num = tonumber(string.upper(hash),16)

    seed = hash_num % mod
end

local function XORShift()
    seed = lrotate(seed, 13) +
        rrotate(seed, 17) +
        lrotate(seed, 5) +
        seed

    return seed % 256
end

local function Encrypt(input, key)
    SetSeed(key)
    local output = {}

    for i = 1, string.len(input) do
        local b = string.byte(input, i)
        local c = XORShift()
        local e = bit.bxor(c, b)
        output[i] =  string.format("\\%03d", e)
    end

    return table.concat(output)
end

local function EncryptRaw(input, key)
    SetSeed(key)
    local output = {}

    for i = 1, string.len(input) do
        local b = string.byte(input, i)
        local c = XORShift()
        local e = bit.bxor(c, b)
        output[i] =  string.char(e)
    end

    return table.concat(output)
end

local function Decrypt(input, key)
    SetSeed(key)
    local output = {}

    for i = 1, string.len(input) do
        local b = string.byte(input, i)
        local c = XORShift()
        local e = bit.bxor(b, c)
        output[i] = string.char(e)
    end

    return table.concat(output)
end

Nova.cipher = {
    encrypt = Encrypt,
    encrypt_raw = EncryptRaw,
    decrypt = Decrypt,
}