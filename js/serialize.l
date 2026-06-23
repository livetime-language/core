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
		for objects
			forDynamic . as value, key
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
						default	result += string(value.toString()).replaceAll("\t" with "\\t").replaceAll("\n" with "\\n")
			result += "\n"

		return result

	static dynamic fromTsv: string tsv
		let lines = tsv.split("\n")
		if(lines.length < 2) return []
		let names = lines[0].split("\t")
		dynamic[] result
		for 1 to lines.length
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
		for 2 to lines.length
			let line = lines[i]
				let values = line.split("\t")
				dynamic obj = {}
				for names
					let value = values[i]
					switch types[i]
						"object"	obj[.] = json.parse(value)
						"number"	obj[.] = value.toFloat
						"boolean"	obj[.] = value == "true"
						"undefined"	
						"null"	obj[.] = null
						default	obj[.] = value ? value.toString().replaceAll("\\t" with "\t").replaceAll("\\n" with "\n") : ""
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
			} else {
				let tset = v.constructor ? window["_transients_of_" + v.constructor.name] : null
				let p = []
				for(let k in v)
					if(Object.prototype.hasOwnProperty.call(v, k)) {
						if(tset && tset.has(k)) continue
						let child = v[k]
						let kk = /^[A-Za-z_][A-Za-z0-9_]*$/.test(k) ? k : escStr(k)
						p.push(kk + ": " + ser(child, counts, anchors, nextId))
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

	static js dynamic fromYaml: string yaml
		function isIgnorableWs(c) {
			if(c === 9 || c === 10 || c === 13 || c === 32) return true
			if(c === 133 || c === 160 || c === 5760) return true
			if(c >= 8192 && c <= 8202) return true
			if(c === 8232 || c === 8233) return true
			if(c === 8239 || c === 8287 || c === 12288) return true
			if(c === 65279) return true
			return false
		}
		function skipWs(s, i) {
			let n = s.length
			while(i < n && isIgnorableWs(s.charCodeAt(i))) ++i
			return i
		}
		function isIdentStart(c) {
			return (c >= 65 && c <= 90) || (c >= 97 && c <= 122) || c === 95
		}
		function isIdentChar(c) {
			return isIdentStart(c) || (c >= 48 && c <= 57)
		}
		function readIdent(s, i) {
			let j = i
			while(j < s.length && isIdentChar(s.charCodeAt(j))) ++j
			return [s.slice(i, j), j]
		}
		function construct(tag) {
			let C = globalThis["_" + tag]
			if(typeof C === "function") return new C()
			if(tag === "Array") return []
			if(tag === "Object") return {}
			return {}
		}
		function parseString(s, ctx) {
			let n = s.length, i = ctx.i
			if(s.charCodeAt(i) !== 34) throw new Error("fromYaml: expected \"")
			++i
			let out = ""
			while(i < n) {
				let c = s.charCodeAt(i)
				if(c === 34) {
					ctx.i = i + 1
					return out
				}
				if(c === 92 && i + 1 < n) {
					let nxt = s.charCodeAt(i + 1)
					if(nxt === 92) { out += "\\"; i += 2; continue }
					if(nxt === 34) { out += "\""; i += 2; continue }
					if(nxt === 110) { out += "\n"; i += 2; continue }
					if(nxt === 114) { out += "\r"; i += 2; continue }
					if(nxt === 116) { out += "\t"; i += 2; continue }
				}
				out += s[i++]
			}
			throw new Error("fromYaml: unterminated string")
		}
		function parseScalar(s, ctx) {
			let i = ctx.i, n = s.length, cc = s.charCodeAt(i)
			if(cc === 34) return parseString(s, ctx)
			function kw(t, len) {
				if(i + len > n) return false
				if(s.slice(i, i + len) !== t) return false
				let nx = i + len
				return nx >= n || !isIdentChar(s.charCodeAt(nx))
			}
			if(kw("null", 4)) { ctx.i = i + 4; return null }
			if(kw("true", 4)) { ctx.i = i + 4; return true }
			if(kw("false", 5)) { ctx.i = i + 5; return false }
			if(kw(".nan", 4)) { ctx.i = i + 4; return NaN }
			if(kw(".inf", 4)) { ctx.i = i + 4; return Infinity }
			if(kw("-.inf", 5)) { ctx.i = i + 5; return -Infinity }
			let j = i
			if(cc === 45) ++j
			let has = false
			if(j < n && s.charCodeAt(j) === 46) {
				++j
				while(j < n && s.charCodeAt(j) >= 48 && s.charCodeAt(j) <= 57) { has = true; ++j }
			} else {
				while(j < n && s.charCodeAt(j) >= 48 && s.charCodeAt(j) <= 57) { has = true; ++j }
				if(j < n && s.charCodeAt(j) === 46) {
					++j
					while(j < n && s.charCodeAt(j) >= 48 && s.charCodeAt(j) <= 57) { has = true; ++j }
				}
			}
			if(j < n && (s.charCodeAt(j) === 101 || s.charCodeAt(j) === 69)) {
				++j
				if(j < n && (s.charCodeAt(j) === 45 || s.charCodeAt(j) === 43)) ++j
				while(j < n && s.charCodeAt(j) >= 48 && s.charCodeAt(j) <= 57) { has = true; ++j }
			}
			if(has) {
				let start = ctx.i
				ctx.i = j
				return parseFloat(s.slice(start, j))
			}
			throw new Error("fromYaml: bad scalar at " + i)
		}
		function parseFlowArrayInto(arr, s, ctx) {
			while(true) {
				ctx.i = skipWs(s, ctx.i)
				if(ctx.i >= s.length) throw new Error("fromYaml: unterminated [")
				if(s.charCodeAt(ctx.i) === 93) { ++ctx.i; break }
				arr.push(parseValue(s, ctx))
				ctx.i = skipWs(s, ctx.i)
				let c = s.charCodeAt(ctx.i)
				if(c === 93) { ++ctx.i; break }
				if(c !== 44) throw new Error("fromYaml: expected , or ]")
				++ctx.i
			}
		}
		function parseFlowMapInto(obj, s, ctx) {
			while(true) {
				ctx.i = skipWs(s, ctx.i)
				if(ctx.i >= s.length) throw new Error("fromYaml: unterminated {")
				if(s.charCodeAt(ctx.i) === 125) { ++ctx.i; break }
				let key
				if(s.charCodeAt(ctx.i) === 34)
					key = parseString(s, ctx)
				else {
					let [id, ni] = readIdent(s, ctx.i)
					if(!id) throw new Error("fromYaml: expected key")
					key = id
					ctx.i = ni
				}
				ctx.i = skipWs(s, ctx.i)
				if(s.charCodeAt(ctx.i) !== 58) throw new Error("fromYaml: expected :")
				++ctx.i
				obj[key] = parseValue(s, ctx)
				ctx.i = skipWs(s, ctx.i)
				let c = s.charCodeAt(ctx.i)
				if(c === 125) { ++ctx.i; break }
				if(c !== 44) throw new Error("fromYaml: expected , or }")
				++ctx.i
			}
		}
		function parseTagged(s, ctx, anchor) {
			ctx.i += 2
			let [tag, ni] = readIdent(s, ctx.i)
			ctx.i = skipWs(s, ni)
			if(!tag) throw new Error("fromYaml: missing tag")
			let c = s.charCodeAt(ctx.i)
			let inst = construct(tag)
			if(c === 91 && typeof inst.push !== "function") inst = []
			if(anchor) ctx.anchors.set(anchor, inst)
			if(c === 91) {
				++ctx.i
				parseFlowArrayInto(inst, s, ctx)
			} else if(c === 123) {
				++ctx.i
				parseFlowMapInto(inst, s, ctx)
			} else throw new Error("fromYaml: expected [ or { after tag")
			return inst
		}
		function parseValue(s, ctx) {
			ctx.i = skipWs(s, ctx.i)
			let anchor = null
			if(s.charCodeAt(ctx.i) === 38) {
				++ctx.i
				let [an, ni] = readIdent(s, ctx.i)
				if(!an) throw new Error("fromYaml: bad anchor")
				anchor = an
				ctx.i = skipWs(s, ni)
			}
			if(s.charCodeAt(ctx.i) === 42) {
				++ctx.i
				let [al, ni] = readIdent(s, ctx.i)
				if(!al) throw new Error("fromYaml: bad alias")
				ctx.i = skipWs(s, ni)
				if(anchor) throw new Error("fromYaml: anchor with alias")
				let ref = ctx.anchors.get(al)
				if(ref === undefined) throw new Error("fromYaml: unknown alias " + al)
				return ref
			}
			if(ctx.i + 1 < s.length && s.charCodeAt(ctx.i) === 33 && s.charCodeAt(ctx.i + 1) === 33)
				return parseTagged(s, ctx, anchor)
			if(s.charCodeAt(ctx.i) === 91) {
				let arr = []
				if(anchor) ctx.anchors.set(anchor, arr)
				++ctx.i
				parseFlowArrayInto(arr, s, ctx)
				return arr
			}
			if(anchor) throw new Error("fromYaml: anchor without tagged value")
			return parseScalar(s, ctx)
		}
		let ctx = { i: 0, anchors: new Map() }
		ctx.i = skipWs(yaml, 0)
		if(ctx.i >= yaml.length) return null
		let root = parseValue(yaml, ctx)
		ctx.i = skipWs(yaml, ctx.i)
		if(ctx.i < yaml.length) throw new Error("fromYaml: trailing input")
		return root

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
