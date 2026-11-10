json
	importance:5 inline js dynamic parse: string value
		JSON.parse(value)
	importance:5 inline js string stringify: dynamic value
		JSON.stringify(value)

interface object
	inline js string toJson() JSON.stringify(this)
	inline js dynamic fromJson(string json) JSON.parse(json)
	
	static string toTypedTsv: dynamic[] objects
		if(objects.length == 0) return ""
		string[] fieldNames
		string[] fieldTypes
		let result = ""

		// Get all field names and types
		for obj in objects
			forDynamic obj as value, key
				if typeof(value) == "function" then continue
				if(!fieldNames.includes(key)) {
					fieldNames.add(key)
					fieldTypes.add(object.typeof(value))
				}
		
		// Output field names
		for fieldNames
			if i > 0 then result += "\t"
			result += .
		result += "\n"

		// Output field types
		for fieldTypes
			if i > 0 then result += "\t"
			result += .
		result += "\n"
			
		// Output values
		for objects
			dynamic object = .
			for fieldNames
				if i > 0 then result += "\t"
				let value = object[.]
				if value == undefined or value == null
					switch fieldTypes[i]
						"number"	result += "0"
						"boolean"	result += "false"
						"string"	result += ""
						default	result += "null"
				else
					switch fieldTypes[i]
						"object"	result += json.stringify(value)
						"number"	result += value.toString()
						"boolean"	result += value ? "true" : "false"
						default	result += string(value.toString()).replaceAll("\t" with "\\t").replaceAll("\n" with "\\n").replaceAll("\r" with "")
			result += "\n"

		return result

	static dynamic fromTsv: string tsv
		let lines = tsv.split("\n")
		if(lines.length < 2) return []
		let names = lines[0].split("\t")
		dynamic[] result
		for i = 1 to lines.length
			let line = lines[i]
				let values = line.split("\t")
				dynamic obj = {}
				for names
					obj[.] = values[i].replaceAll("\\t" with "\t").replaceAll("\\n" with "\n")
				result.add(obj)
		return result

	static dynamic fromTypedTsv: string tsv
		let lines = tsv.split("\n")
		if(lines.length < 2) return []
		let names = lines[0].split("\t")
		let types = lines[1].split("\t")
		dynamic[] result
		for lineIndex = 2 to lines.length
			let line = lines[lineIndex]
				let values = line.split("\t")
				dynamic obj = {}
				for fieldIndex, name in names
					let value = values[fieldIndex]
					switch types[fieldIndex]
						"object"	obj[name] = json.parse(value)
						"number"	obj[name] = value.toFloat
						"boolean"	obj[name] = value == "true"
						"undefined"	
						"null"	obj[name] = null
						default	obj[name] = value ? value.toString().replaceAll("\\t" with "\t").replaceAll("\\n" with "\n") : ""
				result.add(obj)
		return result

	static js string toYaml: dynamic subject
		function refWalk(v, counts, path) {
			if(v === null || v === undefined) return
			let t = typeof v
			if(t !== "object") return
			counts.set(v, (counts.get(v) || 0) + 1)
			if(path.has(v)) return
			path.add(v)
			if(Array.isArray(v)) {
				for(let i = 0, n = v.length; i < n; ++i)
					refWalk(v[i], counts, path)
			} else if(v instanceof Map) {
				for(let e of v) {
					refWalk(e[0], counts, path)
					refWalk(e[1], counts, path)
				}
			} else {
				let tset = v.constructor ? window["_transients_of_" + v.constructor.name] : null
				for(let k in v)
					if(Object.prototype.hasOwnProperty.call(v, k)) {
						if(tset && tset.has(k)) continue
						let child = v[k]
						refWalk(child, counts, path)
					}
			}
			path.delete(v)
		}
		function typeTag(v) {
			if(v === null) return ""
			if(Array.isArray(v)) return ""
			let n = v.constructor && v.constructor.name
			return "!!" + (n && /^[A-Za-z_][A-Za-z0-9_]*$/.test(n) ? n : "Object") + " "
		}
		function escStr(s) {
			return "\"" + s.replace(/\\/g, "\\\\").replace(/"/g, "\\\"").replace(/\n/g, "\\n").replace(/\r/g, "\\r").replace(/\t/g, "\\t") + "\""
		}
		// Keys are quoted unless they are identifiers. null, true and false would be read as these values
		function key(k) {
			return /^[A-Za-z_][A-Za-z0-9_]*$/.test(k) && !/^(null|true|false)$/i.test(k) ? k : escStr(k)
		}
		function ser(v, counts, anchors, nextId) {
			if(v === null) return "null"
			if(v === undefined) return "null"
			let t = typeof v
			if(t === "string") return escStr(v)
			if(t === "number") {
				if(v !== v) return ".nan"
				if(v === Infinity) return ".inf"
				if(v === -Infinity) return "-.inf"
				return String(v)
			}
			if(t === "boolean") return v ? "true" : "false"
			if(t === "bigint") return "\"" + v + "\""
			if(t === "function") return "\"\""
			let multi = (counts.get(v) || 0) > 1
			if(multi) {
				if(anchors.has(v)) return "*" + anchors.get(v)
				let id = "id" + nextId[0]++
				anchors.set(v, id)
			}
			let tag = typeTag(v), body
			if(Array.isArray(v)) {
				let p = [], n = v.length
				for(let i = 0; i < n; ++i)
					p.push(ser(v[i], counts, anchors, nextId))
				body = "[" + p.join(", ") + "]"
			} else if(v instanceof Map) {
				let p = []
				if(v.size === 0 || typeof v.keys().next().value === "string") {
					for(let e of v) {
						p.push(key(e[0]) + ": " + ser(e[1], counts, anchors, nextId))
					}
					body = "{" + p.join(", ") + "}"
				} else {
					for(let e of v)
						p.push("[" + ser(e[0], counts, anchors, nextId) + ", " + ser(e[1], counts, anchors, nextId) + "]")
					body = "[" + p.join(", ") + "]"
				}
			} else {
				let tset = v.constructor ? window["_transients_of_" + v.constructor.name] : null
				let p = []
				for(let k in v)
					if(Object.prototype.hasOwnProperty.call(v, k)) {
						if(tset && tset.has(k)) continue
						let child = v[k]
						p.push(key(k) + ": " + ser(child, counts, anchors, nextId))
					}
				body = "{" + p.join(", ") + "}"
			}
			let out = tag + body
			if(multi) out = "&" + anchors.get(v) + " " + out
			return out
		}
		let counts = new Map()
		refWalk(subject, counts, new Set())
		return ser(subject, counts, new Map(), [0])

	// Parses the first document of a YAML file, null if there is none.
	// Mappings become objects, sequences lists and scalars strings, numbers, booleans or null (YAML 1.2 core schema).
	// A mapping with a tag that names a class becomes an instance of it (!!Player), !!Map creates a Map.
	static dynamic fromYaml: string yaml
		docs := fromYamlDocuments(yaml)
		return docs.length > 0 ? docs[0] : null

	// Parses all documents of a YAML file (they are separated by "---")
	static js dynamic[] fromYamlDocuments: string yaml
		let s = (yaml.charCodeAt(0) === 65279 ? yaml.slice(1) : yaml).replace(/\r\n?/g, "\n"), n = s.length, i = 0
		let anchors = new Map(), documents = []
		let escapes = "0abt\tnvfre \"/\\N_LP", escapeCodes = [0, 7, 8, 9, 9, 10, 11, 12, 13, 27, 32, 34, 47, 92, 133, 160, 8232, 8233]
		// Where a node is: in a block where block collections can start, after the ":" of a key, at a key, or in a flow collection
		const Block = 0, Value = 1, Key = 2, Flow = 3
		function fail(message) {
			throw new Error("fromYaml: " + message + " in line " + s.slice(0, i).split("\n").length)
		}
		function isSpace(c) {
			return c === 32 || c === 9
		}
		// Whether a space, a line break or the end of the file is at j
		function isBlank(j) {
			let c = s.charCodeAt(j)
			return c === 32 || c === 9 || c === 10 || c !== c
		}
		function isFlowIndicator(c) {
			return c === 44 || c === 91 || c === 93 || c === 123 || c === 125
		}
		// Whether the indicator c ("-", "?" or ":") is at i. A blank has to follow it
		function atIndicator(c) {
			return s.charCodeAt(i) === c && isBlank(i + 1)
		}
		// Whether the line at j starts with the document marker "---" or "..."
		function atMarker(j) {
			let c = s.charCodeAt(j)
			return (c === 45 || c === 46) && s.charCodeAt(j + 1) === c && s.charCodeAt(j + 2) === c && isBlank(j + 3) && (j === 0 || s.charCodeAt(j - 1) === 10)
		}
		function column() {
			return i ? i - s.lastIndexOf("\n", i - 1) - 1 : 0
		}
		function lineEnd() {
			let end = s.indexOf("\n", i)
			return end < 0 ? n : end
		}
		// Skips whitespace, line breaks and comments. Returns whether it reached another line
		function skipBlank() {
			let crossed = false
			for(;;) {
				let c = s.charCodeAt(i)
				if(c === 10) crossed = true
				if(c === 32 || c === 9 || c === 10) ++i
				else if(c === 35 && isBlank(i - 1)) i = lineEnd()
				else return crossed
			}
		}
		function isFirstOfLine() {
			return !s.slice(i - column(), i).trim()
		}
		// Skips to the next token, which has to be the first of its line. Returns its column, -1 at the end of the document
		function nextLine() {
			skipBlank()
			if(i >= n || atMarker(i)) return -1
			if(!isFirstOfLine()) fail("unexpected text")
			return column()
		}
		// Reads an anchor name, alias name or tag, which end at a blank or flow indicator
		function readToken() {
			let start = i
			while(i < n && !isBlank(i) && !isFlowIndicator(s.charCodeAt(i))) ++i
			return s.slice(start, i)
		}
		// Creates the collection of a node: a Map for !!Map, an instance for a tag that names a class
		function create(anchor, tag, list) {
			let construct = tag && globalThis["_" + tag]
			let target = tag === "Map" ? new Map() : list ? [] : typeof construct === "function" ? new construct() : {}
			if(anchor) anchors.set(anchor, target)
			return target
		}
		function add(target, value) {
			if(!(target instanceof Map)) target.push(value)
			else if(Array.isArray(value)) target.set(value[0], value[1])
			else fail("a Map needs [key, value] pairs")
		}
		function set(target, key, value) {
			if(target instanceof Map) target.set(key, value)
			else if(key === "<<" && value && typeof value === "object") {
				// Merge key: adds the entries of a mapping (or of a list of mappings) that target doesn't have
				for(let source of Array.isArray(value) ? value : [value])
					for(let k of Object.keys(source))
						if(!Object.prototype.hasOwnProperty.call(target, k)) target[k] = source[k]
			} else if(key === "__proto__") Object.defineProperty(target, key, { value: value, enumerable: true, writable: true, configurable: true })
			else target[key] = value
		}
		// Converts a plain scalar to null, a boolean or a number if it is written like one
		function resolve(text) {
			if(text === "" || text === "~" || text === "null" || text === "Null" || text === "NULL") return null
			if(text === "true" || text === "True" || text === "TRUE") return true
			if(text === "false" || text === "False" || text === "FALSE") return false
			let c = text.charCodeAt(0)
			if(c < 43 || c > 57) return text
			if(/^([-+]?(\.[0-9]+|[0-9]+(\.[0-9]*)?)([eE][-+]?[0-9]+)?|0o[0-7]+|0x[0-9a-fA-F]+)$/.test(text)) return Number(text)
			if(/^[-+]?\.(inf|Inf|INF)$/.test(text)) return c === 45 ? -Infinity : Infinity
			return /^\.(nan|NaN|NAN)$/.test(text) ? NaN : text
		}
		// Folds the line break at i and moves i to the text of the next line.
		// Returns the text since start, followed by a space, or by a line break for each empty line
		function fold(start) {
			let text = s.slice(start, i).replace(/[ \t]+$/, ""), breaks = 0
			for(; i < n; ++i) {
				let c = s.charCodeAt(i)
				if(c === 10) ++breaks
				else if(c !== 32 && c !== 9) break
			}
			return text + (breaks > 1 ? "\n".repeat(breaks - 1) : " ")
		}
		// Reads a scalar in single or double quotes
		function parseQuoted(quote) {
			let out = "", start = ++i
			for(;;) {
				let c = s.charCodeAt(i)
				if(c !== c) fail("unterminated string")
				if(c === quote) {
					out += s.slice(start, i++)
					if(quote === 34 || s.charCodeAt(i) !== 39) return out
					// Two single quotes are an escaped single quote
					start = i++
				} else if(c === 92 && quote === 34) {
					out += s.slice(start, i)
					let e = s[i + 1], length = e === "x" ? 2 : e === "u" ? 4 : e === "U" ? 8 : 0, k = escapes.indexOf(e)
					i += 2
					if(length) {
						let hex = s.slice(i, i + length)
						if(!/^[0-9a-fA-F]+$/.test(hex) || hex.length < length) fail("bad escape sequence")
						out += String.fromCodePoint(parseInt(hex, 16))
						i += length
					} else if(e === "\n") {
						// An escaped line break joins the lines
						while(isSpace(s.charCodeAt(i))) ++i
					} else out += k < 0 ? "\\" + e : String.fromCharCode(escapeCodes[k])
					start = i
				} else if(c === 10) {
					out += fold(start)
					start = i
				} else ++i
			}
		}
		// Whether the plain scalar ends at i: at a ":" before a blank and, in flow collections, at flow indicators
		function endsPlain(flow) {
			let c = s.charCodeAt(i)
			return c === 58 ? isBlank(i + 1) || flow && isFlowIndicator(s.charCodeAt(i + 1)) : flow && isFlowIndicator(c)
		}
		// Reads a scalar without quotes. In blocks, it continues on lines that are indented more than indent
		function parsePlain(indent, flow) {
			let out = "", start = i
			for(;;) {
				let c = s.charCodeAt(i)
				if(c === 10 || c !== c) {
					let end = i, text = fold(start)
					if(i >= n || s.charCodeAt(i) === 35 || !flow && (column() <= indent || atMarker(i)) || endsPlain(flow)) {
						i = end
						break
					}
					out += text
					start = i
				} else if(endsPlain(flow) || c === 35 && isSpace(s.charCodeAt(i - 1))) break
				else ++i
			}
			return out + s.slice(start, i).replace(/[ \t]+$/, "")
		}
		// Reads a literal (|) or folded (>) block scalar: the following lines that are indented more than indent
		function parseBlockScalar(indent) {
			let folded = s.charCodeAt(i++) === 62, chomp = 0, textIndent = -1, c
			// Header: "+" keeps the line breaks at the end, "-" removes them, a digit is the indentation of the text
			for(; (c = s.charCodeAt(i)) === 43 || c === 45 || c >= 49 && c <= 57; ++i) {
				if(c === 43) chomp = 1
				else if(c === 45) chomp = -1
				else textIndent = indent + c - 48
			}
			while(isSpace(s.charCodeAt(i))) ++i
			if(s.charCodeAt(i) === 35) i = lineEnd()
			if(i < n && s.charCodeAt(i) !== 10) fail("unexpected text after block scalar header")
			++i
			let out = "", empty = 0, any = false, more = false
			while(i < n && !atMarker(i)) {
				let j = i
				while(s.charCodeAt(j) === 32 && (textIndent < 0 || j - i < textIndent)) ++j
				c = s.charCodeAt(j)
				if(c !== c) break
				if(c === 10) {
					++empty
					i = j + 1
					continue
				}
				// The first line with text sets the indentation, a line that is indented less ends the scalar
				if(textIndent < 0 && j - i > indent) textIndent = j - i
				if(textIndent < 0 || j - i < textIndent) break
				// Folding joins lines with a space, except lines that are indented more
				let lineMore = folded && isSpace(c)
				if(!folded || lineMore || more) out += "\n".repeat(any ? empty + 1 : empty)
				else out += empty ? "\n".repeat(empty) : any ? " " : ""
				i = lineEnd()
				out += s.slice(j, i++)
				more = lineMore
				any = true
				empty = 0
			}
			// A last line without line break stays as it is
			if(i > n) i = n
			else if(chomp > 0) out += "\n".repeat(any ? empty + 1 : empty)
			else if(chomp === 0 && any) out += "\n"
			return out
		}
		// Reads a flow sequence [a, b] or a flow mapping {a: 1, b: 2}
		function parseFlow(anchor, tag) {
			let list = s.charCodeAt(i++) === 91, close = list ? 93 : 125, target = create(anchor, tag, list)
			for(;;) {
				skipBlank()
				let c = s.charCodeAt(i)
				if(c === close) {
					++i
					return target
				}
				if(c !== c) fail(list ? "unterminated [" : "unterminated {")
				if(atIndicator(63)) {
					++i
					skipBlank()
				}
				let key = parseNode(0, Flow), value = null
				skipBlank()
				let pair = s.charCodeAt(i) === 58
				if(pair) {
					++i
					skipBlank()
					value = parseNode(0, Flow)
					skipBlank()
				}
				if(!list) set(target, key, value)
				else if(pair) {
					// A pair in a sequence is a mapping with one entry
					let single = {}
					set(single, key, value)
					add(target, single)
				} else add(target, key)
				c = s.charCodeAt(i)
				if(c === 44) ++i
				else if(c !== close) fail(list ? "expected , or ]" : "expected , or }")
			}
		}
		// Reads the node after the "-", "?" or ":" of a block collection at column col:
		// the rest of the line, or the following lines if they are indented more
		function parseIndented(col, mode) {
			if(!skipBlank()) return i < n ? parseNode(col, mode) : null
			if(i >= n || atMarker(i)) return null
			// The items of a sequence can have the same indentation as its key
			let next = column()
			return next > col || mode === Value && next === col && atIndicator(45) ? parseNode(col, mode) : null
		}
		// Reads a block sequence whose items start with "-" at column col
		function parseBlockSequence(col, anchor, tag) {
			let target = create(anchor, tag, true)
			for(;;) {
				++i
				add(target, parseIndented(col, Block))
				let next = nextLine()
				if(next > col) fail("bad indentation")
				if(next < col || !atIndicator(45)) return target
			}
		}
		// Reads a block mapping whose keys start at column col
		function parseBlockMapping(col, anchor, tag) {
			let target = create(anchor, tag, false)
			for(;;) {
				let start = i, explicit = atIndicator(63), key, value = null
				if(explicit) {
					++i
					key = parseIndented(col, Block)
					skipBlank()
				} else {
					key = parseNode(col, Key)
					while(isSpace(s.charCodeAt(i))) ++i
					if(!atIndicator(58) || s.lastIndexOf("\n", i) >= start) fail("expected a key followed by a colon")
				}
				if(atIndicator(58) && (!explicit || column() === col)) {
					++i
					value = parseIndented(col, explicit ? Block : Value)
				}
				set(target, key, value)
				let next = nextLine()
				if(next > col) fail("bad indentation")
				if(next < col) return target
			}
		}
		// Reads the node at i. A block node belongs to a collection at column indent: its other lines are indented more
		function parseNode(indent, mode) {
			// compact: A block collection can start at i, which it can't after a key on the same line
			let flow = mode === Flow, compact = mode === Block || mode === Value && isFirstOfLine()
			let start = i, anchor = "", tag = "", own = false, c
			while((c = s.charCodeAt(i)) === 38 || c === 33) {
				++i
				if(c === 38) anchor = readToken()
				else {
					// !!name, !name, !handle!name or !<prefix:name>
					let close = s.charCodeAt(i) === 60 ? s.indexOf(">", i) : -1
					tag = close < 0 ? readToken() : s.slice(i, close)
					if(close >= 0) i = close + 1
					tag = tag.replace(/^.*[!:]/, "") || "str"
				}
				let end = i
				if(flow) skipBlank()
				else if(skipBlank()) {
					// No node follows. Only the items of a sequence can have the same indentation as its key
					if(i >= n || atMarker(i) || column() <= indent && !(mode === Value && column() === indent && atIndicator(45))) {
						i = end
						c = 10
						break
					}
					// Before a block mapping on the following lines, anchor and tag belong to the mapping. On the same line, they belong to its first key
					own = true
					compact = mode !== Key
					start = i
				}
			}
			if(!flow && (atIndicator(45) || atIndicator(63))) {
				if(!compact) fail("a block collection can't start here")
				return c === 45 ? parseBlockSequence(column(), anchor, tag) : parseBlockMapping(column(), anchor, tag)
			}
			let block = !flow && (c === 124 || c === 62), value
			if(c === 91 || c === 123) value = parseFlow(anchor, tag)
			else if(c === 42) {
				++i
				let name = readToken()
				if(!anchors.has(name)) fail("unknown alias " + name)
				value = anchors.get(name)
			} else {
				let quoted = c === 34 || c === 39
				let text = block ? parseBlockScalar(indent) : quoted ? parseQuoted(c) : parsePlain(indent, flow)
				value = tag === "str" || (block || quoted) && !/^(int|float|bool|null)$/.test(tag) ? text : resolve(text)
			}
			if(compact && !block) {
				while(isSpace(s.charCodeAt(i))) ++i
				if(atIndicator(58)) {
					// The node is the first key of a block mapping
					i = start
					return parseBlockMapping(column(), own ? anchor : "", own ? tag : "")
				}
			}
			if(anchor) anchors.set(anchor, value)
			return value
		}
		for(;;) {
			skipBlank()
			if(i >= n) return documents
			let c = s.charCodeAt(i), marker = atMarker(i)
			if(marker && c === 46 || c === 37 && column() === 0) {
				// End of a document or a directive like %YAML
				i = lineEnd()
				continue
			}
			if(marker) i += 3
			documents.push(parseIndented(-1, Block))
			if(nextLine() >= 0) fail("unexpected text")
		}

	static js dynamic fromXml: string xml
		let length = xml.length
		let i = 0
		function isWs(c) {
			return c === 9 || c === 10 || c === 13 || c === 32
		}
		function skipWs() {
			while(i < length && isWs(xml.charCodeAt(i))) ++i
		}
		function hasNonWs(value) {
			for(let j = 0, n = value.length; j < n; ++j) {
				let c = value.charCodeAt(j)
				if(c !== 9 && c !== 10 && c !== 13 && c !== 32) return true
			}
			return false
		}
		function decode(value) {
			let amp = value.indexOf("&")
			if(amp === -1) return value
			let result = value.slice(0, amp)
			let start = amp
			for(;;) {
				let end = value.indexOf(";", start + 1)
				if(end === -1) return result + value.slice(start)
				let entity = value.slice(start + 1, end)
				if(entity === "lt") result += "<"
				else if(entity === "gt") result += ">"
				else if(entity === "amp") result += "&"
				else if(entity === "quot") result += '"'
				else if(entity === "apos") result += "'"
				else if(entity.charCodeAt(0) === 35) {
					let code = entity.charCodeAt(1) === 120 || entity.charCodeAt(1) === 88 ? parseInt(entity.slice(2), 16) : parseInt(entity.slice(1), 10)
					result += isNaN(code) ? "&" + entity + ";" : String.fromCodePoint(code)
				} else result += "&" + entity + ";"
				let next = value.indexOf("&", end + 1)
				if(next === -1) return result + value.slice(end + 1)
				result += value.slice(end + 1, next)
				start = next
			}
		}
		function toTypedValue(value) {
			if(value === "true") return true
			if(value === "false") return false
			if(value === "null") return null
			if(value === "undefined") return undefined
				
			let first = value.charCodeAt(0)
			if(first === 123 || first === 91) {
				try {
					return JSON.parse(value)
				} catch(error) {}
			}
			if((first >= 48 && first <= 57) || first === 45 || first === 43 || first === 46) {
				let numeric = true
				for(let i = 1, len = value.length; i < len; i++) {
					let code = value.charCodeAt(i)
					if((code < 48 || code > 57) && code !== 46 && code !== 43 && code !== 45) {
						numeric = false
						break
					}
				}
				if(numeric) {
					let number = parseFloat(value)
					if(!isNaN(number)) return number
				}
			}
			return value
		}
		function addValue(target, name, value) {
			let existing = target[name]
			if(existing === undefined) target[name] = value
			else if(Array.isArray(existing)) existing.push(value)
			else target[name] = [existing, value]
		}
		function addText(node, value) {
			if(!hasNonWs(value)) return
			value = decode(value).trim()
			if(!value) return
			node.value._text = node.value._text ? string(node.value._text) + value : toTypedValue(value)
		}
		function finish(node, target) {
			let value = node.value
			if(!node.hasAttributes && !node.hasChildren) value = value._text === undefined ? "" : value._text
			else if(value._text === undefined) delete value._text
			addValue(target, node.name, value)
		}
		let root = {}
		let stack = []
		while(i < length) {
			let open = xml.indexOf("<", i)
			if(open === -1) {
				if(stack.length) addText(stack[stack.length - 1], xml.slice(i))
				break
			}
			if(open > i && stack.length) addText(stack[stack.length - 1], xml.slice(i, open))
			i = open + 1
			if(i >= length) break
			let marker = xml.charCodeAt(i)
			if(marker === 63) {
				let end = xml.indexOf("?>", i + 1)
				if(end === -1) throw new Error("fromXml: unterminated declaration")
				i = end + 2
				continue
			}
			if(marker === 33) {
				if(xml.slice(i + 1, i + 3) === "--") {
					let end = xml.indexOf("-->", i + 3)
					if(end === -1) throw new Error("fromXml: unterminated comment")
					i = end + 3
					continue
				}
				if(xml.slice(i + 1, i + 8) === "[CDATA[") {
					let end = xml.indexOf("]]>", i + 8)
					if(end === -1) throw new Error("fromXml: unterminated cdata")
					if(stack.length) addText(stack[stack.length - 1], xml.slice(i + 8, end))
					i = end + 3
					continue
				}
				let depth = 0
				let quote = 0
				++i
				while(i < length) {
					let c = xml.charCodeAt(i++)
					if(quote) {
						if(c === quote) quote = 0
						continue
					}
					if(c === 34 || c === 39) quote = c
					else if(c === 91) ++depth
					else if(c === 93 && depth) --depth
					else if(c === 62 && !depth) break
				}
				continue
			}
			if(marker === 47) {
				++i
				let start = i
				while(i < length) {
					let c = xml.charCodeAt(i)
					if(isWs(c) || c === 62) break
					++i
				}
				let name = xml.slice(start, i)
				while(i < length && xml.charCodeAt(i) !== 62) ++i
				if(i < length) ++i
				let node = stack.pop()
				if(!node || node.name !== name) throw new Error("fromXml: mismatched closing tag")
				finish(node, stack.length ? (stack[stack.length - 1].hasChildren = true, stack[stack.length - 1].value) : root)
				continue
			}
			let nameStart = i
			while(i < length) {
				let c = xml.charCodeAt(i)
				if(isWs(c) || c === 47 || c === 62) break
				++i
			}
			let node = { name: xml.slice(nameStart, i), value: {}, hasAttributes: false, hasChildren: false }
			while(i < length) {
				skipWs()
				let c = xml.charCodeAt(i)
				if(c === 47) {
					++i
					if(xml.charCodeAt(i) !== 62) throw new Error("fromXml: expected >")
					++i
					finish(node, stack.length ? (stack[stack.length - 1].hasChildren = true, stack[stack.length - 1].value) : root)
					break
				}
				if(c === 62) {
					++i
					stack.push(node)
					break
				}
				let attrStart = i
				while(i < length) {
					c = xml.charCodeAt(i)
					if(isWs(c) || c === 61 || c === 47 || c === 62) break
					++i
				}
				let attrName = xml.slice(attrStart, i)
				skipWs()
				let attrValue = ""
				if(xml.charCodeAt(i) === 61) {
					++i
					skipWs()
					let quote = xml.charCodeAt(i)
					if(quote === 34 || quote === 39) {
						let valueStart = ++i
						while(i < length && xml.charCodeAt(i) !== quote) ++i
						attrValue = toTypedValue(decode(xml.slice(valueStart, i)))
						if(i < length) ++i
					} else {
						let valueStart = i
						while(i < length) {
							quote = xml.charCodeAt(i)
							if(isWs(quote) || quote === 47 || quote === 62) break
							++i
						}
						attrValue = toTypedValue(decode(xml.slice(valueStart, i)))
					}
				}
				(node.value._attributes || (node.value._attributes = {}))[attrName] = attrValue
				node.hasAttributes = true
			}
		}
		if(stack.length) throw new Error("fromXml: unterminated tag")
		for(let name in root)
			return root
		return null
