local MAGNITUDE_POSTFIXES = { "K", "M", "B", "T", "Q", "Qu", "S", "Se", "O", "N", "D" }

local NumberFormatter = {}

function NumberFormatter.Abbreviate(number: number, precision: number, positiveMarked: boolean): string
	if number >= 10e32 then return `∞` end
	
    precision = precision or 2
    local log = math.floor(math.log(math.abs(number), 1_000))
    for comparedLog, postfix in MAGNITUDE_POSTFIXES do
        if comparedLog ~= log then continue end
        number = number / 1_000^log
        number = string.format(`%{if positiveMarked then "+" else ""}.{precision}f`, number) -- Reduce precision (e.g. 1.2345678M -> 1.23M)
        number = string.gsub(number, "%.*0+$", "") -- Remove excess precision (e.g. 1.00K -> 1K)
        return `{number}{postfix}`
    end
    number =
        if positiveMarked then if number >= 0 then `+{number}` else `-{number}`
        else number
    return number -- Found no postfix
end

function NumberFormatter.AddDelimiters(number: number, delimiter: string?): string
    delimiter = delimiter or ","
    local sign = number < 0 and "-" or ""
    number = math.abs(number)
    local formatted = string.reverse(tostring(number))
    formatted = string.gsub(formatted, "(%d%d%d)", `%1{string.reverse(delimiter)}`)
    formatted = string.reverse(formatted)
    formatted = string.gsub(formatted, `^{delimiter}`, "") -- Remove leading delimiter
    return `{sign}{formatted}`
end

return NumberFormatter